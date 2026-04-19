# Codex Hermes

An LLM-assisted operations notebook for human operators.

## What This Is

Codex Hermes is an operations notebook framework for people who still like knowing what their infrastructure is doing.

It combines:

- structured inventories
- session handoff notes
- reusable runbooks
- example data files
- small helper scripts

The goal is simple: keep context, evidence, and repeatable workflows in one place without pretending a pile of YAML, shell history, and optimism is the same thing as operations discipline.

## Design Principles

- Human operator stays in control.
- LLM assistance is useful, but bounded.
- Framework and instance data should not be tangled together.
- Markdown and machine-readable files complement each other.
- Safe templates are first-class, not afterthoughts.

## Repository Layout

- `config/` — where knobs, paths, and secret references learn some manners
- `inventory/` — the cast list: hosts, networks, shares, and other named troublemakers
- `data/` — machine-readable glue for checks, indexes, and lightweight automation
- `notes/` — session continuity, project notes, and operator memory with better structure than sticky notes
- `scripts/` — small tools for read-heavy operational work and carefully explicit write actions
- `monitoring-container/` — container packaging for people who want scheduled checks without turning the repo into a platform religion
- `.vscode/` — optional tasks and editor support for the people living in VS Code all day anyway

## Quick Start

1. Copy the `*.example.json` files into instance-specific files.
2. Fill in your own environment values locally.
3. Use `SESSION-HANDOFF.template.md` and the `notes/` templates to shape your working style.
4. Add real checks, scripts, and inventories once the structure fits how you actually operate.

## Scope

This repo is the framework, not your entire living environment frozen in Git.

Treat it as the reusable layer: the part worth keeping tidy enough that another operator could read it without needing a guided tour of your network closet.