# Codex Hermes

An LLM-assisted operations notebook for (mostly) human operators. Recommended usecase is to be extremely lazy and not to read anything below, just ask your favorite LLM to summarize and continue in the direction of this repo. It needs to be able to browse and expand the whole repository, like Github copilot does, copy and past approach most likely won't work.

## What This Is

Codex Hermes is an operations notebook for the operator who started with remembered IPs, half-finished migrations, old forum tabs, and a strong belief that the documentation cleanup would happen later.

It is built around a simple story:

- one operator
- one small mixed environment
- a few recurring checks
- a few active projects
- a shift from improvised memory to deliberate, script-assisted operations

The point is not to build an autonomous empire. The point is to spend less human time on re-finding facts, re-running boring checks, and re-learning last week's context.

The human should spend time on judgment, priorities, tradeoffs, and risky decisions.
The LLM should spend time on the boring parts: organizing notes, updating structured files, drafting runbooks, and carrying context across sessions.

This repo shows how to move from "I think I know how this works" to "I can stop for a week, come back, and still know what is true."

## Design Principles

- Human is the captain, LLM is the hands on keyboard.
- LLM assistance is useful, but bounded.
- Framework and instance data should not be tangled together.
- Markdown and machine-readable files complement each other.
- Safe templates are first-class, not afterthoughts.
- Good operations depend on known state, not folklore.
- The system should reduce operator drag, not create a second job in documentation.

## The Sample Environment

The example files in this repo describe one small environment:

- `edge-router` keeps the main LAN honest
- `mini-pc-1` runs the main virtual workloads
- `nas-1` holds backups and shared storage
- `ap-1` handles wireless access
- `home-automation-1` is the little box everyone forgets until it goes offline
- `ops-laptop` is where the operator actually does the work

The cloud examples add one more layer: not just servers, but also what runs on them and what depends on what.

The operator did not begin with a beautiful system. They began with:

- device names scattered across notes and terminal history
- backup jobs that mostly worked, until they did not
- maintenance tasks remembered by mood rather than by cadence
- changes that were obvious at the time and mysterious two weeks later

Two example story lines matter here:

- networking changes that once took a week of scattered checking can be prepared and driven in a day once the state, runbook, and validation path are explicit
- workstation file cleanup that once felt like random reordering turns into a priority decision once the operator separates what is merely messy from what is actually important

Codex Hermes is the version after that operator got tired of operating by folklore, noise, and half-visible traces.

## Repository Layout

- `config/` — where knobs, paths, and secret references learn some manners
- `inventory/` — the cast list for the sample environment: hosts, networks, shares, and the other named troublemakers
- `data/` — recurring checks and project indexes, so the operator stops relying on vibes and starts seeing drift sooner
- `notes/` — session continuity, project notes, and the paper trail of how the environment became more legible
- `scripts/` — small tools for read-heavy operational work and carefully explicit write actions
- `terraform-example/` — provider-neutral Terraform scaffold for generic cloud utility-node and network-appliance planning
- `monitoring-container/` — container packaging for people who want scheduled checks without turning the repo into a platform religion
- `.vscode/` — optional tasks and editor support for the people living in VS Code all day anyway

The same structure can also carry a small cloud/Terraform direction: cloud assets in inventory, recurring validation in data/scripts, and project notes that explain why the infrastructure exists and how it should be changed.

## Quick Start

1. Copy the `*.example.json` files into instance-specific files.
2. Read the sample environment files as one joined-up story, not as isolated examples.
3. Use `SESSION-HANDOFF.template.md` and the `notes/` templates to shape your own working style.
4. Replace the dummy environment with your own once the structure feels useful rather than decorative.

## What To Read First

If you want the shortest path to understanding the repo, follow this order:

1. `inventory/devices.example.json`
2. `inventory/service-topology.example.json`
3. `data/recurring-checks.json`
4. `notes/_example-session.md`
5. `notes/projects/_example-project.md`
6. `scripts/host-health.ps1`
7. `scripts/network-audit-example.ps1`

That path shows the real point of the repo: inventory, recurring checks, active work, session continuity, and a few small tools to separate signal from noise.

## Scope

This repo is the framework, not your entire living environment frozen in Git.

Treat it as the reusable layer: the part worth keeping tidy enough that another operator could read it without needing a guided tour of your network closet.

If it is working properly, the repo does three things:

- reduces the amount of boring work the human has to repeat
- makes interruptions less expensive
- lets the operator spend more time on productive changes than on reconstruction of context