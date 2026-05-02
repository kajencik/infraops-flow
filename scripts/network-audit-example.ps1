<#
.SYNOPSIS
Collects a small read-only network reachability snapshot from a config file.

.DESCRIPTION
Runs asynchronous ICMP and TCP port probes against a defined host list,
prints an operator-facing table, and can optionally write a current JSON
snapshot plus a simple run history.

This script is intentionally generic. It does not assume any vendor, SSH key,
inventory parser, or real environment path. Targets, ports, and output files
belong in config.

.PARAMETER ConfigPath
Path to the JSON config file. Defaults to the example config in this repo.

.PARAMETER SnapshotPath
Optional override for the current-run snapshot JSON path.

.PARAMETER HistoryPath
Optional override for the appended run-history JSON path.

.PARAMETER Quiet
Suppresses the final file-write summary lines.

.EXAMPLE
./network-audit-example.ps1

.EXAMPLE
./network-audit-example.ps1 -ConfigPath ..\config\network-audit.example.json
#>

[CmdletBinding()]
param(
    [string]$ConfigPath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'config\network-audit.example.json'),
    [string]$SnapshotPath,
    [string]$HistoryPath,
    [switch]$Quiet
)

$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path $PSScriptRoot -Parent

function Resolve-RepoRelativePath {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return Join-Path $repoRoot $Path
}

function Read-NetworkAuditConfig {
    param([string]$Path)

    $resolvedPath = Resolve-RepoRelativePath -Path $Path
    if (-not (Test-Path $resolvedPath)) {
        throw "Config file not found: $resolvedPath"
    }

    $config = Get-Content -Path $resolvedPath -Raw | ConvertFrom-Json -Depth 10
    if (-not $config.hosts -or @($config.hosts).Count -eq 0) {
        throw 'Config file must define at least one host entry under hosts.'
    }

    return $config
}

function Test-TcpPort {
    param(
        [string]$ComputerName,
        [int]$Port,
        [int]$TimeoutMs = 300
    )

    try {
        $client = New-Object Net.Sockets.TcpClient
        $iar = $client.BeginConnect($ComputerName, $Port, $null, $null)
        if ($iar.AsyncWaitHandle.WaitOne($TimeoutMs)) {
            $client.EndConnect($iar) | Out-Null
            $client.Close()
            return $true
        }

        $client.Close()
        return $false
    }
    catch {
        return $false
    }
}

function Start-AsyncPingJobs {
    param($TargetHosts)

    $jobsByAddress = @{}
    foreach ($target in @($TargetHosts)) {
        $jobsByAddress[$target.address] = Start-Job -Name ("ping-{0}" -f $target.address.Replace('.', '-')) -ScriptBlock {
            param($Target)

            try {
                $reply = Test-Connection -ComputerName $Target.address -Count 1 -ErrorAction Stop | Select-Object -First 1
                $latency = $null
                if ($null -ne $reply.Latency) {
                    $latency = [int]$reply.Latency
                }
                elseif ($null -ne $reply.ResponseTime) {
                    $latency = [int]$reply.ResponseTime
                }

                if ($null -ne $latency -and $latency -le 0) {
                    $latency = 1
                }

                [pscustomobject]@{
                    Address   = $Target.address
                    Reachable = $true
                    LatencyMs = $latency
                    Error     = '-'
                }
            }
            catch {
                [pscustomobject]@{
                    Address   = $Target.address
                    Reachable = $false
                    LatencyMs = $null
                    Error     = $_.Exception.Message
                }
            }
        } -ArgumentList $target
    }

    return $jobsByAddress
}

