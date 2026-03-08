---
name: plan
description: >
  Transform approved technical designs into implementation plans through
  structured dialogue. Decomposes work into right-sized, ordered tasks
  with clear dependencies, acceptance criteria, and risk-aware sequencing.
  Plans are permanent documentation — they explain WHAT to build and in
  what order, not HOW to write the code. The agent co-authors with the
  user, pausing to validate decomposition and ordering before detailing
  sub-plans. Use when design is approved, user says "write the plan",
  "plan this", "create plan for...", or a design document exists.
argument-hint: "[feature-name] or path to design doc"
---

# Plan: Design → Implementation Plan

**Philosophy:** A plan answers "how do we build it, in what order, and how do we know each piece is done?" The design doc made the architectural decisions; the plan decomposes them into executable work. Plans are permanent documentation — they explain the decomposition rationale so future engineers understand not just what was built but why it was built in that sequence.

## Why This Matters

A plan that just lists tasks in a spreadsheet is a todo list, not an implementation plan. This skill produces plans that are:
- **Risk-aware** — risky or uncertain work comes early, not at the end
- **Vertically sliced** — each task delivers testable, end-to-end functionality where possible
- **Right-sized** — tasks are small enough for focused execution but large enough to be meaningful
- **Traceable** — every task traces to FRs from the PRD and verification from the design
- **Agent-ready** — each sub-plan contains enough context for /beads to create executable work packages

---

## Trigger Conditions

Run this skill when:
- Design has been approved (`/technical-design` completed)
- User says "write the plan", "plan this", "create plan for..."
- A design document exists at `${PROJECT_ROOT}/docs/designs/{feature}/`
- For BRIEF scope: brainstorm + PRD exist (no design doc needed)

---

## Mode Selection

| Mode | Input Required | When | Output |
|------|---------------|------|--------|
| **BRIEF** | Brainstorm + PRD (no design doc) | BRIEF scope, simple changes | Single `overview.md` with inline tasks |
| **STANDARD** | Design document | STANDARD scope, typical feature | `overview.md` + sub-plan files |
| **COMPREHENSIVE** | Design document | COMPREHENSIVE scope, multi-service | `overview.md` + sub-plans + risk register + cross-cutting concerns doc |

BRIEF mode produces a single file with 3-6 tasks. No sub-plan files — the overview IS the plan.

---

## Collaborative Model

```
Phase 1: Import & Decompose
  ── PAUSE 1: "Here's the decomposition. Right tasks? Right order?" ──
Phase 2: Overview Document
Phase 3: Sub-Plans (STANDARD+)
  ── PAUSE 2: "Sub-plans written. Ready for review?" ──
Phase 4: Self-Review
  ── PAUSE 3: "Plan complete. Approve for /beads?" ──
```

---

## Prerequisites

**Step 0: Resolve Project Root:**

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
ls "${PROJECT_ROOT}/docs/"
```

**Determine mode:**

```bash
# STANDARD/COMPREHENSIVE mode: Design document exists
ls "${PROJECT_ROOT}/docs/designs/{feature}/" 2>/dev/null && echo "STANDARD mode"

# BRIEF mode: No design doc, work from brainstorm + PRD
ls "${PROJECT_ROOT}/docs/brainstorm/{feature}/brainstorm.md" 2>/dev/null && echo "BRIEF mode"
```

**Import upstream artifacts:**

```bash
# Design docs (primary input for STANDARD+)
ls "${PROJECT_ROOT}/docs/designs/{feature}/"

# PRD for requirement traceability
cat "${PROJECT_ROOT}/docs/prd/{feature}/prd.md" 2>/dev/null

# Work decomposition from design
grep -A 50 "Work Decomposition" "${PROJECT_ROOT}/docs/designs/{feature}/design.md" 2>/dev/null

