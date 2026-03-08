---
name: compound
description: >
  Capture learnings from feature development to make future work easier.
  Each call captures one focused learning — a pattern discovery, gotcha,
  architecture decision, process improvement, or context gap. Learnings are
  routed to the right location based on scope (project-specific vs global)
  and surfaced in future sessions through CLAUDE.md references. Called after
  review cycles during execute, after /review approval, or at any point
  during development when insight is fresh.
argument-hint: "[learning-topic] or 'review' to process review findings"
---

# Compound: Feature Learning Capture

**Philosophy:** Large feature development produces valuable learnings at every phase — from brainstorm through review. Capture them while context is fresh, one at a time, so future features benefit. A learning that changes future behaviour is valuable. A learning that merely records history is shelfware. Every entry should tell the reader what to DO differently, not just what happened.

## Why This Matters

Without structured capture, learnings evaporate between sessions. The same gotchas get rediscovered, the same architectural mistakes get repeated, the same review comments appear on every PR. AI coding agents make this worse — each session starts fresh with no memory of past struggles unless learnings are persisted in files the agent reads at startup (CLAUDE.md, AGENTS.md, learnings files).

Research shows that lessons-learned databases fail when they focus on problems without solutions, or when they're stored in locations nobody visits. This skill solves both: learnings are written in imperative voice (what to DO) and routed to files that agents load automatically.

---

## Trigger Conditions

Run this skill when:
- After review approval (standard end-of-feature)
- During any phase when an important insight surfaces
- User says "capture learning", "compound", "document what we learned"
- After discovering a pattern, gotcha, or best practice
- When /execute or /review identifies learnings to document

---

## The Threshold Test

Not everything is worth documenting. Before persisting a learning, it should pass at least 2 of these 3 criteria:

1. **Would this save someone >15 minutes** if they knew it in advance?
2. **Is this not already captured** in existing docs, linter rules, or compiler errors?
3. **Will this still be relevant** in 3+ months?

**Skip documenting:**
- Trivial fixes (typos, syntax errors, formatting)
- Well-documented behaviour easily found in official docs
- One-off debugging steps for a transient state
- Subjective style preferences already covered by linters
- Workarounds for bugs in dependencies that have been fixed

---

## Learning Categories

### By Type

| Category | What It Captures | When It Surfaces |
|----------|-----------------|-----------------|
| `pattern` | A reusable approach that worked well | Design and implementation |
| `gotcha` | Something that caused unexpected problems | Implementation (prevents repeat) |
| `architecture` | A significant design choice with trade-offs | Design phase (informs decisions) |
| `process` | A workflow or tooling change that improved velocity | All phases (changes how we work) |
| `context-gap` | Missing knowledge that caused wasted time | Bead creation (adds context refs) |
| `review-feedback` | Recurring review comments worth codifying | Implementation (updates standards) |

### By Pipeline Phase

| Phase | Example Learning |
|-------|-----------------|
| `brainstorm` | "5 Whys revealed the real problem was X not Y" |
| `discovery` | "Auth framework requires X when configuring Y" |
| `prd` | "Security criteria on FRs caught issue during review" |
| `design` | "Cursor pagination was better than offset for this use case" |
| `plan` | "Sub-plan 03 should have been split — too large for one bead" |
| `execution` | "Tenant filter must be added to every entity query" |
| `review` | "Upstream compliance check caught missing index from design" |
| `testing` | "Concurrent operation scenario uncovered race condition" |

---

## Learning Scope

Learnings have different scopes. The scope determines where the learning is stored and how it's surfaced.

| Scope | Where to Store | Examples |
|-------|---------------|---------|
| **Project** (default) | `${PROJECT_ROOT}/docs/learnings/{category}.md` | Codebase-specific patterns, entity gotchas, service interactions |
| **Global** | `~/.claude/learnings/` or equivalent agent memory | Language-level gotchas, tool usage patterns, general best practices |
| **Feature** | Inline code comment or ADR in `docs/decisions/` | "This endpoint uses eventual consistency because..." |

**Decision tree:**
1. Does it apply regardless of project or tech stack? → **Global**
2. Does it apply across this codebase? → **Project** (default)
3. Does it apply only to this feature or module? → **Feature** (inline comment)

Default to **project** scope. Promote to global only when the learning clearly transcends the current codebase.

---

## Execution

### Step 1: Identify the Learning

Ask: **"What did you learn? Which category and phase does this relate to?"**

If processing review findings, read the review output and extract learnings.

### Step 2: Apply Threshold Test

Check the learning against the 3 criteria. If it doesn't pass at least 2, suggest skipping:
"This seems like {reason it might not qualify}. Still worth documenting, or skip?"

### Step 3: Classify

