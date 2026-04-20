# Terraform Example

This folder is a public-safe Terraform scaffold for the kind of small cloud WireGuard planning discussed elsewhere in this repo.

It is intentionally generic:

- no real provider names
- no real account structure
- no private IP plan from a live environment
- no secret values

The point is to show a usable shape for Hermes-assisted work, not to publish a fake one-click deployment.

## Why this exists

The useful public pattern is not just "some Terraform files."

The useful pattern is:

1. infrastructure intent has a clear folder structure
2. long-lived core resources are separated from disposable spokes
3. asset notes and recurring checks can describe the same systems
4. cost review can stay close to the infrastructure model
5. application and server relations can be described without relying on memory alone

## Structure

```text
terraform-example/
  modules/
    generic-network-appliance/
    generic-utility-node/
  stacks/
    generic-cloud/
      core/
      spokes/
  templates/
    cloud-init-wireguard-node.yaml.tftpl
```

## Design notes

- `modules/` contains provider-neutral module interfaces.
- `stacks/generic-cloud/core/` models the long-lived utility node, network-appliance role, and a public-facing Linux VM for simple static-site or edge-adjacent hosting.
- `stacks/generic-cloud/spokes/` models disposable spoke or test nodes that should be easy to replace.
- `templates/` holds bootstrap text that a real provider-specific stack could pass into cloud-init or an equivalent initialization path.

The module implementations use `terraform_data` so the example stays valid and inspectable without pretending to be a real cloud provider deployment. Replace those resources with provider-specific resources when adapting the scaffold.

## Hermes fit

This folder is meant to work alongside:

- `notes/projects/cloud-and-terraform-operations.md`
- `config/cloud-costs.example.json`
- `data/recurring-checks.json`
- `inventory/service-topology.example.json`

That way the assistant can reason across Terraform shape, modeled cost, and recurring validation without needing private infrastructure details.

## Example service topology

The matching inventory example models a small cloud application shape:

- `Eshop App A` runs on an application server and depends on a database server
- `Desktop App B` talks directly to the same database server
- `Static Page C` is served directly from a public-facing Linux VM

That gives Hermes a concrete relation map between infrastructure assets and application behavior.

## First adaptation path

1. copy one stack into your private repo
2. replace module internals with real provider resources
3. keep the same core/spokes lifecycle split
4. keep the same variable names where they still make sense
5. point your cost and monitoring notes at the resulting assets