# Codex Hermes

An LLM-assisted operations notebook for human operators.

## What This Is

Codex Hermes is a public-safe framework for running an operations notebook with:

- structured inventories
- session handoff notes
- reusable runbooks
- example data files
- small helper scripts

The goal is to help operators keep context, evidence, and repeatable workflows in one place without pretending the system should run unattended.

## Design Principles

- Human operator stays in control.
- LLM assistance is useful, but bounded.
- Real environment data stays separate from the framework.
- Markdown and machine-readable files complement each other.
- Safe templates are first-class, not afterthoughts.

## Repository Layout

- `config/` — example config and secret metadata templates
- `inventory/` — example inventory schemas and sample data
- `data/` — reusable structured companion data
- `notes/` — session and project note templates
- `scripts/` — helper script conventions and future public-safe utilities
- `monitoring-container/` — placeholder area for containerized monitoring examples
- `.vscode/` — optional workspace tasks and editor defaults

## Quick Start

1. Copy the `*.example.json` files into instance-specific files.
2. Fill in your own environment values locally.
3. Keep real secrets, live inventories, and dated private sessions out of the public repo.
4. Use `SESSION-HANDOFF.template.md` and the `notes/` templates to shape your working style.

## Scope

This repo is the framework, not the live instance.

It is meant to be paired with a private operations repo where real inventories, real notes, live logs, and sensitive environment details are kept.