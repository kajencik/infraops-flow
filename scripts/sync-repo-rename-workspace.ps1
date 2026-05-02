<#
.SYNOPSIS
Builds a portable rename/workspace sync bundle for multi-machine repo alignment.

.DESCRIPTION
Scans configured workspace roots for `.code-workspace` files, creates patched copies
that replace the old repository name with the new one, and writes a small manifest
plus machine-agnostic rename guidance into a timestamped folder under a sync root.

The script is intentionally non-destructive: it does not rename folders, edit local
workspace files in place, or change git remotes. It prepares a bundle that can be
synced (for example via OneDrive) and applied on other machines.

.PARAMETER OldRepoName
Previous repository folder/slug name.

.PARAMETER NewRepoName
New repository folder/slug name.

.PARAMETER SyncRoot
Root folder used to store generated bundles.

.PARAMETER BundleName
Prefix for the generated bundle folder.

.PARAMETER WorkspaceSearchRoots
Roots to scan recursively for `.code-workspace` files.

.PARAMETER RepoSearchRoots
Candidate parent folders that may contain old/new repo folders.

.PARAMETER Force
Overwrite an existing bundle path if the same timestamped folder already exists.

.EXAMPLE
./scripts/sync-repo-rename-workspace.ps1

.EXAMPLE
./scripts/sync-repo-rename-workspace.ps1 -OldRepoName codex-hermes -NewRepoName infraops-flow -SyncRoot "$env:USERPROFILE\OneDrive\VSCode\sync"
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateNotNullOrEmpty()]
    [string]$OldRepoName = 'codex-hermes',

    [ValidateNotNullOrEmpty()]
    [string]$NewRepoName = 'infraops-flow',

    [ValidateNotNullOrEmpty()]
    [string]$SyncRoot = (Join-Path $env:USERPROFILE 'OneDrive\VSCode\sync'),

    [ValidateNotNullOrEmpty()]
    [string]$BundleName = 'repo-rename-sync',

    [string[]]$WorkspaceSearchRoots = @(
        (Join-Path $env:USERPROFILE 'OneDrive\VSCode\workspaces'),
        (Join-Path $env:USERPROFILE 'Documents\VSCode\workspaces')
    ),

    [string[]]$RepoSearchRoots = @(
        (Join-Path $env:USERPROFILE 'source\repos'),
        (Join-Path $env:USERPROFILE 'OneDrive\source\repos'),
        (Join-Path $env:USERPROFILE 'Documents\repos')
    ),

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Step {
    param([string]$Message)
    Write-Host "[+] $Message" -ForegroundColor Cyan
}

