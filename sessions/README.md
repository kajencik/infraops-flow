# Sessions

This folder holds personal session history for each contributor.

## Why it exists

Shared folders like `inventory/`, `scripts/`, and `applications/` represent facts about the environment.
This folder represents facts about the people working on it — specifically, what each person has done,
found, and left open across their working sessions.

The combination of shared + personal layers gives an LLM (or a new team member) complete context:
- what the environment looks like (shared files)
- what each person has been doing with it (session files)

## Structure

```
sessions/
  <contributor>/
    PROFILE.md             # who they are, their focus area, how to read their notes
    YYYY-MM-DD.md          # one file per working session
    YYYY-MM-DD-topic.md    # use a short topic suffix if there are multiple sessions per day
  README.md                # this file
```

## Session file format

Each session file covers a single working session and uses this structure:

```markdown
# Session — YYYY-MM-DD

## What I did
Concrete actions taken: commands run, configs changed, things verified.

## What I found
Evidence worth keeping: anomalies, confirmed states, surprises.

## What I changed in shared files
Notes on any changes made to inventory/, scripts/, applications/, terraform-example/, or config/.
Link to the commit or PR if useful.

## Open items
Things left half-done, blocked, or worth picking up next session.
```

## Conventions

- **Session filename:** `YYYY-MM-DD.md` or `YYYY-MM-DD-brief-topic.md`
- **`PROFILE.md`:** one short paragraph — name, focus area, preferred check cadence
- **Ownership:** no one edits another contributor's session files; they accumulate as an immutable log
- **`TEAM-STATUS.md`:** update the relevant row at the end of every session (two-minute task)

## Using sessions as LLM context

At the start of a session, feed your LLM:
1. `TEAM-STATUS.md` — what the whole team knows right now
2. Your own most recent session file — where you personally left off
3. Any relevant shared file — environment facts you need for this session

The files are the memory. No cross-session persistence is required from the LLM itself.
