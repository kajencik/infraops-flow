# Observability and Automation

## Goal

Reduce repetitive operator work by turning recurring checks into a small system with known inputs, known outputs, and an audit trail that survives interruption.

The point is not to automate everything. The point is to stop re-discovering the same state by hand when a short repeatable collection path would do it faster and with less ambiguity.

## Current Status

- The working model is centered on reusable building blocks instead of one environment.
- The basic shape is: assets, checks, events, rules, actions, and human approval.
- The preferred storage split is lightweight and practical: notes in Markdown, config/state in JSON or YAML, and event history in SQLite when plain files stop being enough.

## Core Model

### Assets

Things that matter operationally: hosts, routers, switches, services, shares, sensors, or backup targets.

### Checks

Repeatable probes such as ping, TCP reachability, API health, log review, inventory diff, or storage-health collection.

### Events

Meaningful changes produced by checks: new device seen, core host missing, backup path changed, repeated login failures, service unreachable.

### Rules

Deterministic logic that decides whether an event is noise, a note, or an incident worth escalation.

### Actions

Safe follow-up steps such as writing a summary, opening a project note, sending a notification, or preparing a guided remediation path.

### Human Approval

Higher-impact actions should stay approval-gated. The system should help the operator spend judgment where it matters, not quietly take risky actions on its own.

## Practical Pattern

1. Collect on a schedule.
2. Diff against the last known state.
3. Classify with rules first.
4. Summarize in a short operator-facing note.
5. Require approval before anything meaningfully changes the environment.

## Suggested Layout

```text
config/
  profiles/
  rules/
scripts/
  collectors/
  checks/
  actions/
state/
logs/
playbooks/
templates/
```

## First Useful Milestone

1. Pick one recurring check that already exists informally.
2. Make the inputs explicit.
3. Save a machine-readable snapshot.
4. Diff the next run against the previous snapshot.
5. Write a short human summary only when something changed.

## Why This Matters

The real value is not the probe itself. It is the reduction in reconstruction cost.

When recurring evidence is captured consistently, sessions become shorter, handoff improves, and the human can focus on deciding what to do next instead of rebuilding context from memory.