function Ensure-Directory {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Get-ExistingPaths {
    param([string[]]$Paths)

    foreach ($path in @($Paths)) {
        if ([string]::IsNullOrWhiteSpace($path)) {
            continue
        }

        if (Test-Path -LiteralPath $path) {
            [System.IO.Path]::GetFullPath($path)
        }
    }
}

function Normalize-WorkspaceRelativePath {
    param(
        [string]$RelativePath,
        [string]$RootLeaf
    )

    if ([string]::IsNullOrWhiteSpace($RelativePath)) {
        return $RelativePath
    }

    $normalized = ($RelativePath -replace '\\', '/')
    if ([string]::IsNullOrWhiteSpace($RootLeaf)) {
        return $normalized
    }

    $prefix = "$RootLeaf/"
    while ($normalized.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        $normalized = $normalized.Substring($prefix.Length)
    }

    return $normalized
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$bundleDir = Join-Path ([System.IO.Path]::GetFullPath($SyncRoot)) ("{0}-{1}" -f $BundleName, $timestamp)
$workspaceOutRoot = Join-Path $bundleDir 'workspaces'
$workspaceOriginalRoot = Join-Path $workspaceOutRoot 'original'
$workspacePatchedRoot = Join-Path $workspaceOutRoot 'patched'
$bundleScriptsRoot = Join-Path $bundleDir 'scripts'
$guidancePath = Join-Path $bundleDir 'apply-on-target-machine.txt'
$manifestPath = Join-Path $bundleDir 'rename-sync-manifest.json'

if ((Test-Path -LiteralPath $bundleDir) -and -not $Force) {
    throw "Bundle already exists: $bundleDir. Re-run with -Force if you want to overwrite it."
}

$existingWorkspaceRoots = @(Get-ExistingPaths -Paths $WorkspaceSearchRoots)
$existingRepoRoots = @(Get-ExistingPaths -Paths $RepoSearchRoots)

$workspaceFiles = @()
foreach ($root in $existingWorkspaceRoots) {
    $workspaceFiles += Get-ChildItem -Path $root -Filter '*.code-workspace' -File -Recurse -ErrorAction SilentlyContinue
}

$workspaceFiles = $workspaceFiles | Sort-Object -Property FullName -Unique

$workspaceReport = New-Object System.Collections.Generic.List[object]

if ($PSCmdlet.ShouldProcess($bundleDir, 'Create rename sync bundle')) {
    Ensure-Directory -Path $workspaceOriginalRoot
    Ensure-Directory -Path $workspacePatchedRoot
    Ensure-Directory -Path $bundleScriptsRoot

    $scriptSourceRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    $applyScriptSource = Join-Path $scriptSourceRoot 'apply-repo-rename-workspace.ps1'
    $syncScriptSource = Join-Path $scriptSourceRoot 'sync-repo-rename-workspace.ps1'

    $copiedBundleScripts = New-Object System.Collections.Generic.List[string]
    foreach ($scriptPath in @($applyScriptSource, $syncScriptSource)) {
        if (-not (Test-Path -LiteralPath $scriptPath)) {
            continue
        }

        $destination = Join-Path $bundleScriptsRoot (Split-Path -Leaf $scriptPath)
        Copy-Item -LiteralPath $scriptPath -Destination $destination -Force
        $copiedBundleScripts.Add($destination) | Out-Null
    }

    Write-Step "Scanning $($workspaceFiles.Count) workspace file(s)"

    foreach ($file in $workspaceFiles) {
        $rootMatch = $existingWorkspaceRoots | Where-Object { $file.FullName.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase) } | Select-Object -First 1
        $relativePath = if ($rootMatch) {
            $file.FullName.Substring($rootMatch.Length).TrimStart('\')
        } else {
            Split-Path -Leaf $file.FullName
        }

        $safeRootName = if ($rootMatch) { (Split-Path -Leaf $rootMatch) } else { 'workspace-root' }
        $relativePath = Normalize-WorkspaceRelativePath -RelativePath $relativePath -RootLeaf $safeRootName
        $originalDestination = Join-Path (Join-Path $workspaceOriginalRoot $safeRootName) $relativePath
        $patchedDestination = Join-Path (Join-Path $workspacePatchedRoot $safeRootName) $relativePath

        Ensure-Directory -Path (Split-Path -Parent $originalDestination)
        Ensure-Directory -Path (Split-Path -Parent $patchedDestination)

        $raw = Get-Content -LiteralPath $file.FullName -Raw
        $patched = $raw.Replace($OldRepoName, $NewRepoName)
        $changed = $patched -ne $raw

        [System.IO.File]::WriteAllText($originalDestination, $raw, [System.Text.Encoding]::UTF8)
        [System.IO.File]::WriteAllText($patchedDestination, $patched, [System.Text.Encoding]::UTF8)

        $workspaceReport.Add([ordered]@{
            sourcePath = $file.FullName
            root = $rootMatch
            relativePath = $relativePath.Replace('\', '/')
            patchedPath = $patchedDestination
            oldRepoNameFound = $changed
        }) | Out-Null
    }

    $repoReport = foreach ($root in $existingRepoRoots) {
        $oldPath = Join-Path $root $OldRepoName
        $newPath = Join-Path $root $NewRepoName

        [ordered]@{
            repoRoot = $root
            oldRepoPath = $oldPath
            newRepoPath = $newPath
            oldExists = (Test-Path -LiteralPath $oldPath)
            newExists = (Test-Path -LiteralPath $newPath)
        }
    }

    $guidanceLines = @(
        "Rename sync bundle generated: $(Get-Date -Format s)",
        "",
        "Source rename mapping:",
        "- old repo name: $OldRepoName",
        "- new repo name: $NewRepoName",
        "",
        "Bundle includes helper scripts under: scripts/",
        "- apply-repo-rename-workspace.ps1",
        "- sync-repo-rename-workspace.ps1",
        "",
        "Automatic apply option (recommended):",
        "- On the target machine, from inside this bundle run:",
        "  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\\scripts\\apply-repo-rename-workspace.ps1 -BundlePath '$bundleDir' -Execute",
        "",
        "How to apply on another machine:",
        "1. Ensure the repo is cloned/renamed to the new folder name where needed.",
        "2. Run the bundled apply script in dry mode first (omit -Execute).",
        "3. Re-run with -Execute when output looks correct.",
        "4. For each local clone, verify git remote:",
        "   git remote set-url origin https://github.com/<owner>/$NewRepoName.git",
        "5. Reopen VS Code workspace and verify folder paths resolve.",
        "",
        "Notes:",
        "- This bundle is read-only guidance + file copies; it does not change remote machines automatically.",
        "- Original workspace files are preserved under workspaces/original."
    )

    [System.IO.File]::WriteAllLines($guidancePath, $guidanceLines, [System.Text.Encoding]::UTF8)

    $manifest = [ordered]@{
        schemaVersion = 1
        generatedAt = (Get-Date).ToString('o')
        machine = $env:COMPUTERNAME
        oldRepoName = $OldRepoName
        newRepoName = $NewRepoName
        syncRoot = [System.IO.Path]::GetFullPath($SyncRoot)
        bundleDir = $bundleDir
        workspaceSearchRoots = $existingWorkspaceRoots
        repoSearchRoots = $existingRepoRoots
        workspaceFiles = $workspaceReport
        repoFolderStatus = $repoReport
        bundledScripts = $copiedBundleScripts
        guidanceFile = $guidancePath
    }

    $manifestJson = $manifest | ConvertTo-Json -Depth 8
    [System.IO.File]::WriteAllText($manifestPath, $manifestJson + [Environment]::NewLine, [System.Text.Encoding]::UTF8)

    $patchedCount = @($workspaceReport | Where-Object { $_.oldRepoNameFound }).Count
    Write-Host ''
    Write-Host "[OK] Bundle ready: $bundleDir" -ForegroundColor Green
    Write-Host "Workspace files scanned: $($workspaceReport.Count)" -ForegroundColor Green
    Write-Host "Workspace files patched for '$OldRepoName': $patchedCount" -ForegroundColor Green
    Write-Host "Guidance: $guidancePath" -ForegroundColor Green
}