# Learnings from past features
ls "${PROJECT_ROOT}/docs/learnings/" 2>/dev/null
```

---

## Critical Sequence

### Phase 1: Decomposition

**Step 1.1 — Choose Decomposition Strategy:**

Default to **vertical slicing** — each task delivers a thin, end-to-end slice of functionality across all layers. This produces testable increments at every step and de-risks integration.

Use **horizontal layering** only for genuine shared prerequisites that multiple features depend on (database schema, auth infrastructure, CI pipeline). Mark these as "Phase 0: Foundation" and keep them minimal.

| Strategy | When to Use | Example |
|----------|------------|---------|
| **Vertical slice** | Feature work, user-facing capabilities | "Create widget: schema + endpoint + UI + test" as one task |
| **Horizontal layer** | Shared infrastructure, platform changes | "Database migration for all new entities" as foundation |
| **Hybrid** (most common) | Typical features with shared prereqs | Foundation layer first, then vertical feature slices |

**Step 1.2 — Import or Create Decomposition:**

**STANDARD+ mode:** If the technical design includes a Work Decomposition section, import it as the starting point. Restructure into vertical slices if it was decomposed horizontally.

**BRIEF mode:** Decompose directly from brainstorm boundaries and PRD:
- Each Must-Have requirement becomes a task or part of a vertical slice
- Group related requirements into coherent behaviour units
- Create a simple dependency order

**Step 1.3 — Size Each Task:**

| Signal | Too Small | Right Size | Too Large |
|--------|-----------|------------|-----------|
| Scope | Single trivial change | One coherent behaviour change | Multiple unrelated behaviours |
| Files | 1 file, trivial | 2-8 related files | 15+ across unrelated concerns |
| Testability | Nothing meaningful to test | Clear acceptance test(s) | Requires a test plan of its own |
| Description | "Add import statement" | "Add endpoint for creating widgets with validation and persistence" | "Implement the widget subsystem" |

**The leaf-node test:** If a task can be split into sub-tasks that are independently testable, split it. If splitting creates tasks that only make sense together, it's correctly sized.

**Step 1.4 — Map FRs to Tasks:**

Every Must-Have FR from the PRD must appear in at least one task.

```markdown
### FR Coverage
| FR | Task(s) | Status |
|----|---------|--------|
| FR-{MODULE}-{NAME} | T01, T03 | ✅ Covered |
| FR-{MODULE}-{NAME} | T02 | ✅ Covered |
| FR-{MODULE}-{NAME} | — | ⚠ Gap (deferred?) |
```

Flag any uncovered Must-Have FRs as blocking issues.

**Step 1.5 — Order by Risk and Dependency:**

Neither pure "risk-first" nor pure "foundation-first" is optimal. Use this sequence:

```
Phase 0: Foundation (minimal scaffolding, shared prerequisites)
         → Only genuine blockers. If it's not blocking Phase 1, it's not foundation.

Phase 1: High-Risk / Core (the riskiest or most uncertain work)
         → Integration points, novel patterns, performance-critical paths
         → Prove these early. If they fail, the design needs revision.

Phase 2: Feature Slices (the bulk of the work, vertical slices by value)
         → Group by domain area. Mark parallelisable tasks.
         → Each slice is independently testable and demoable.

Phase 3: Polish (edge cases, error handling, performance, UX refinements)
         → Only after core functionality is proven.
```

**Step 1.6 — Map Dependencies:**

```markdown
### Dependency Graph

  T01 (schema) ──> T02 (create widget) ──> T05 (widget detail view)
       |                |
       +──> T03 (list widgets) ──> T06 (search/filter)
       |
       +──> T04 (external API integration)

### Critical Path
T01 → T02 → T05 → T08 (longest chain: {N} tasks)

### Parallelisable
T03 and T04 can run in parallel after T01.
```

Verify: no circular dependencies. Every task has explicit "Depends on" and "Blocks" relationships.

**PAUSE 1:** Present the decomposition, FR coverage, and ordering to the user.
"Here's how I've broken down the work: {N} tasks across {N} phases. The critical path is {chain}. Does this decomposition look right? Any tasks missing or mis-ordered?"

---

### Phase 2: Overview Document

Create `${PROJECT_ROOT}/docs/plans/{feature}/overview.md`:

```markdown
# Implementation Plan: {Feature Name}

> Plan for implementing {feature} based on the approved technical design.

## References
- Design: `docs/designs/{feature}/design.md`
- PRD: `docs/prd/{feature}/prd.md`
- Discovery: `docs/discovery/{feature}/discovery-brief.md` (if exists)

## Decomposition Strategy
{Vertical slicing / Horizontal foundation + vertical slices / etc.}
{Brief rationale for the chosen strategy.}

