---
description: "Use when editing PowerShell helpers under scripts/ in codex-hermes."
applyTo: "scripts/**/*.ps1"
---

# PowerShell Scripts Instructions

- Default scripts to read-only and diagnostic behavior unless a write action is explicitly requested and documented.
- Keep targets, ports, and output paths configurable via parameters or config files; avoid hardcoded private values.
- Preserve human-readable output and JSON output contracts unless consumers are updated in the same change.
- Ensure example scripts remain runnable in a generic environment with repository example configs.
- Keep helper functions composable and explicit; avoid hidden side effects.
- Validate touched scripts by running them from repo root with default/example parameters.
