# Session Handoff

## Current Status

- What is currently true in the environment?
- What was last verified by an actual check?
- What is still assumed, inherited, or suspiciously under-documented?

The point of this file is to make the next session start from known state instead of vague memory.

## Verified Findings

- Record evidence-backed findings here.
- Prefer exact paths, commands, versions, or timestamps when useful.

Treat this as the signal section, not the speculation section.

## Open Questions

- What still needs investigation?
- What is blocked on operator input or environment access?

## Default Restart Path

1. Read this file.
2. Read the relevant project note under `notes/projects/`.
3. Continue from the last verified checkpoint.

## Example Use

- `edge-router` reachable and still owns the main LAN gateway.
- `nas-1` share path verified.
- one backup task still points to an older workstation path and needs cleanup.