## Cross-Cutting Concerns
- **Testing:** {Strategy — unit tests per task, integration tests for workflows, etc.}
- **Configuration:** {Approach — environment variables, service defaults, etc.}
- **Error Handling:** {Pattern — validation layer, global error middleware, etc.}
- **Observability:** {Logging, metrics, alerting approach from design's operational section}

## Task Summary
| # | Task | Phase | Complexity | Risk | Depends On | Implements |
|---|------|-------|-----------|------|------------|-----------|
| T01 | {title} | 0: Foundation | S | Low | — | — |
| T02 | {title} | 1: Core | M | High | T01 | FR-{NAME} |
| T03 | {title} | 2: Feature | M | Low | T01 | FR-{NAME} |
| ... | ... | ... | ... | ... | ... | ... |

## FR Coverage
{Table from Phase 1.4}

## Dependency Graph
{ASCII diagram from Phase 1.6}

## Critical Path
{Longest dependency chain with task IDs}

## Risk Register (COMPREHENSIVE only)
| Risk | Phase/Task | Likelihood | Impact | Mitigation |
|------|-----------|-----------|--------|------------|
| {risk} | T02 | Med | High | {approach} |

## Testing Summary
| Task | Unit Tests | Integration Tests | E2E Tests |
|------|-----------|------------------|-----------|
| T02 | Validation logic | Endpoint contract | — |
| T05 | — | — | Widget creation flow |

## Sub-Plans
| # | File | Phase | Complexity |
|---|------|-------|-----------|
| T01 | `01-foundation.md` | 0 | S |
| T02 | `02-create-widget.md` | 1 | M |
| ... | ... | ... | ... |

---
*Plan created: {date}*
*Based on approved design: {date}*
```

---

### Phase 3: Sub-Plan Documents (STANDARD + COMPREHENSIVE)

**BRIEF mode skips this phase** — the overview IS the plan with inline task descriptions.

For each task, create `NN-{task-name}.md`:

```markdown
# Sub-Plan: {Task Title}

## Traceability
- **Implements:** FR-{MODULE}-{NAME}, FR-{MODULE}-{NAME}
- **Design Reference:** `docs/designs/{feature}/{relevant-file}.md`
- **Validates Against:** BDD scenarios tagged @UC-{MODULE}-{NNN} (if applicable)

## Prerequisites
- [ ] {Previous task} completed
- [ ] {Required infrastructure in place}

## Intent

### What to Build
{High-level description of what this task delivers and why it matters
in the overall plan. Reference the design doc for detailed specs.
This should be 2-4 sentences, not a paragraph.}

### Key Design Decisions
{Summarise relevant decisions from the design's Alternatives section.
"We chose X over Y because Z — see design.md for full analysis."
Only include decisions that affect THIS task.}

### Patterns to Follow
{Which existing codebase patterns to follow.
"Follow the pattern established in {ExistingModule} for {pattern type}."
Check project CLAUDE.md for pattern references.}

## Scope

### In Scope
- {Specific deliverable 1}
- {Specific deliverable 2}

### Out of Scope
- {What this task does NOT include — handled by other tasks}

## Context to Load
{Specific files the executing agent should read:}
- `docs/designs/{feature}/{file}` — {what to learn from it}
- `src/{project}/{folder}/` — {existing pattern to follow}

## Acceptance Criteria
{From the PRD's FR definitions — the Given/When/Then criteria
that the executing agent must satisfy.}

  Given {precondition}
  When {action}
  Then {expected result}

  Given {error condition}
  When {error action}
  Then {error handling result}

## Verification
- [ ] {Testable assertion 1}
- [ ] {Testable assertion 2}
- [ ] {Edge case assertion}
```

**What sub-plans contain:**
- Intent (what and why)
- Scope boundaries (in/out)
- Context references (what to read)
- Acceptance criteria (what "done" means)
- Design decision summaries (why this approach)

**What sub-plans do NOT contain:**
- Source code or implementation steps (that's the agent's job during /execute)
- Commit messages or test commands (that's /beads territory)
- Duplicated design doc content (reference it, don't copy it)

The boundary: **plans say WHAT to build. Beads say HOW to execute it.** /beads reads these sub-plans and adds execution-level detail (specific files to modify, test commands, commit messages, failure criteria).

---

### Phase 4: Self-Review

**2 rounds minimum. Exit on 2 consecutive clean rounds.**

**Theme 1: Completeness**
- [ ] Every Must-Have FR covered by at least one task?
- [ ] Every task has acceptance criteria?
- [ ] Cross-cutting concerns addressed (testing, config, observability)?
- [ ] Dependencies between tasks are explicit?

**Theme 2: Right-Sizing**
- [ ] No task too large (multiple unrelated behaviours)?
- [ ] No task too small (trivial, nothing meaningful to test)?
- [ ] Each task independently testable?
- [ ] Agent can complete each task in a single focused session?

**Theme 3: Ordering**
- [ ] High-risk items in early phases?
- [ ] No circular dependencies?
- [ ] Critical path identified and prioritised?
- [ ] Parallelisable tasks marked?

**Theme 4: Traceability**
- [ ] Every task lists FRs it implements?
- [ ] FR coverage table has no gaps for Must-Haves?
- [ ] Design decisions summarised in relevant sub-plans?

**Theme 5: Clarity**
- [ ] Intent clear without being implementation-specific?
- [ ] Scope boundaries (in/out) defined per task?
- [ ] Context references point to actual files?
- [ ] A developer (or agent) could pick up any sub-plan and understand what to build?

**Known limitation:** Self-review is performed by the same agent that wrote the plan. Mitigate by following themes as a checklist. Invite the user to spot-check the tasks they're least confident about.

**PAUSE 3:** Present completed plan with summary.

```markdown
## Implementation Plan Complete

**Feature:** {name}
**Mode:** {BRIEF | STANDARD | COMPREHENSIVE}
**Tasks:** {N} across {N} phases
**Critical path:** {task chain} ({N} tasks)
**FR coverage:** {N}/{N} Must-Haves covered
**Risk items:** {N} tasks flagged as high-risk (addressed in Phase 1)

Ready for review:
1. "plan approved" → Proceed to /beads
2. "refine {task}" → Iterate on specific task
3. "reorder" → Change task sequencing
4. "park" / "abandon"
```

---

## BRIEF Mode Template

For BRIEF mode, produce a single `overview.md`:

```markdown
# Implementation Plan: {Feature Name}

**PRD:** `docs/prd/{feature}/prd.md`
**Date:** {today}

## Tasks

### T01: {Title} [Foundation]
**Implements:** FR-{NAME}
**What:** {2-3 sentences describing intent}
**Acceptance:** {Given/When/Then from PRD}
**Depends on:** None

### T02: {Title} [Core]
**Implements:** FR-{NAME}, FR-{NAME}
**What:** {2-3 sentences}
**Acceptance:** {criteria}
**Depends on:** T01

### T03: {Title} [Feature]
...

## Dependency Order
T01 → T02 → T03

---
*Plan created: {date}*
```

---

## Output Structure

```
${PROJECT_ROOT}/docs/plans/{feature}/
├── overview.md              # Decomposition, ordering, FR coverage, cross-cutting concerns
├── 01-foundation.md         # Sub-plan (STANDARD+)
├── 02-create-widget.md      # Sub-plan
├── 03-list-widgets.md       # Sub-plan
├── 04-integration.md        # Sub-plan
└── ...
```

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "plan approved" | Plan complete | Proceed to /beads |
| "refine" | Gaps or ordering issues | Return to relevant phase |
| "park" | Save for later | Archive; user resumes later |
| "abandon" | Don't build this | Document decision rationale |

**On approval:** "Plan approved. Run /beads to create executable work packages."

---

## Anti-Patterns

**Horizontal-Only Decomposition** — "Task 1: All database work. Task 2: All API work. Task 3: All UI." No testable increment until the last task. Default to vertical slices instead.

**Deferred Risk** — Saving integrations and hard problems for the end. If the external API doesn't work as expected, you want to know in Phase 1, not Phase 5.

**Testing as Phase N** — "Phase 4: Write all the tests." Each task should include its own test expectations. Testing is part of every task, not a separate phase.

**The 200-Task Plan** — Over-decomposing into trivial tasks. If a task is "add import statement", it's too small. Merge into coherent behaviour units.

**Plan-as-Design** — If writing the plan surfaces architectural decisions, the design is incomplete. Plans decompose decisions already made, they don't make new ones.

**Copy-Paste Sub-Plans** — Duplicating design doc content into every sub-plan. Reference it instead. Duplication drifts and creates conflicting sources of truth.

---

## Reference Files

For project-specific patterns: check project CLAUDE.md for pattern reference files
For ASCII diagram conventions: `_shared/references/ascii-conventions.md`

---

*Skill Version: 3.0*
*v3: Vertical slicing default, risk-based ordering, collaborative PAUSE points, cross-cutting concerns, sizing heuristics, cleaner plan/beads boundary, BRIEF/STANDARD/COMPREHENSIVE modes, anti-patterns*
