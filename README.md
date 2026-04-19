# Codex Hermes

An LLM-assisted operations notebook for human operators.

## What This Is

Codex Hermes is an operations notebook for the operator who started with a pile of remembered IPs, half-finished migrations, old forum tabs, weak signals, and a strong belief that they would document it properly later.

The public repo is built around a dummy environment and a very ordinary story:

- one operator
- a small mixed homelab
- a few recurring checks
- a few active projects
- a transition from improvised notes to controlled, productive chaos

It combines:

- structured inventories
- session handoff notes
- reusable runbooks
- example data files
- small helper scripts

The goal is simple: show how an operator can move from "I know roughly how this works" to "I can stop for a week, come back, follow the traces, and still know what is true."

## Design Principles

- Human is the captain, LLM is the hands on keyboard.
- LLM assistance is useful, but bounded.
- Framework and instance data should not be tangled together.
- Markdown and machine-readable files complement each other.
- Safe templates are first-class, not afterthoughts.
- Good operations depend on known state, not folklore.

## The Sample Environment

The example files in this repo all describe the same small environment:

- `edge-router` keeps the main LAN honest
- `mini-pc-1` runs the main virtual workloads
- `nas-1` holds backups and shared storage
- `ap-1` handles wireless access
- `home-automation-1` is the little box everyone forgets until it goes offline
- `ops-laptop` is where the operator actually does the work

The operator did not begin with a beautiful system.

They began with:

- device names scattered across notes and terminal history
- backup jobs that mostly worked, until they did not
- maintenance tasks remembered by mood rather than by cadence
- changes that were obvious at the time and mysterious two weeks later

Codex Hermes is the version after that operator got tired of operating by folklore, noise, and half-visible traces.

## Repository Layout

- `config/` — where knobs, paths, and secret references learn some manners
- `inventory/` — the cast list for the sample environment: hosts, networks, shares, and the other named troublemakers
- `data/` — recurring checks and project indexes for that same environment, so the operator stops relying on vibes and starts seeing drift sooner
- `notes/` — session continuity, project notes, and the paper trail showing how the environment became less improvised and more legible
- `scripts/` — small tools for read-heavy operational work and carefully explicit write actions
- `monitoring-container/` — container packaging for people who want scheduled checks without turning the repo into a platform religion
- `.vscode/` — optional tasks and editor support for the people living in VS Code all day anyway

## Quick Start

1. Copy the `*.example.json` files into instance-specific files.
2. Read the sample environment files as one joined-up story, not as isolated examples.
3. Use `SESSION-HANDOFF.template.md` and the `notes/` templates to shape your own working style.
4. Replace the dummy environment with your own once the structure feels useful rather than decorative.

## What To Read First

If you want the shortest path to understanding the repo, follow this order:

1. `inventory/devices.example.json`
2. `data/recurring-checks.json`
3. `notes/_example-session.md`
4. `notes/projects/_example-project.md`
5. `scripts/host-health.ps1`

That path shows the real point of the repo: inventory, recurring checks, active work, session continuity, and a few small tools to separate signal from noise.

## Scope

This repo is the framework, not your entire living environment frozen in Git.

Treat it as the reusable layer: the part worth keeping tidy enough that another operator could read it without needing a guided tour of your network closet.