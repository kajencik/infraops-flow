# Data

Machine-readable companion files live here.

Use them to support:

- project indexing
- recurring checks
- lightweight automation

In the sample environment, this is where the operator turned vague intentions into tracked work:

- recurring checks that happen on purpose
- active projects that do not vanish into terminal scrollback
- lightweight structured data that makes the notes easier to trust

This is the quiet utility layer of the repo: not glamorous, but very good at turning faint signals into something you can actually trace later.

This is also where the LLM becomes useful without becoming magical. Structured files make the boring work easier to update, check, compare, and carry forward across sessions.

## Files

- `projects-index.json` — active and tracked project metadata with status and `resumePriority`. The AI reads this to know what is in flight and where to look next.
- `recurring-checks.json` — repeatable checks, their purpose, and expected cadence.
- `knowledge-graph-overview.example.json` — cross-domain orientation index. Copy and rename to `knowledge-graph-overview.json` in your instance. One sentence per domain, one pointer per project. Load this for broad context before opening long files.
- `knowledge-graph-top-dashboard.example.json` — ultra-compact startup snapshot: top 5 projects, top topics, open items. Copy and rename to `knowledge-graph-top-dashboard.json`. Keep it small and regenerate it whenever priorities shift significantly.

## Knowledge-graph pattern

The two `knowledge-graph-*.example.json` files introduce a lightweight knowledge-graph layer that the AI assistant can use to orient quickly at session start:

1. Load `knowledge-graph-top-dashboard.json` first — one small file, answers "what are we working on right now"
2. Load `knowledge-graph-overview.json` next if broader context is needed — domains, project summaries, key file pointers
3. Drill into `projects-index.json` or specific note files only when a project needs detailed attention

This layered approach keeps the AI's context window focused. It also makes the repo portable: the knowledge lives in plain JSON, not inside any tool or service.

The dashboard file is maintained manually (or by a small script in your instance). There is no build step or server required to use it.

### Future direction: MCP server

Once the JSON structure is stable and the file volume grows enough that raw file reads become noisy, an MCP (Model Context Protocol) server can wrap these same files with typed tool calls — returning only the ranked project array instead of the full index, or joining project metadata with session evidence on demand.

That is a follow-up step, not a starting requirement. The JSON files are the product; an MCP server is one possible query interface over them.

## External advisory references

If your instance includes a local awesome-copilot mirror, keep its compact index under `data/external/awesome-copilot/llms.txt` (or an equivalent small index file). For Copilot-specific questions, query that index first and then open only the specific mirrored file you need.

Use this as advisory context only. Environment truth still lives in this repository's own inventory, notes, and data files.

