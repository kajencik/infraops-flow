<#
.SYNOPSIS
Checks a modeled monthly cloud-cost profile from a config file.

.DESCRIPTION
Reads a small JSON profile describing expected monthly cloud costs,
prints a summary by resource and lifecycle, compares the result to an
optional monthly budget, and can write a JSON report for later review.

This script is intentionally provider-neutral. It does not call billing APIs.
It verifies the operator's current cost model so Terraform plans, asset notes,
and recurring checks can all point to the same assumptions.

.PARAMETER ConfigPath
Path to the JSON config file. Defaults to the example config in this repo.

.PARAMETER ReportPath
Optional override for the JSON report output path.

.PARAMETER Quiet
Suppresses the final report-write summary line.

.PARAMETER FailIfOverBudget
Throws an error when the total exceeds the configured monthly budget.

.EXAMPLE
./cloud-cost-check-example.ps1

.EXAMPLE
./cloud-cost-check-example.ps1 -FailIfOverBudget
#>

[CmdletBinding()]
param(
    [string]$ConfigPath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'config\cloud-costs.example.json'),
    [string]$ReportPath,
    [switch]$Quiet,
    [switch]$FailIfOverBudget
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

function New-ParentDirectory {
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

    New-ParentDirectory -FilePath $Path
    $Payload | ConvertTo-Json -Depth 10 | Set-Content -Path $Path -Encoding UTF8
}

function Read-CostConfig {
    param([string]$Path)

    $resolvedPath = Resolve-RepoRelativePath -Path $Path
    if (-not (Test-Path $resolvedPath)) {
        throw "Config file not found: $resolvedPath"
    }

    $config = Get-Content -Path $resolvedPath -Raw | ConvertFrom-Json -Depth 10
    if (-not $config.resources -or @($config.resources).Count -eq 0) {
        throw 'Config file must define at least one resource entry under resources.'
    }

    return $config
}

function ConvertTo-RoundedCurrency {
    param([double]$Value)
    return [math]::Round($Value, 2)
}

$config = Read-CostConfig -Path $ConfigPath
$currency = if ($config.currency) { [string]$config.currency } else { 'EUR' }
$profileName = if ($config.profileName) { [string]$config.profileName } else { 'default' }
$monthlyBudget = if ($null -ne $config.monthlyBudget) { [double]$config.monthlyBudget } else { $null }

$resourceRows = foreach ($resource in @($config.resources)) {
    $quantity = if ($null -ne $resource.quantity) { [double]$resource.quantity } else { 1 }
    $unitMonthlyCost = if ($null -ne $resource.unitMonthlyCost) { [double]$resource.unitMonthlyCost } else { 0 }
    $monthlyCost = ConvertTo-RoundedCurrency ($quantity * $unitMonthlyCost)

    [pscustomobject]@{
        Name            = [string]$resource.name
        Category        = if ($resource.category) { [string]$resource.category } else { '-' }
        Lifecycle       = if ($resource.lifecycle) { [string]$resource.lifecycle } else { 'core' }
        Quantity        = $quantity
        UnitMonthlyCost = ConvertTo-RoundedCurrency $unitMonthlyCost
        MonthlyCost     = $monthlyCost
        Notes           = if ($resource.notes) { [string]$resource.notes } else { '-' }
    }
}

$monthlyTotal = ConvertTo-RoundedCurrency (($resourceRows | Measure-Object -Property MonthlyCost -Sum).Sum)
$annualTotal = ConvertTo-RoundedCurrency ($monthlyTotal * 12)

$lifecycleTotals = @(
    $resourceRows |
        Group-Object Lifecycle |
        Sort-Object Name |
        ForEach-Object {
            [pscustomobject]@{
                Lifecycle   = $_.Name
                MonthlyCost = ConvertTo-RoundedCurrency (($_.Group | Measure-Object -Property MonthlyCost -Sum).Sum)
            }
        }
)

$categoryTotals = @(
    $resourceRows |
        Group-Object Category |
        Sort-Object Name |
        ForEach-Object {
            [pscustomobject]@{
                Category    = $_.Name
                MonthlyCost = ConvertTo-RoundedCurrency (($_.Group | Measure-Object -Property MonthlyCost -Sum).Sum)
            }
        }
)

$budgetStatus = 'no budget configured'
$budgetVariance = $null
if ($null -ne $monthlyBudget) {
    $budgetVariance = ConvertTo-RoundedCurrency ($monthlyBudget - $monthlyTotal)
    if ($monthlyTotal -le $monthlyBudget) {
        $budgetStatus = 'within budget'
    }
    else {
        $budgetStatus = 'over budget'
    }
}

Write-Host '=== Cloud Cost Check Example ==='
Write-Host ("Profile: {0}" -f $profileName)
Write-Host ("Currency: {0}" -f $currency)
Write-Host ("Monthly total: {0} {1}" -f $monthlyTotal, $currency)
Write-Host ("Annualized total: {0} {1}" -f $annualTotal, $currency)
if ($null -ne $monthlyBudget) {
    Write-Host ("Budget: {0} {1} | Status: {2} | Variance: {3} {1}" -f (ConvertTo-RoundedCurrency $monthlyBudget), $currency, $budgetStatus, $budgetVariance)
}

Write-Host "`n=== Resource cost model ==="
$resourceRows | Format-Table -AutoSize

Write-Host "`n=== Monthly total by lifecycle ==="
$lifecycleTotals | Format-Table -AutoSize

Write-Host "`n=== Monthly total by category ==="
$categoryTotals | Format-Table -AutoSize

if ($config.assumptions -and @($config.assumptions).Count -gt 0) {
    Write-Host "`n=== Assumptions ==="
    foreach ($assumption in @($config.assumptions)) {
        Write-Host ("- {0}" -f [string]$assumption)
    }
}

$capturedAtUtc = [DateTime]::UtcNow.ToString('o')
$reportPayload = [pscustomobject]@{
    capturedAtUtc  = $capturedAtUtc
    profileName    = $profileName
    currency       = $currency
    monthlyBudget  = if ($null -ne $monthlyBudget) { ConvertTo-RoundedCurrency $monthlyBudget } else { $null }
    budgetStatus   = $budgetStatus
    budgetVariance = $budgetVariance
    monthlyTotal   = $monthlyTotal
    annualTotal    = $annualTotal
    lifecycleTotals = @($lifecycleTotals)
    categoryTotals  = @($categoryTotals)
    resources       = @($resourceRows)
    assumptions     = @($config.assumptions)
}

$resolvedReportPath = if ($PSBoundParameters.ContainsKey('ReportPath')) {
    Resolve-RepoRelativePath -Path $ReportPath
}
elseif ($config.outputs.writeReport -and $config.outputs.reportPath) {
    Resolve-RepoRelativePath -Path ([string]$config.outputs.reportPath)
}
else {
    $null
}

if ($resolvedReportPath) {
    Save-JsonFile -Path $resolvedReportPath -Payload $reportPayload
    if (-not $Quiet) {
        Write-Host ("Report saved to {0}" -f $resolvedReportPath)
    }
}

if ($FailIfOverBudget -and $budgetStatus -eq 'over budget') {
    throw ("Cloud cost model exceeds budget by {0} {1}." -f [math]::Abs($budgetVariance), $currency)
}