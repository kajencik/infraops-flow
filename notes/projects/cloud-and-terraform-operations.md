# Cloud and Terraform Operations

## Goal

Extend the operations notebook beyond local assets so the same assistant can reason across three linked things at once:

- what exists
- what is healthy
- what the infrastructure code says should exist

The point is not to turn Terraform into a monitoring system or to turn inventory into state files. The point is to keep asset knowledge, recurring checks, and infrastructure intent close enough together that the operator and the assistant can move from evidence to change safely.

## Why This Fits InfraOps Flow

Small environments drift in predictable ways:

- a host exists in Terraform but is missing from practical monitoring
- a cloud VM is still running, but nobody has updated the asset inventory or notes
- costs are technically low, but the repo does not explain why the node exists anymore
- a Terraform change is ready to apply, but there is no attached validation or rollback note

InfraOps Flow is useful when it keeps those threads joined.

## Core Model

### Assets

Track cloud VMs, VPN nodes, utility hosts, backup targets, and public endpoints as named assets, not as scattered provider screenshots or remembered IDs.

### Desired State

Terraform expresses the intended infrastructure shape: providers, regions, instance sizes, network layout, bootstrap templates, and lifecycle boundaries.

### Observed State

Recurring checks confirm the live side: reachability, service health, WireGuard status, basic security exposure, backup success, and cost or provider drift review.

### Change Evidence

Plans, validation notes, and post-change checks should sit near the project note so a future session can tell the difference between a deliberate change and a mystery.

## Assistant-Friendly Working Pattern

1. Read the asset inventory first.
2. Read the active cloud/Terraform project note.
3. Check the latest recurring evidence.
4. Review the Terraform plan or current stack inputs.
5. Summarize the gap between intended state and observed state.
6. Prepare a change only after validation and rollback are explicit.

That sequence gives the assistant enough context to help without pretending that infrastructure code alone explains the whole environment.

## Practical Areas To Track

### Utility Nodes

Small always-on VMs used for VPN, backup relays, lightweight automation, remote admin access, or narrow supporting services.

That can include a simple public-facing Linux VM when the workload does not need a full application tier, for example a static site, status page, lightweight documentation host, or other low-complexity public endpoint.

### Cost and Provider Direction

Document why a provider or instance class is being used, not just the current price. Cheap infrastructure is only useful if the operator can still explain its purpose later.

Keep one explicit cost model close to the project, even if it is simple and manually maintained. A small script-driven monthly check is often enough to catch the more common failure mode: not runaway hyperscaler spend, but quiet drift where the operator can no longer explain why the current cloud shape still deserves its monthly cost.

### State and Lifecycle Boundaries

Separate stable core infrastructure from disposable test nodes, short-lived spokes, and experiments. The notes should make it obvious which things are safe to recreate and which are carrying real responsibility.

### Validation After Apply

Treat `terraform apply` as the midpoint, not the finish line. The useful end state is verified service behavior, not just a successful provider API call.

## Suggested Artifacts

- inventory entries for cloud assets and public endpoints
- inventory entries for applications, the servers they run on, and their dependencies
- recurring checks for reachability, service status, and drift review
- a project note describing provider choice, lifecycle split, and current operating model
- a small cost-check profile and script output summarizing the current monthly model
- a provider-neutral Terraform scaffold that separates long-lived core resources from disposable spoke resources
- short dated session notes when a plan, cutover, or recovery event materially changes the state
- script outputs or summaries that help the assistant compare intended state to live evidence

## Good First Scope

Start with one small cloud pattern, not a multi-provider platform:

1. one low-cost utility node
2. one Terraform root stack
3. one simple validation checklist
4. one cost note explaining why this provider was chosen
5. one recurring check proving the node is still reachable and still useful

## Relationship To Other Notes

- Use `notes/projects/observability-and-automation.md` for the recurring-check model.
- Use `notes/projects/change-management-and-risky-ops.md` when a Terraform or cloud change can affect real access, routing, or recovery.

Public scaffold location:

- `terraform-example/README.md`
- `terraform-example/stacks/generic-cloud/core/`
- `terraform-example/stacks/generic-cloud/spokes/`
- `terraform-example/modules/generic-utility-node/`
- `terraform-example/modules/generic-network-appliance/`
- `inventory/service-topology.example.json`

The current public example explicitly includes a public-facing Linux VM role in the core stack so the static-site/server pattern is not left implicit.

This note is the bridge between those two ideas: operational evidence on one side, infrastructure intent on the other.