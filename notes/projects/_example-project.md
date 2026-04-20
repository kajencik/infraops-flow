# Example Project

## Goal

Move backups and operational exports away from ad hoc paths on the operator workstation and onto `nas-1`, so the environment has one predictable storage target instead of accumulated convenience decisions.

This is not just file reordering. It is a priority correction: stop spending effort on the most visible mess first and start with the things that matter for restore confidence and operational trust.

## Current Status

- `nas-1` is reachable and the intended share path exists.
- One legacy export still points at a local desktop path, which makes restore assumptions harder to trust.

This is a small example of the wider pattern in the repo: once the important path is visible, the work gets shorter, less emotional, and easier to script.

## Evidence

- Recent session check confirmed `nas-1` is online and reachable from `ops-laptop`.
- One export task still references the old path and needs to be moved deliberately, not by wishful thinking.

## Next Actions

1. Inventory every current backup and export target.
2. Move the remaining legacy export to `\\nas-1\\ops-backups`.
3. Run one verification cycle and confirm the new target contains the expected files.
4. Retire the old path only after the new target is proven.