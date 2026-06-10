---
name: session-review
description: Review past Claude Code sessions on this machine over a given time range and scope, and distill the user's behavior patterns — preferred workflows, recurring principles, red lines, corrections — plus a what-happened work digest. Use whenever the user asks to review past work or sessions ("check your work from the last month", "what did we do last 2 weeks", "review all sessions in project X"), asks what patterns/preferences/workflows they have, wants a work summary or month-in-review, or wants session history mined to improve CLAUDE.md or create skills. Accepts a time range (days) and a project scope filter.
---

You are mining the user's own session transcripts to answer two questions: *what work happened* (digest) and *how the user likes to work* (behavior patterns worth codifying in CLAUDE.md or skills). The raw material is large — hundreds of transcripts with pasted logs — so extraction is scripted, reading is delegated to parallel agents, and only synthesis happens in the main thread.

## Step 1: Pin down scope and range

From the request, determine:
- **Time range**: days to look back. Default 30. "last 2 weeks" → 14.
- **Scope**: project filter (case-insensitive substring of the project dir slug, e.g. "taskflow", "cvat"). Default: all projects.
- **Goal**: digest only, patterns only, or both (default both).

If the user asked something materially different from these defaults, confirm before the heavy steps; otherwise state the interpretation in one line and proceed.

## Step 2: Extract

Run the bundled script:

```bash
<skill-dir>/scripts/extract_sessions.sh -d <DAYS> [-p <FILTER>] [-o <OUTDIR>]
```

Default workspace: `~/.claude/cache/session-review`. It produces:
- `digest.tsv` — one line per session: date, project slug, AI title, first user prompt (200 chars)
- `prompts/<project>.txt` — every user-typed message, grouped under `=== SESSION <date> <id> ===` headers

Report the session count and per-project line counts to the user before continuing. If zero sessions matched, say so and stop — don't analyze an empty set.

## Step 3: Fan out analysis agents

Group the prompt files into ~4–6 batches: merge related project dirs (e.g. `Nexus-Java-vue*` together), balance by line count so no agent gets everything. Launch all agents **in a single message** so they run concurrently:

- **One pattern-analysis agent per batch**, with this prompt shape (fill in file paths and a one-line project context if known):

> Read <files>. These are all user-typed prompts from Claude Code sessions in <projects> over the past <N> days, grouped by session with === SESSION date id === headers. Files contain large pasted error logs — skim those, focus on the user's own words.
> Analyze the USER's behavior patterns (not the project). Extract:
> 1. WORKFLOWS: recurring task patterns (name, frequency estimate, 1-2 verbatim quotes)
> 2. PRINCIPLES: recurring instructions/preferences, verbatim quotes
> 3. RED LINES: explicit prohibitions or angry corrections (look for: don't, never, stop, no!, why did you, revert, undo, wait, 等一下, 不要), verbatim quotes with session date
> 4. CORRECTIONS: what Claude did wrong vs what the user wanted
> Be exhaustive on red lines and corrections — they matter most. Return raw structured markdown; your final message is the deliverable.

- **One digest agent** on `digest.tsv`: group by project, cluster session titles into themes, then a week-by-week chronological narrative.

The bilingual cue matters: this user writes corrections in Chinese when frustrated — tell agents to treat Chinese imperatives as high-signal.

## Step 4: Synthesize

Merge agent outputs in the main thread (don't delegate synthesis — it needs cross-batch comparison):
- **Work digest**: per-project themes + chronological arc.
- **Top workflows** ranked by cross-project frequency — a pattern seen in one project is habit; in three, it's a workflow.
- **Common principles** — deduplicate, keep one best verbatim quote each.
- **Red lines** — anything that triggered revert/stop/anger. Never soften these.
- **Gap analysis**: diff the findings against `~/.claude/CLAUDE.md` — which patterns are already codified, which are live corrections not yet written down.

## Step 5: Deliver and offer follow-ups

Final message = the full report (digest + patterns + gaps). Then offer, without doing them unasked:
1. Save report as a dated md file in the current workspace
2. Update persistent memory files with new/changed patterns
3. Merge gap items into CLAUDE.md (needs explicit approval — it's the user's rule file)
4. Convert a recurring workflow into a skill

Each of these is a change — wait for the user's pick.
