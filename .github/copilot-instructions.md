# GitHub Copilot Instructions

This repository is a reusable operations-notebook framework. It is template-first and public-safe by default, with example data and scripts meant to be adapted to real environments.

## Start Here

- At session start, read `data/knowledge-graph-top-dashboard.json` first — it gives the top projects and open items in one small file without loading the full notes tree.
- If broader context is needed, read `data/knowledge-graph-overview.json` next for domain orientation and project pointers.
- Then read `README.md` and `TEAM-STATUS.md` before broad changes.
- Treat this repository as a framework layer, not a dump of private environment specifics.
- Use `SESSION-HANDOFF.template.md` and example files to preserve reproducible operator workflow.

## Working Rules

- Keep framework assets generic and reusable; avoid introducing tenant- or user-specific secrets, hostnames, or private IP details.
- Preserve the framework-versus-instance boundary: examples belong here, live private state belongs in instance repositories.
- Keep Markdown guidance and JSON companion data aligned when both represent the same operational concept.
- Prefer small, reviewable changes and explicit migration notes over broad restructuring.
- Distinguish verified behavior from proposed roadmap items.

## Repository Layout

- `config/`: example configuration files and safe templates.
- `inventory/`: example device/service topology and environment inventory.
- `data/`: recurring-check and project index structures.
- `notes/`: sample session/project continuity patterns.
- `scripts/`: read-heavy helper scripts and explicit operational examples.
- `terraform-example/`: provider-neutral infrastructure scaffold.
- `.vscode/`: optional task surface.

## Validation Paths

There is no single global test suite. Validate the slice you touched.

- For PowerShell scripts: run the touched script with example-safe config and verify it remains read-focused by default.
- For docs/templates: confirm paths and file names referenced in README still exist.
- For JSON examples: keep structures valid and consistent with scripts/docs that consume them.

Recommended commands from repo root:

- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/host-health.ps1`
- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/network-audit-example.ps1`

## Change Expectations

- Do not add secrets, credentials, private keys, or personally identifying production metadata.
- Keep `.example` files generic and ready to copy into real environments.
- If script output shape or JSON contract changes, update the corresponding docs/examples in the same change.
- Avoid mixing framework cleanup with behavior-changing script edits unless tightly related.
