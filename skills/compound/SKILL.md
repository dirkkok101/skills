---
name: compound
description: >
  Capture learnings from feature development to make future work easier.
  Each call captures one or more focused learnings — pattern discoveries,
  gotchas, architecture decisions, process improvements, or context gaps.
  Learnings are routed to the right location based on scope (project-specific
  vs global) and surfaced in future sessions through CLAUDE.md references.
  Called after review cycles during execute, after /review approval, or at
  any point during development when insight is fresh.
argument-hint: "[learning-topic] or 'review' to process review findings"
---

# Compound: Feature Learning Capture

**Philosophy:** Large feature development produces valuable learnings at every phase — from brainstorm through review. Capture them while context is fresh so future features benefit. A learning that changes future behaviour is valuable. A learning that merely records history is shelfware. Every entry should tell the reader what to DO differently, not just what happened.

**Duration targets:** Single learning ~3-5 minutes. Bulk processing (review findings) ~10-20 minutes. Most time should be spent on Step 3 (threshold test and classification) — if you're spending more time writing than deciding what's worth writing, the threshold test isn't filtering hard enough.

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

## Stage Gate Reference
For interactive stage gate patterns used at PAUSE points: `_shared/references/stage-gates.md`
If `AskUserQuestion` is unavailable, fall back to presenting options as markdown text and waiting for freeform response.

---

## Collaborative Model

```
Phase 1: Identify & Classify Learnings
  ── PAUSE 1: "Here's what I've identified. Worth documenting?" ──
Phase 2: Document & Save
Phase 3: Surface & Verify
  ── PAUSE 2: "Learning saved. Surfacing confirmed." ──
```

For bulk processing (review findings), Phase 1 presents all candidate learnings at once. The user approves, rejects, or modifies each before Phase 2 processes approved ones.

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
| **Global** | Agent's persistent memory location (configured per agent) | Language-level gotchas, tool usage patterns, general best practices |
| **Feature** | Inline code comment or ADR in `docs/decisions/` | "This endpoint uses eventual consistency because..." |

**Decision tree:**
1. Does it apply regardless of project or tech stack? → **Global**
2. Does it apply across this codebase? → **Project** (default)
3. Does it apply only to this feature or module? → **Feature** (inline comment)

Default to **project** scope. Promote to global only when the learning clearly transcends the current codebase.

---

## Critical Sequence

### Phase 1: Identify & Classify

**Step 1.1 — Gather Candidate Learnings:**

**Single learning mode:** Ask the user what they learned, or extract from the context of the current conversation.

**Bulk mode (review findings):** Read the most recent review output from `docs/reviews/`. For each significant finding category, extract potential learnings:
- **Correctness** findings → `gotcha` or `pattern` learnings
- **Security** findings → `gotcha` learnings
- **Performance** findings → `pattern` or `architecture` learnings
- **Upstream compliance** findings → `process` or `context-gap` learnings
- **Test coverage** findings → `review-feedback` learnings

If no review file exists, ask the user to describe findings or run /review first.

**Step 1.2 — Apply Threshold Test:**

For each candidate learning, check against the 3 criteria. If it doesn't pass at least 2, flag it:
"This seems like {reason it might not qualify}. Still worth documenting, or skip?"

**Step 1.3 — Classify Each Learning:**

For each learning that passes threshold:
- **Category** from the type table (pattern, gotcha, architecture, process, context-gap, review-feedback)
- **Phase** where the learning originated
- **Scope** (project, global, or feature)
- **Feature** it was discovered during

**PAUSE 1:** Present classified learnings to the user.

**Single mode:**

Present the learning details as formatted markdown:
```markdown
## Learning Identified

**Title:** {title}
**Category:** {category} | **Phase:** {phase} | **Scope:** {scope}
**Threshold:** Passes {N}/3 criteria ({which ones})

**What to Do:** {imperative statement}
**Context:** {1-2 sentences}
```

Then use AskUserQuestion (Decision Gate — Pattern 1):
```
AskUserQuestion:
  question: "Save this learning?"
  header: "Learning"
  multiSelect: false
  options:
    - label: "Accept (Recommended)"
      description: "Save this learning as classified."
    - label: "Modify"
      description: "Change category, scope, or wording."
    - label: "Skip"
      description: "Doesn't pass threshold after all."
```

**Bulk mode:**

Present all learnings as formatted markdown:
```markdown
## Learnings from Review

{N} candidate learnings extracted, {M} passed threshold:

| # | Title | Category | Phase | Scope | Threshold |
|---|-------|----------|-------|-------|-----------|
| 1 | {title} | {category} | {phase} | {scope} | {N}/3 |
| 2 | {title} | {category} | {phase} | {scope} | {N}/3 |

Filtered out: {list of candidates that didn't pass threshold and why}
```

Then use AskUserQuestion (Batch Review — Pattern 3), up to 4 learnings per batch:
```
AskUserQuestion:
  question: "Which learnings should we save? (Unselected items are skipped)"
  header: "Learnings"
  multiSelect: true
  options:
    - label: "{learning 1 title}"
      description: "{category} — {phase} — {scope}"
    - label: "{learning 2 title}"
      description: "{category} — {phase} — {scope}"
    - label: "{learning 3 title}"
      description: "{category} — {phase} — {scope}"
    - label: "{learning 4 title}"
      description: "{category} — {phase} — {scope}"
```

