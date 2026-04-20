# Notes

This directory holds the operator-facing narrative: what changed, what was verified, what still looks suspicious, and what future-you should read first.

In the sample environment, the notes tell the real transition story: from a setup that mostly worked through habit and memory to one that can survive interruption, handoff, and a bad Tuesday evening without losing the plot.

The aim is not more prose for its own sake. The aim is to spend less time reconstructing what happened and more time doing the next useful thing.

Suggested flow:

1. Keep session continuity in `SESSION-HANDOFF.template.md`.
2. Track ongoing work in `notes/projects/`.
3. Use dated session notes when the work is real enough that memory alone should no longer be trusted.

The notes are where weak intuitions become known state, and where long messy tasks start turning into shorter, more scriptable ones.

Current reusable note:

- `notes/projects/change-management-and-risky-ops.md` captures a general cutover/rollback method for risky infrastructure work.
- `notes/projects/observability-and-automation.md` captures the model for recurring checks, structured evidence, and approval-gated follow-up.
- `notes/projects/cloud-and-terraform-operations.md` captures the cloud/IaC direction where asset state, monitoring evidence, and Terraform intent stay usable together for the assistant.

Current example sessions:

- `notes/2026-04-20-change-management-session.md` shows how a risky change can be prepared without turning the session into a memory dump.
- `notes/2026-04-20-monitoring-session.md` shows the shift from ad hoc checks to repeatable collection.
