# Change Management and Risky Operations

## Purpose

This note captures the operating pattern to use when a task can affect availability, access, routing, storage, backups, or any other system that becomes very memorable when it breaks.

The standard is straightforward: separate staging from cutover, write the rollback before you need it, and verify the live result instead of assuming the plan survived contact with reality.

## Use this approach for

- network changes that can affect routing, DHCP, DNS, firewall behavior, or remote access
- storage moves, disk replacement, backup-target changes, and share redesigns
- service cleanup on systems that already carry useful workloads
- infrastructure changes where partial activation can interfere with the current live state
- cloud or Terraform changes that can disconnect, expose, replace, or strand live resources

## Default method

1. Define the live authority first.
   Be explicit about what currently owns the active role: gateway, DHCP server, DNS authority, share path, or production endpoint.

2. Separate staging, cutover, and post-cutover verification.
   Safe build work and live activation should not be mixed into one blurry sequence.

3. Keep rollback access independent.
   Maintain a management path, backup access route, alternate console path, or reversible state that does not depend on the thing you are changing.

4. Record the no-go overlaps.
   Examples: two DHCP servers on one LAN, two routers claiming the same gateway IP, deleting the old service before the replacement has proven itself, or changing permissions without a restore path.

5. Change one risky layer at a time.
   Keep the blast radius small enough that failures stay legible.

6. Verify immediately after each high-impact step.
   Confirm the active authority, access path, and core client behavior before moving on.

7. Define rollback before execution.
   If the new state fails validation, the path back should already be written down.

## Reusable checklist

### Before change

- current live owner identified
- management or fallback access confirmed
- backup, snapshot, or export taken when appropriate
- success criteria written down
- rollback trigger and rollback path written down

### During staging

- new system does not claim live authority early
- test access is deliberate and bounded
- destructive cleanup is deferred until restore confidence exists

### During cutover

- old authority removed from the active path first
- new authority activated once
- no overlapping control plane remains active

### After cutover

- verify access, data path, and expected client behavior
- verify monitoring, backups, and management access still work
- update handoff notes with the new steady state

## Generic scenarios that fit this method

### Router replacement or gateway migration

Risk areas:

- live gateway ownership
- DHCP overlap
- WAN failover behavior
- remote access during the handoff

### Storage replacement or backup-target move

Risk areas:

- data placement and mount paths
- backup freshness
- share permissions
- restore confidence during the move

### Service cleanup on a live host

Risk areas:

- disabling something that still owns traffic
- package or service removal before the replacement is verified
- firewall or DNS drift during the cleanup

### Cloud or infrastructure-as-code changes

Risk areas:

- replacing live resources unintentionally
- exposing a service with the wrong policy
- route or security-group drift
- destructive terraform apply against stale assumptions

## Practical reading

Not every change needs a maintenance-window ceremony.

Use this method when partial activation, conflicting authorities, or irreversible cleanup can create an outage that is much harder to unwind than to plan.

If a task touches only isolated lab assets or can be recreated trivially, lighter notes are usually enough.