If more than 4 learnings, present in sequential batches.

---

### Phase 2: Document & Save

For each approved learning:

**Step 2.1 — Write in Format:**

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

**Step 2.2 — Format Validation:**

Before saving, verify the learning follows the format:
- [ ] Has a "What to Do" section with an imperative statement (not narrative)
- [ ] "What to Do" is specific and actionable (not vague advice)
- [ ] Context is brief (1-3 sentences, not a novel)
- [ ] Category and scope are correct

If validation fails, fix the learning before saving. This prevents the "Problem-Only Entry" anti-pattern from slipping through.

**Step 2.3 — Save:**

**Project scope:** Append to `${PROJECT_ROOT}/docs/learnings/{category}.md`

If the file doesn't exist, create it:
```markdown
# Learnings: {Category}

Accumulated learnings from feature development.
Referenced by brainstorm and discovery skills.
```

**Global scope:** Append to the agent's persistent memory location. Keep it concise — global files are loaded every session and consume tokens.

**Feature scope:** Add as an inline code comment at the relevant location, or create an ADR in `docs/decisions/`.

---

### Phase 3: Surface & Verify

A learning that's stored but never found is shelfware. This phase ensures the learning will actually surface in future sessions.

**Step 3.1 — Verify Upstream Consumption:**

Check that the learnings directory is referenced by files that agents load:

- Does the project's CLAUDE.md (or equivalent) reference `docs/learnings/`?
- If not, suggest adding: `# Check docs/learnings/ for codebase-specific patterns and gotchas`

For global learnings:
- Add a one-line imperative to the global agent instructions file
- Keep it concise — global files are loaded every session

For coding standards (review-feedback category):
- Suggest updating CLAUDE.md with the new standard
- Frame as an imperative: "Always X when Y" or "Never X because Y"

**Step 3.2 — Reference Updates (if applicable):**

If the learning improves a shared reference file (project conventions, patterns doc, etc.):

```
"This learning about {topic} could improve {reference file}.

Suggested addition:
  {New pattern, gotcha, or convention}

Update the reference? [yes / no]"
```

If user approves, update the reference file directly.

**Step 3.3 — Verify End-to-End:**

Confirm the learning will actually surface by checking the full chain:
1. Learning is saved in the correct location
2. That location is referenced from a file agents load at startup
3. Upstream skills (research, brainstorm, discovery) will encounter it when they import learnings

If any link in the chain is broken, fix it now — don't leave a learning orphaned.

**PAUSE 2:** Confirm completion.

Present confirmation as formatted markdown:
```markdown
## Learning Captured

**Saved:** {file path}
**Surfacing verified:** {Yes — referenced from CLAUDE.md / No — needs reference added}
**Reference updates:** {any files updated}
```

Then use AskUserQuestion (Decision Gate — Pattern 1):
```
AskUserQuestion:
  question: "Learning captured. What next?"
  header: "Next"
  multiSelect: false
  options:
    - label: "Done (Recommended)"
      description: "Session complete."
    - label: "More"
      description: "Capture another learning."
    - label: "Update reference"
      description: "Also update a shared reference file with this learning."
```

---

## Anti-Patterns

**The Problem-Only Entry** — "We had trouble with X." Without a "What to Do" section, this is a diary entry, not a learning. Every learning must include an imperative statement that tells the reader what to DO differently. The format validation step catches this — if it slips through, the validation isn't running.

**The Novel** — A 500-word learning about a minor gotcha. Learnings should be scannable — one imperative line, 1-3 sentences of context, done. Detailed analysis belongs in an ADR or design doc, not a learning. If you're writing more than 10 lines, you're probably documenting an architecture decision, not a learning.

**The Kitchen Sink** — Mixing unrelated learnings into a single entry. Each learning gets its own entry with its own category and scope so it can be independently found and acted on. A single compound session can process multiple learnings (especially in bulk mode), but each one is a separate entry.

**CLAUDE.md Pollution** — Adding every learning directly to CLAUDE.md. This file is loaded every session and consumes tokens. Only the highest-signal, most frequently relevant learnings belong there. Route everything else to `docs/learnings/` and reference the directory. A CLAUDE.md that grows to 500 lines of learnings degrades agent performance.

**Write-Only Documentation** — Storing learnings in a location nobody visits. This is why Phase 3 exists — verify the full chain from saved file to agent startup. If no upstream skill references the learnings directory, the learning might as well not exist.

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "done" | Learning(s) captured | Session complete |
| "more" | Capture another learning | Return to Phase 1 |
| "skip" | Learning doesn't pass threshold | Discard and move on |

---

*Skill Version: 3.4*
*v3.4: PAUSE points use AskUserQuestion tool — Decision Gate for single learning and completion, Batch Review for bulk learnings*
*v3.1: Duration targets, collaborative model with PAUSE points, structured response options (single + bulk mode), format validation before saving, surfacing verification as dedicated phase with end-to-end chain check, generic agent memory path (not hardcoded), clarified one-entry-per-learning vs session-can-process-multiple, removed duplicate Quality Standards section, shell commands replaced with prose, anti-patterns explain WHY*