Determine:
- **Category** from the type table (pattern, gotcha, architecture, process, context-gap, review-feedback)
- **Phase** where the learning originated
- **Scope** (project, global, or feature)
- **Feature** it was discovered during

### Step 4: Document

**Learning Format:**

```markdown
## {Learning Title}

**Category:** {category}
**Phase:** {phase}
**Feature:** {feature name}
**Date:** {today}

### What to Do
{Imperative statement — what should someone DO differently because of this learning.
"Always add tenant filter to new entity queries."
"Use cursor pagination instead of offset for large datasets."
This is the minimum viable learning. If someone reads nothing else, this line should change their behaviour.}

### Context
{Brief context — what happened that produced this insight. 1-3 sentences.}

### Impact
{What would have happened without this learning? How much time/effort does it save?}
```

### Step 5: Save

**Project scope:** Append to `${PROJECT_ROOT}/docs/learnings/{category}.md`

If the file doesn't exist, create it:
```markdown
# Learnings: {Category}

Accumulated learnings from feature development.
Referenced by brainstorm and discovery skills.
```

**Global scope:** Append to `~/.claude/learnings/{category}.md` or equivalent agent memory location.

**Feature scope:** Add as an inline code comment at the relevant location, or create an ADR in `docs/decisions/`.

### Step 6: Surface the Learning

A learning that's stored but never found is shelfware. Ensure the learning will surface in future sessions:

**For project learnings:**
- Verify `docs/learnings/` is referenced in the project's CLAUDE.md or equivalent
- If not, suggest adding: `# Check docs/learnings/ for codebase-specific patterns and gotchas`

**For global learnings:**
- Add a one-line imperative to the global agent instructions file
- Keep it concise — global files are loaded every session and consume tokens

**For coding standards (review-feedback category):**
- Suggest updating CLAUDE.md with the new standard
- Frame as an imperative: "Always X when Y" or "Never X because Y"

### Step 7: Reference Updates (if applicable)

If the learning improves a shared reference file (project conventions, patterns doc, etc.):

```
"This learning about {topic} could improve {reference file}.

Suggested addition:
  {New pattern, gotcha, or convention}

Update the reference? [yes / no]"
```

If user approves, update the reference file directly.

---

## Bulk Processing (Review Findings)

When called with "review" argument, process the most recent review output:

```bash
ls "${PROJECT_ROOT}/docs/reviews/" 2>/dev/null | sort | tail -1
```

If no review file exists, ask the user to describe findings or run /review first.

For each significant finding category, extract potential learnings:
- **Correctness** findings → `gotcha` or `pattern` learnings
- **Security** findings → `gotcha` learnings
- **Performance** findings → `pattern` or `architecture` learnings
- **Upstream compliance** findings → `process` or `context-gap` learnings
- **Test coverage** findings → `review-feedback` learnings

Present extracted learnings to user for confirmation before saving. Apply the threshold test to each.

---

## Anti-Patterns

**The Problem-Only Entry** — "We had trouble with X." Without a "What to Do" section, this is a diary entry, not a learning. Every learning must include an imperative statement.

**The Novel** — A 500-word learning about a minor gotcha. Learnings should be scannable — one imperative line, 1-3 sentences of context, done. Detailed analysis belongs in an ADR or design doc, not a learning.

**The Kitchen Sink** — Batching 10 learnings into one compound call. Each call captures one focused learning. Multiple learnings get separate entries so they can be independently categorised and found.

**CLAUDE.md Pollution** — Adding every learning directly to CLAUDE.md. This file is loaded every session and consumes tokens. Only the highest-signal, most frequently relevant learnings belong there. Route everything else to `docs/learnings/` and reference the directory.

**Write-Only Documentation** — Storing learnings in a location nobody visits. Route learnings to files that agents load automatically, or reference them from files that agents load.

---

## Quality Standards

- **Imperative, not narrative** — "Always X when Y" not "We discovered that X can happen"
- **Specific, not vague** — "Add tenant filter to all entity queries" not "Watch out for multi-tenancy issues"
- **Threshold-tested** — Passes at least 2 of 3 criteria before persisting
- **Correctly scoped** — Project vs global vs feature, stored in the right location
- **Surfaced** — Referenced from a file that agents load, not buried in an unvisited directory
- **One per call** — Focused entries that can be independently found and categorised

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "done" | Learning captured | Session complete or capture another |
| "more" | Capture another learning | Return to Step 1 |
| "skip" | Learning doesn't pass threshold | Discard and move on |

---

*Skill Version: 3.0*
*v3: Threshold test for documentation worthiness, learning scope routing (project/global/feature), imperative voice requirement, anti-patterns, removed project-specific domain references, surfacing guidance*