function Start-AsyncPortJobs {
    param(
        $TargetHosts,
        [int]$TimeoutMs
    )

    $jobsByAddress = @{}
    foreach ($target in @($TargetHosts)) {
        $jobsByAddress[$target.address] = Start-Job -Name ("ports-{0}" -f $target.address.Replace('.', '-')) -ScriptBlock {
            param($Target, $PortTimeoutMs)

            $openPorts = @()
            foreach ($port in @($Target.ports)) {
                try {
                    $client = New-Object Net.Sockets.TcpClient
                    $iar = $client.BeginConnect($Target.address, [int]$port, $null, $null)
                    if ($iar.AsyncWaitHandle.WaitOne([int]$PortTimeoutMs)) {
                        $client.EndConnect($iar) | Out-Null
                        $openPorts += [int]$port
                    }
                    $client.Close()
                }
                catch {
                    # Ignore per-port failures and continue scanning.
                }
            }

            [pscustomobject]@{
                Address   = $Target.address
                OpenPorts = @($openPorts | Sort-Object -Unique)
                Error     = '-'
            }
        } -ArgumentList $target, $TimeoutMs
    }

    return $jobsByAddress
}

function Wait-AsyncJobs {
    param(
        [hashtable]$JobsByAddress,
        [string]$Activity,
        [int]$TimeoutSeconds = 10
    )

    if (-not $JobsByAddress -or $JobsByAddress.Count -eq 0) {
        return
    }

    $jobs = @($JobsByAddress.Values)
    $total = $jobs.Count
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)

    while ((Get-Date) -lt $deadline) {
        $completed = @($jobs | Where-Object { $_.State -match 'Completed|Failed|Stopped' }).Count
        $percent = if ($total -gt 0) { [int](($completed / $total) * 100) } else { 100 }
        Write-Progress -Activity $Activity -Status ("Completed {0}/{1}" -f $completed, $total) -PercentComplete $percent

        if ($completed -ge $total) {
            break
        }

        Wait-Job -Job $jobs -Any -Timeout 1 | Out-Null
    }

    Write-Progress -Activity $Activity -Completed
}

function Receive-AsyncJobResults {
    param(
        [hashtable]$JobsByAddress,
        [string]$Activity,
        [scriptblock]$FallbackFactory,
        [int]$TimeoutSeconds = 10
    )

    $results = @{}
    if (-not $JobsByAddress -or $JobsByAddress.Count -eq 0) {
        return $results
    }

    Wait-AsyncJobs -JobsByAddress $JobsByAddress -Activity $Activity -TimeoutSeconds $TimeoutSeconds

    foreach ($entry in $JobsByAddress.GetEnumerator()) {
        $address = $entry.Key
        $job = $entry.Value

        try {
            if ($job.State -eq 'Completed') {
                $payload = Receive-Job -Job $job -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($payload) {
                    $results[$address] = $payload
                }
                else {
                    $results[$address] = & $FallbackFactory $address 'no result'
                }
            }
            else {
                $results[$address] = & $FallbackFactory $address 'timeout'
            }
        }
        finally {
            Stop-Job -Job $job -ErrorAction SilentlyContinue | Out-Null
            Remove-Job -Job $job -Force -ErrorAction SilentlyContinue | Out-Null
        }
    }

    return $results
}

