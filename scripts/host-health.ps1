<#
.SYNOPSIS
Collects a quick read-only health snapshot from a Windows host.

.DESCRIPTION
Produces a compact operator-facing report covering basic system identity,
processor details, BIOS version, disk inventory, storage health, recent
storage-related events, and optional SMART health summaries when
smartctl.exe is available.

This script is intentionally read-only.

.PARAMETER StorageEventLookbackDays
How many days of storage-related System log events to inspect.

.PARAMETER OutputPath
Optional path to save the full report as plain text.

.PARAMETER Quiet
Suppresses the final "report saved" message when OutputPath is used.

.PARAMETER IncludeSerialNumbers
Includes disk serial numbers in the disk inventory section.

.PARAMETER SkipSmartCtl
Skips smartctl probing even if smartctl.exe is installed.

.EXAMPLE
./host-health.ps1

.EXAMPLE
./host-health.ps1 -StorageEventLookbackDays 14 -OutputPath .\host-health.txt
#>

[CmdletBinding()]
param(
    [ValidateRange(1, 365)]
    [int]$StorageEventLookbackDays = 30,
    [string]$OutputPath,
    [switch]$Quiet,
    [switch]$IncludeSerialNumbers,
    [switch]$SkipSmartCtl
)

$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'

$reportLines = New-Object System.Collections.Generic.List[string]

function Add-ReportLine {
    param([string]$Line = '')

    Write-Host $Line
    $reportLines.Add($Line) | Out-Null
}

function Add-ReportBlock {
    param([string[]]$Lines)

    foreach ($line in @($Lines)) {
        Add-ReportLine $line
    }
}

function Add-Section {
    param(
        [string]$Title,
        [scriptblock]$Body
    )

    Add-ReportLine ("=== {0} ===" -f $Title)

    try {
        & $Body
    }
    catch {
        Add-ReportLine ("Unable to collect section '{0}': {1}" -f $Title, $_.Exception.Message)
    }

    Add-ReportLine ''
}

function Format-ObjectLines {
    param(
        $InputObject,
        [ValidateSet('List', 'Table')]
        [string]$Mode = 'List'
    )

    if ($null -eq $InputObject) {
        return @('No data returned.')
    }

    $formatted = if ($Mode -eq 'Table') {
        $InputObject | Format-Table -AutoSize | Out-String -Width 220
    }
    else {
        $InputObject | Format-List | Out-String -Width 220
    }

    return @($formatted -split "`r?`n")
}

function Get-SmartCtlCommand {
    $smartctl = Get-Command smartctl.exe -ErrorAction SilentlyContinue
    if (-not $smartctl) {
        $smartctl = Get-Command smartctl -ErrorAction SilentlyContinue
    }

    return $smartctl
}

Add-Section -Title 'Computer System' -Body {
    $system = Get-CimInstance Win32_ComputerSystem |
        Select-Object Manufacturer, Model, @{N = 'RAM_GB'; E = { [math]::Round($_.TotalPhysicalMemory / 1GB, 1) }}

    Add-ReportBlock (Format-ObjectLines -InputObject $system -Mode List)
}

Add-Section -Title 'CPU' -Body {
    $cpu = Get-CimInstance Win32_Processor |
        Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed

    Add-ReportBlock (Format-ObjectLines -InputObject $cpu -Mode List)
}

Add-Section -Title 'BIOS' -Body {
    $bios = Get-CimInstance Win32_BIOS |
        Select-Object SMBIOSBIOSVersion, ReleaseDate, Manufacturer

    Add-ReportBlock (Format-ObjectLines -InputObject $bios -Mode List)
}

Add-Section -Title 'Disk Drives' -Body {
    $selectedProperties = @(
        'Model',
        'InterfaceType',
        @{N = 'SizeGB'; E = { [math]::Round($_.Size / 1GB, 1) }},
        'Status'
    )

    if ($IncludeSerialNumbers) {
        $selectedProperties += 'SerialNumber'
    }

    $diskDrives = Get-CimInstance Win32_DiskDrive | Select-Object $selectedProperties
    Add-ReportBlock (Format-ObjectLines -InputObject $diskDrives -Mode Table)
}

Add-Section -Title 'Storage Health' -Body {
    $physicalDisks = Get-PhysicalDisk
    if (-not $physicalDisks) {
        Add-ReportLine 'No physical disk data returned by Get-PhysicalDisk.'
        return
    }

    $storageHealth = $physicalDisks |
        Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus, @{N = 'SizeGB'; E = { [math]::Round($_.Size / 1GB, 1) }}

    Add-ReportBlock (Format-ObjectLines -InputObject $storageHealth -Mode Table)
}

Add-Section -Title ("Recent Storage Events ({0} days)" -f $StorageEventLookbackDays) -Body {
    $eventFilter = @{
        LogName   = 'System'
        StartTime = (Get-Date).AddDays(-$StorageEventLookbackDays)
    }

    $recentEvents = Get-WinEvent -FilterHashtable $eventFilter |
        Where-Object { $_.ProviderName -match 'disk|stornvme|storahci|Ntfs' -or $_.Id -in 7, 11, 15, 51, 55, 129, 153, 157 } |
        Select-Object -First 20 TimeCreated, ProviderName, Id, LevelDisplayName

    if (-not $recentEvents) {
        Add-ReportLine 'No obvious storage-failure events in the selected lookback window.'
        return
    }

    Add-ReportBlock (Format-ObjectLines -InputObject $recentEvents -Mode Table)
}

Add-Section -Title 'SMART Summary' -Body {
    if ($SkipSmartCtl) {
        Add-ReportLine 'smartctl probing skipped by request.'
        return
    }

    $smartctl = Get-SmartCtlCommand
    if (-not $smartctl) {
        Add-ReportLine 'smartctl.exe not found; install smartmontools for deeper disk checks.'
        return
    }

    $devices = @(& $smartctl.Source --scan-open 2>$null | ForEach-Object { ($_ -split ' ')[0] } | Where-Object { $_ })
    if ($devices.Count -eq 0) {
        Add-ReportLine 'smartctl is available, but no devices were returned by --scan-open.'
        return
    }

    foreach ($device in $devices) {
        Add-ReportLine ("# {0}" -f $device)
        $summary = @(& $smartctl.Source -H $device 2>$null | Select-String 'SMART overall-health|SMART Health Status|PASSED|FAILED|OK' | ForEach-Object { $_.ToString().Trim() })
        if ($summary.Count -eq 0) {
            Add-ReportLine 'No concise SMART health line returned.'
            continue
        }

        Add-ReportBlock $summary
    }
}

if ($OutputPath) {
    $outputDirectory = Split-Path -Path $OutputPath -Parent
    if ($outputDirectory -and -not (Test-Path $outputDirectory)) {
        New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
    }

    $reportLines | Set-Content -Path $OutputPath -Encoding UTF8
    if (-not $Quiet) {
        Write-Host ("Report saved to {0}" -f $OutputPath)
    }
}