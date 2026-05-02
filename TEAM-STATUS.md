# Team Status

One row per active contributor. Updated at the end of every session.

| Contributor | Last session | Focus area       | Current open item                                      |
|-------------|--------------|------------------|--------------------------------------------------------|
| alice       | 2026-04-20   | cloud/terraform  | VPN spoke plan not yet applied; network inventory update pending |
| bob         | 2026-04-18   | LAN/monitoring   | ops-laptop backup job still targets local path, not nas-1 |

---

## Roadmap ideas

These are concrete ideas for future framework additions. They are documented here rather than in open issues so they survive context gaps.

### MCP server layer (not yet implemented)

Once a workspace has enough data files and cross-file joins become noisy, an MCP (Model Context Protocol) server can wrap the knowledge-graph JSON files with typed tool calls.

Key insight from benchmarking: MCP per-call latency equals raw file reads (~0.1–0.7 ms). The value is not speed — it is **targeted extraction**: returning only the ranked project array from a 50+ KB index file, which keeps the AI's context window focused without loading everything.

Design guidance when you are ready to add it:
- The JSON files are the source of truth; the MCP server is a thin query layer over them. No data migration needed.
- Cold-start cost is ~2 seconds (dotnet process startup) paid once per session. Negligible.
- Good tipping point: when you have many data files and frequent cross-file joins, or when raw file loads start filling the context window.
- Suggested stack: .NET + `ModelContextProtocol` NuGet package, stdio transport, auto-detect repo root by walking up until `SESSION-HANDOFF.md` is found.
- Tools to implement first: `get_top_dashboard`, `get_ranked_projects`, `list_data_files`, `read_data_file`.

There is no MCP implementation in this repository. The JSON-first structure is sufficient as a starting point.

---

## How to use this file

**Starting a session:**
Read this table to know what the rest of the team last touched and what is pending.
Then read your own last session file under `sessions/<your-name>/`.

**Ending a session:**
Update your row. Keep it to one line — last session date, focus area, and the single most important open item.
Anything more detailed belongs in your session log.

**Orienting after a gap:**
Read this table, then your last session file, then any other contributors' session files that mention your area.
That replaces the "what happened while I was away" conversation.