function Ensure-DirectoryForFile {
    param([string]$FilePath)

    $directory = Split-Path -Path $FilePath -Parent
    if ($directory -and -not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
}

function Save-JsonFile {
    param(
        [string]$Path,
        $Payload
    )

    Ensure-DirectoryForFile -FilePath $Path
    $Payload | ConvertTo-Json -Depth 10 | Set-Content -Path $Path -Encoding UTF8
}

$config = Read-NetworkAuditConfig -Path $ConfigPath
$defaultPorts = @($config.defaultPorts | ForEach-Object { [int]$_ })
$tcpTimeoutMs = if ($config.probe.tcpTimeoutMs) { [int]$config.probe.tcpTimeoutMs } else { 300 }

$targets = foreach ($hostEntry in @($config.hosts)) {
    $hostPorts = if ($hostEntry.ports -and @($hostEntry.ports).Count -gt 0) {
        @($hostEntry.ports | ForEach-Object { [int]$_ })
    }
    else {
        @($defaultPorts)
    }

    [pscustomobject]@{
        name         = [string]$hostEntry.name
        address      = [string]$hostEntry.address
        expectedRole = if ($hostEntry.expectedRole) { [string]$hostEntry.expectedRole } else { '-' }
        tags         = @($hostEntry.tags)
        ports        = @($hostPorts | Sort-Object -Unique)
    }
}

Write-Host "=== Network Audit Example ==="
Write-Host ("Profile: {0}" -f $(if ($config.profileName) { $config.profileName } else { 'default' }))
Write-Host ("Targets: {0}" -f $targets.Count)

$pingJobsByAddress = Start-AsyncPingJobs -TargetHosts $targets
$portJobsByAddress = Start-AsyncPortJobs -TargetHosts $targets -TimeoutMs $tcpTimeoutMs

$pingResults = Receive-AsyncJobResults -JobsByAddress $pingJobsByAddress -Activity 'ICMP probe progress' -TimeoutSeconds 8 -FallbackFactory {
    param($Address, $Reason)
    [pscustomobject]@{
        Address   = $Address
        Reachable = $false
        LatencyMs = $null
        Error     = $Reason
    }
}

$portTimeoutSeconds = [math]::Max(8, [math]::Ceiling(($targets.Count * 0.4) + 3))
$portResults = Receive-AsyncJobResults -JobsByAddress $portJobsByAddress -Activity 'TCP probe progress' -TimeoutSeconds $portTimeoutSeconds -FallbackFactory {
    param($Address, $Reason)
    [pscustomobject]@{
        Address   = $Address
        OpenPorts = @()
        Error     = $Reason
    }
}

$results = foreach ($target in $targets) {
    $ping = $pingResults[$target.address]
    $port = $portResults[$target.address]

    [pscustomobject]@{
        Name         = $target.name
        Address      = $target.address
        ExpectedRole = $target.expectedRole
        Ping         = if ($ping -and $ping.Reachable) { 'up' } else { 'down' }
        LatencyMs    = if ($ping -and $ping.Reachable -and $null -ne $ping.LatencyMs) { $ping.LatencyMs } else { '-' }
        OpenPorts    = if ($port -and @($port.OpenPorts).Count -gt 0) { @($port.OpenPorts) -join ',' } else { '-' }
        Tags         = if (@($target.tags).Count -gt 0) { @($target.tags) -join ',' } else { '-' }
    }
}

$results | Format-Table -AutoSize

$capturedAtUtc = [DateTime]::UtcNow.ToString('o')
$snapshotPayload = [pscustomobject]@{
    capturedAtUtc = $capturedAtUtc
    profileName   = if ($config.profileName) { $config.profileName } else { 'default' }
    results       = @($results)
}

$resolvedSnapshotPath = if ($PSBoundParameters.ContainsKey('SnapshotPath')) {
    Resolve-RepoRelativePath -Path $SnapshotPath
}
elseif ($config.outputs.writeSnapshot -and $config.outputs.snapshotPath) {
    Resolve-RepoRelativePath -Path ([string]$config.outputs.snapshotPath)
}
else {
    $null
}

if ($resolvedSnapshotPath) {
    Save-JsonFile -Path $resolvedSnapshotPath -Payload $snapshotPayload
    if (-not $Quiet) {
        Write-Host ("Snapshot saved to {0}" -f $resolvedSnapshotPath)
    }
}

$resolvedHistoryPath = if ($PSBoundParameters.ContainsKey('HistoryPath')) {
    Resolve-RepoRelativePath -Path $HistoryPath
}
elseif ($config.outputs.writeHistory -and $config.outputs.historyPath) {
    Resolve-RepoRelativePath -Path ([string]$config.outputs.historyPath)
}
else {
    $null
}

if ($resolvedHistoryPath) {
    $history = @()
    if (Test-Path $resolvedHistoryPath) {
        $existing = Get-Content -Path $resolvedHistoryPath -Raw | ConvertFrom-Json -Depth 10
        if ($existing) {
            $history = @($existing)
        }
    }

    $history += [pscustomobject]@{
        capturedAtUtc = $capturedAtUtc
        profileName   = $snapshotPayload.profileName
        results       = @($results)
    }

    Save-JsonFile -Path $resolvedHistoryPath -Payload @($history)
    if (-not $Quiet) {
        Write-Host ("History updated: {0}" -f $resolvedHistoryPath)
    }
}