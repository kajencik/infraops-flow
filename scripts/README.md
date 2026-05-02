# Scripts

This is where the repo stops talking about operations and starts doing small, useful pieces of it.

In the sample environment, scripts are the modest part of the system: they support the operator, they do not pretend to replace them.

That matters. The goal is not to automate everything. The goal is to let the human spend less time on repetitive collection, checking, and reshaping of boring inputs.

Guidelines:

- keep environment-specific values out of the script body
- prefer config or parameters over hardcoded targets
- treat write actions as explicit and reviewable
- separate reusable helpers into `scripts/lib/`

Good scripts in this repo should feel boring in the best way: readable, parameterized, and unlikely to surprise an operator at 23:40.

They are how a week of scattered re-checking starts turning into a day with a known run path.

Current scripts:

- `host-health.ps1` collects a read-only Windows host snapshot without assuming anything about the rest of the environment.
- `network-audit-example.ps1` shows a small config-driven reachability check with optional JSON snapshot and history output.
- `cloud-cost-check-example.ps1` shows a small config-driven monthly cloud-cost review for generic utility-node and network-appliance planning.
- `sync-repo-rename-workspace.ps1` builds a portable rename/workspace bundle under a sync directory so other machines can align repo folder names and `.code-workspace` paths after a repository rename; the bundle now includes `scripts/apply-repo-rename-workspace.ps1` for direct execution on target machines.
- `apply-repo-rename-workspace.ps1` consumes a generated bundle and can automatically rename repo folders, update local workspace files, and rewrite git origin URLs to the new repo slug (dry-run by default; use `-Execute` to apply).

Related runbook example:

- `notes/projects/repo-rename-and-workspace-sync.md` documents the full source-machine to target-machine rename workflow with dry-run, execute, and rollback guidance.