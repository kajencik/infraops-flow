# Repo Rename And Workspace Sync

## Goal

Provide a repeatable, low-risk workflow to align repository rename changes across multiple machines, including local folder names, VS Code workspace files, and git remote URLs.

## When to use this runbook

Use this when a repository slug or folder name changes and you already have clones/workspaces on multiple machines.

Typical examples:

- branding rename
- slug normalization
- moving from an old project name to a new one

## Scope

This runbook covers:

- building a portable rename bundle from one machine
- syncing that bundle through a shared sync folder
- applying rename updates automatically on target machines

This runbook does not cover:

- GitHub web UI repository rename itself
- CI/CD secret updates in external systems
- downstream links in third-party tools

## Required scripts

- scripts/sync-repo-rename-workspace.ps1
- scripts/apply-repo-rename-workspace.ps1

## Example mapping

- old name: codex-hermes
- new name: infraops-flow

Replace these names with your own values when needed.

## Workflow

### 1. Source machine: create rename bundle

Run from repository root:

powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\sync-repo-rename-workspace.ps1 -OldRepoName codex-hermes -NewRepoName infraops-flow -SyncRoot "$env:USERPROFILE\OneDrive\VSCode\sync"

Expected output:

- a timestamped bundle under your sync root
- workspaces/original and workspaces/patched copies
- rename-sync-manifest.json
- apply-on-target-machine.txt
- scripts/apply-repo-rename-workspace.ps1 (copied into the bundle)
- scripts/sync-repo-rename-workspace.ps1 (copied into the bundle)

### 2. Wait for sync

Let your sync provider finish uploading the bundle before moving to target machines.

### 3. Target machine: dry run first

Run from inside the synced bundle folder:

powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\apply-repo-rename-workspace.ps1 -BundlePath .

Review the WhatIf output and confirm:

- expected repo folder rename paths
- expected workspace file replacements
- expected origin URL updates

### 4. Target machine: execute

Run from inside the synced bundle folder:

powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\apply-repo-rename-workspace.ps1 -BundlePath . -Execute -GitHubOwner kajencik

Notes:

- GitHub owner is optional if origin URLs already allow inference.
- You can skip specific actions with:
  - -SkipRepoRename
  - -SkipWorkspaceUpdate
  - -SkipGitRemoteUpdate

### 5. Post-apply verification

Run these checks on each target machine:

- git -C <path-to-renamed-repo> remote -v
- git -C <path-to-renamed-repo> status
- open your .code-workspace file in VS Code and verify folders resolve

## Rollback approach

If workspace updates are wrong for a machine, restore from:

- bundle path: workspaces/original

If repo rename was not desired in one path:

- rename folder back manually
- rerun apply script with -SkipRepoRename and only the needed operations

## Good operating pattern

- always run dry mode first
- apply on one secondary machine before applying to all machines
- keep the bundle for at least one full validation cycle
- commit documentation updates in the repo after the rename settles
