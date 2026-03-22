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

**Duration targets:** BRIEF ~15-20 minutes, STANDARD ~30-60 minutes, COMPREHENSIVE ~1-2 hours. Most time should be spent on Phase 1 (decomposition and ordering). If you're spending more time writing sub-plans than thinking about task boundaries, the balance is wrong.

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

## Stage Gates — AskUserQuestion

At every PAUSE point in this skill, **call the `AskUserQuestion` tool** to present structured options to the user. Do not present options as plain markdown text — use the tool. The YAML blocks at each PAUSE point show the exact parameters to pass.

For pattern details and examples: `../_shared/references/stage-gates.md`

> **Fallback:** Only if `AskUserQuestion` is not available as a tool (check your tool list), fall back to presenting options as markdown text and waiting for freeform response.

---

## Mode Selection

| Mode | Input Required | When | Output |
|------|---------------|------|--------|
| **BRIEF** | Brainstorm + PRD (no design doc) | BRIEF scope, simple changes | Single `overview.md` with inline tasks |
| **STANDARD** | Design document | STANDARD scope, typical feature | `overview.md` + sub-plan files |
| **COMPREHENSIVE** | Design document | COMPREHENSIVE scope, multi-service | `overview.md` + sub-plans + risk register + cross-cutting concerns doc |

BRIEF mode produces a single file with 3-6 tasks. No sub-plan files — the overview IS the plan. BRIEF skips: Phase 3 (sub-plans), Phase 3b (companion docs), and the Dependency Graph/Critical Path sections from Phase 1.

---

## Collaborative Model

```
Phase 0: Import & Prerequisites
Phase 1: Decomposition (with kill criteria check)
  ── PAUSE 1: "Here's the decomposition. Right tasks? Right order?" ──
Phase 2: Overview Document
Phase 3: Sub-Plans (STANDARD+)
Phase 3b: Companion Documents (COMPREHENSIVE only)
Phase 4: Self-Review (before presenting to user)
  ── PAUSE 2: "Plan complete. Approve for /beads?" ──
```

---

## Prerequisites

**Step 0 — Resolve and Import:**

Import upstream artifacts into the planning workspace:
- **Design docs** (primary input for STANDARD+) — `docs/designs/{feature}/` (architecture, data model, API spec, sequences)
- **PRD** — `docs/prd/{feature}/prd.md` (requirement traceability — every Must-Have FR must be covered)
- **Work decomposition from design** — the "Work Decomposition" section of `docs/designs/{feature}/design.md` is the starting point for Phase 1
- **Brainstorm** — `docs/brainstorm/{feature}/brainstorm.md` (scope classification, kill criteria)
- **Use cases** — `docs/prd/{feature}/use-cases/` and `docs/use-cases/` (for BDD scenario references in sub-plans)
- **Browser E2E plans** — `docs/browser-e2e-plans/` (if exists, for COMPREHENSIVE companion docs)
- **ADRs** — `docs/adr/` (architecture decision records informing decomposition choices)
- **Patterns** — `docs/patterns/` (established patterns for pattern references in sub-plans)
- **Learnings** — `docs/learnings/` (relevant compound learnings from past features)

Create the output directory: `docs/plans/{feature}/`

Do not re-interview the user for context that exists in these artifacts. Import it, reference it, build on it.

---

## Critical Sequence

### Phase 1: Decomposition

**Step 1.0 — Kill Criteria Check:**

Review kill criteria from brainstorm output before investing in detailed planning. During decomposition, check whether the work scope threatens any kill criterion:
- Does the task count or complexity suggest the feature is larger than brainstorm estimated?
- Do dependencies reveal timeline risks that threaten kill criteria?
- Are there integration unknowns that could block the critical path?

If a kill criterion is violated or at serious risk: "Kill criterion '{criterion}' appears at risk because decomposition reveals {reason}. Recommend returning to brainstorm to reassess scope before continuing to plan."

**Step 1.0b — Implementation Gap Analysis (run BEFORE decomposition):**

This is the most important step for any module where code may already exist. Run it BEFORE choosing a decomposition strategy — the results determine whether this is a greenfield plan, an alignment plan, or a verification checklist.

```
IF Implementation Status shows > 90% "Exists":
  → Verification Mode: produce gap-analysis.md + single verification sub-plan + companion docs
  → No separate sub-plan files per task (the remaining work is too small to justify them)
  → The gap analysis IS the plan — it identifies what to fix, verify, and test

IF Implementation Status shows > 70% "Exists" (but < 90%):
  → Non-Greenfield Fast Path: derive tasks from gaps, not design work decomposition
  → Skip importing design's Work Decomposition section
  → Tasks focus on "what to change" not "what to build"
  → Companion docs focus on verification, not new behavior

IF Implementation Status shows < 30% "Exists":
  → Greenfield Path: standard decomposition from design
  → Import design Work Decomposition as starting point

ELSE:
  → Hybrid: some greenfield tasks, some modification tasks
```

**Gap analysis is the single source of truth.** The gap-analysis.md file (or the overview's Implementation Status table) is the authoritative record of what exists, what needs modification, and what's new. Do NOT duplicate this information across overview, gap analysis, and sub-plans — reference it. The overview's Design Coverage table can summarize with a single line ("44/44 exist — see gap-analysis.md for modification details") when all elements exist.

**Design feedback:** If the gap analysis or decomposition reveals a design-level issue (architectural tension, missing specification, contradicted assumption), document it as a `## Design Feedback` section in the overview — not buried in sub-plan context paragraphs. This surfaces issues that should go back to `/technical-design` without blocking plan completion.

**Agent efficiency:** Do NOT use Explore agents for gap analysis — they over-report existence without catching field-level gaps. Use targeted Grep/Glob for element-by-element checks:
- Grep for class names to confirm existence
- Read specific files to compare properties/fields against design
- Count test attributes (`[Fact]`, `[Theory]`, `it(`) to get precise test coverage

Explore agents are useful for initial context loading (Phase 0) but not for the gap analysis itself.

**Re-planning (overwriting existing plans):** When a plan directory already exists:
1. Read the old plan's overview to understand prior state
2. Run gap analysis against current code (not old plan)
3. Remove old sub-plan files before writing new ones
4. Note in the overview what changed from the prior plan and why

**PAUSE 1 presentation:** Show the FR Coverage table, UC Coverage table, and Dependency Graph as formatted markdown BEFORE the AskUserQuestion. The user cannot approve what they cannot see. For non-greenfield plans with ≤8 tasks, present task summary + gap highlights + dependency graph inline, with full coverage tables in overview.md.

**Test coverage as first-class step:** For non-greenfield plans, count existing tests precisely (grep for test attributes, map to design test cases) rather than estimating. The gap between "~37 tests" and "32 tests" matters when planning test tasks.

**Step 1.2 — Choose Decomposition Strategy:**

Default to **vertical slicing** — each task delivers a thin, end-to-end slice of functionality across all layers. This produces testable increments at every step and de-risks integration.

Use **horizontal layering** only for genuine shared prerequisites that multiple features depend on (database schema, auth infrastructure, CI pipeline). Mark these as "Phase 0: Foundation" and keep them minimal.

| Strategy | When to Use | Example |
|----------|------------|---------|
| **Vertical slice** | Feature work, user-facing capabilities | "Create widget: schema + endpoint + UI + test" as one task |
| **Horizontal layer** | Shared infrastructure, platform changes | "Database migration for all new entities" as foundation |
| **Hybrid** (most common) | Typical features with shared prereqs | Foundation layer first, then vertical feature slices |
| **Gap-driven** (non-greenfield) | >70% exists, alignment/refactoring work | Tasks derived from gap analysis: "Fix result type pattern", "Add missing audit events" |

**Step 1.3 — Import or Create Decomposition:**

**Non-greenfield (>70% exists):** Skip the design's Work Decomposition section — it describes greenfield build. Instead, derive tasks directly from the Implementation Gap Analysis (Step 1.4d): each "Modify" or "New" element becomes a task or part of a task. Group related modifications into coherent change sets.

**Greenfield (<30% exists):** Import the design's Work Decomposition section as the starting point. Restructure into vertical slices if decomposed horizontally.

**Hybrid (30-70% exists):** Import design Work Decomposition for new elements, derive modification tasks from gap analysis for existing elements.

**Align with design's feature decomposition:** If the design uses feature-first decomposition (`docs/designs/{feature}/features/{sub-feature}/`), sub-plans should mirror this structure. Each design feature area typically maps to one sub-plan (e.g., `features/applications/` → `02-application-feature.md`). This alignment ensures sub-plans can directly reference their feature's api-surface.md, test-plan.md, and ui-mockup.md without ambiguity.

**BRIEF mode:** Decompose directly from brainstorm boundaries and PRD:
- Each Must-Have requirement becomes a task or part of a vertical slice
- Group related requirements into coherent behaviour units
- Create a simple dependency order

**Step 1.4 — Size Each Task:**

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

Flag any uncovered Must-Have FRs as blocking issues. If the project uses an issue tracker, offer to create tracked items: "These Must-Have FRs have no covering task. Want me to create tracked issues for them?"

**Step 1.4b — Map UCs to Tasks:**

Every use case from the PRD must be executable end-to-end across the task sequence. A UC may span multiple tasks — that's fine, but the full scenario flow must be covered. If tasks covering a UC can run in parallel (per the dependency graph), verify the UC has no ordering dependency between them.

```markdown
### UC Coverage
| UC | Title | Tier | Task(s) | Ordering | End-to-End? |
|----|-------|------|---------|----------|-------------|
| UC-{MODULE}-001 | {title} | 1 | T02, T03, T05 | Sequential (T02→T03→T05) | ✅ Full scenario covered |
| UC-{MODULE}-002 | {title} | 2 | T03 | Single task | ✅ Covered |
| UC-{MODULE}-003 | {title} | 1 | T02 | — | ⚠ Steps 3-5 not covered (failure paths) |
```

For Tier 1 UCs, verify:
- Every scenario step has a covering task
- Every failure path has a covering task
- Every business rule (BR-*) maps to a validation task
- If UC tasks are parallelizable, the UC doesn't require them in sequence

UC Coverage gap handling:
- **Tier 1 UC gap** → blocker, do not proceed until resolved
- **Tier 2 UC gap** → may be deferred with explicit owner and rationale
- **UC tied to scope-excluded FR** → mark as `Scope Exclusion` in the table, not as a gap or blocker. Reference the design's Scope Exclusions section. This is NOT a planning failure — it's an intentional design decision.

**Step 1.4c — Design Coverage Matrix:**

Every design element (endpoint, entity, command, query, contract, mapper) must have a covering task. This goes beyond FR coverage — a design may specify 6 endpoints for a single FR.

```markdown
### Design Coverage
| Design Element | Type | Source File | Task | Status |
|---------------|------|------------|------|--------|
| POST /api/v1/widgets | endpoint | api-surface.md | T03 | ✅ Covered |
| WidgetDTO | contract | api-surface.md | T02 | ✅ Covered |
| SaveWidgetCommand | command | api-surface.md | T03 | ✅ Covered |
| GetWidgetQuery | query | api-surface.md | T04 | ✅ Covered |
| Widget entity | entity | data-model.md | T01 | ✅ Covered |
| widget.saved audit | audit | design.md | — | ⚠ Gap |
```

Derive the element list from the design's api-surface files (endpoints, contracts, commands, queries) and data-model (entities, migrations). Flag gaps as blocking issues.

**Step 1.4d — Implementation Gap Analysis (Run FIRST — see Step 1.1):**

Check what's already built before decomposing. This is the most important step for non-greenfield work — it determines whether the plan is a build plan or an alignment plan.

**Structured checklist** — for each design element type, search the codebase:

```
For each entity in data-model.md:
  [ ] Entity class exists? Schema matches?
  [ ] EF Configuration exists? Indexes, constraints match?
  [ ] Migration exists?

For each feature area in api-surface.md:
  [ ] Contracts (DTO, Request, Response) exist? Fields match?
  [ ] EntityMapper exists? Uses correct pattern?
  [ ] DTOMapper exists? Uses correct pattern?
  [ ] Commands exist? Return types match design?
  [ ] Queries exist? Include correct navigations?
  [ ] Validators exist? Rules match design?
  [ ] Endpoints exist? Routes, verbs, auth policies match?

For each frontend feature in ui-mockup.md:
  [ ] Models/interfaces exist?
  [ ] Feature service exists?
  [ ] List/grid page exists?
  [ ] Capture/form page exists?
  [ ] Routing configured?

Cross-cutting:
  [ ] DI registration exists?
  [ ] Audit events wired?
  [ ] Tests exist? Coverage sufficient?
```

Use targeted Grep/Glob for this — an Explore agent is overkill for element-by-element checks.

```markdown
### Implementation Status
| Design Element | Type | Status | Notes |
|---------------|------|--------|-------|
| Widget entity | entity | ✅ Exists | Schema matches design |
| WidgetDTO | contract | ✅ Exists | Missing new field "Category" |
| SaveWidgetCommand | command | ⚠ Modify | Exists but uses old return type pattern (need updated pattern per design decision) |
| GetWidgetQuery | query | ❌ New | Not yet implemented |
| Widget grid UI | frontend | ❌ New | Not yet implemented |
```

Mark each element as:
- **New** — nothing exists, build from scratch per design
- **Modify** — exists but needs changes to match design (specify WHAT changes)
- **Exists** — already matches design, verify only (no bead needed unless verification fails)

For greenfield features, every element is "New" — but still document the table to confirm nothing was assumed to exist.

**Task sizing for modifications** (different from greenfield):

| Modification Type | Size | Example |
|-------------------|------|---------|
| Pattern replacement (same logic, new type) | S | Change return type from old pattern to new per design decision |
| Field addition (cascades to DTO + mapper + tests) | M | Add `Category` field across entity, DTO, mapper, validator |
| Behavioral change (new logic path) | L | Add audit event wiring where none existed |
| Architecture change (cascading rework) | XL | Move from commands to event-driven pattern |

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

**PAUSE 1:** Guided Review Workflow — adaptive depth based on task count.

**For ≤ 8 tasks:** Present Task Summary + Dependency Graph in chat, with a note "Full coverage tables (FR, UC, Design) will be in overview.md." Use a single approval gate.

**For > 8 tasks:** Walk the user through the decomposition section by section using the multi-step flow below.

**For non-greenfield (>70% exists):** Present only Task Summary + gap summary + Dependency Graph. The full coverage tables are dominated by "Covered/Exists" rows — presenting them in chat is noise. Reference overview.md for the full tables.

**Step 1:** Present the Task Summary table as formatted markdown (from Step 1.3/1.4 output).

**Step 2:** AskUserQuestion — Batch Review (Pattern 3) for task validation:

```
AskUserQuestion:
  question: "Which tasks need adjustment? (Unselected tasks are approved)"
  header: "Tasks"
  multiSelect: true
  options:    # Up to 4 tasks per batch
    - label: "T01: {title}"
      description: "Phase 0: Foundation — Complexity S"
    - label: "T02: {title}"
      description: "Phase 1: Core — Complexity M"
    - label: "T03: {title}"
      description: "Phase 2: Feature — Complexity M"
    - label: "T04: {title}"
      description: "Phase 2: Feature — Complexity S"
```

Repeat with additional batches if there are more than 4 tasks. For any tasks flagged for adjustment, collect the user's notes and iterate before continuing.

**Step 3:** Present the FR Coverage table (from Step 1.4), UC Coverage table (from Step 1.4b), and Design Coverage table (from Step 1.4c) as formatted markdown, then:

```
AskUserQuestion:
  question: "Is FR coverage complete?"
  header: "FR Coverage"
  multiSelect: false
  options:
    - label: "Complete (Recommended)"
      description: "All Must-Have FRs covered, all Tier 1 UCs end-to-end, all design elements mapped."
    - label: "Has gaps"
      description: "Some FRs, UCs, or design elements are missing task coverage."
    - label: "Need to adjust"
      description: "Coverage mappings need changes."
```

**Step 4:** Present the Dependency Graph and Critical Path (from Step 1.6), then:

```
AskUserQuestion:
  question: "Does the ordering and critical path look right?"
  header: "Ordering"
  multiSelect: false
  options:
    - label: "Correct (Recommended)"
      description: "Task ordering and critical path are right. Proceed to write overview and sub-plans."
    - label: "Reorder"
      description: "Some tasks should come earlier or later."
    - label: "Escalate"
      description: "Decomposition reveals the design is incomplete. Return upstream."
```

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

## UC Coverage
{Table from Phase 1.4b}

## Design Coverage
{Table from Phase 1.4c}

## Implementation Status
{Table from Phase 1.4d — always present, even if all "New" for greenfield}

## Design Feedback (if any)
{Issues discovered during planning that should go back to /technical-design.
Architectural tensions, missing specifications, contradicted assumptions.
These don't block the plan but should be addressed in the design.}

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

> Part of [{Feature Name} Plan](overview.md)

## Traceability
- **Implements:** FR-{MODULE}-{NAME}, FR-{MODULE}-{NAME}
- **Design Reference:** `docs/designs/{feature}/{relevant-file}.md`
- **Validates Against:** BDD scenarios tagged @UC-{MODULE}-{NNN} (if applicable)

## Prerequisites
- [ ] {Previous task} completed
- [ ] {Required infrastructure in place}

## Objective

{2-4 sentences — what this task delivers and why it matters in the
overall plan. Reference the design doc for detailed specs.}

## Context

{Situational context: what exists already, what this task builds on,
what the executing agent needs to understand before starting.}

## Tasks

### Task N: {Task Title}

**Objective:** {One sentence — what this task accomplishes.}

**Approach:**
{Brief prose description of the implementation strategy. Reference
design decisions: "We chose X over Y because Z — see design.md."}

**Pseudocode:** (include when the design produced algorithmic detail)
```
{Pseudocode showing data flow, branching logic, and entity relationships.
This is algorithmic intent — NOT compilable source code.
Include: entity creation patterns, validation logic, mapper flows,
command/query structure, endpoint wiring.
Omit: imports, DI registration, boilerplate, exact method signatures.}
```

**Contract Shapes:** (include when task defines or modifies contracts)
```
{DTO/request/response structure definitions showing fields and types.
These come from the design's api-surface.md — reference, don't reinvent.}
```

**Pattern Reference:**
- {Specific file that establishes the pattern to follow}
- {Location where the new code should live}
- {Design doc section with full specs}

**Success Criteria:**
- {Testable assertion — what must be true when done}

**Failure Criteria:** (REQUIRED for implementation tasks. Verification/audit tasks may omit when there are no rejected alternatives — success criteria serve as the constraint.)
- {What NOT to do — from design decisions: "Do NOT use [rejected approach] — use [chosen approach] per [decision reference]"}
- {Rejected alternative — from design: "Do NOT use [alternative B] for [concern] — use [alternative A] per design decision [slug]"}
- {Pattern constraint — "Do NOT [anti-pattern] — use [correct pattern] per project pattern doc"}

To extract failure criteria, read the design's decision records (decisions/*.md):
1. For each task, identify which design decisions apply
2. Read the "Rejected Alternatives" or "Cons" from the decision record
3. Quote the rejected approach verbatim as a "Do NOT"
4. Include the ADR/decision reference so the executing agent can verify

---

{Repeat for each task in this sub-plan}

## Component Success Criteria

- {Overall criteria for this sub-plan as a whole}

## References

- {Links to design docs, api-surface, test-plan, use cases}
```

**What sub-plans contain:**
- Objective and context (what and why)
- Implementation guidance: pseudocode, contract shapes, pattern references (design-level intent)
- Failure criteria (what NOT to do — prevents re-deriving design constraints)
- Scope boundaries (in/out)
- Context references (what to read)
- Acceptance criteria (what "done" means)
- Design decision summaries (why this approach)

**What sub-plans do NOT contain:**
- Compilable source code (pseudocode is algorithmic intent, not code)
- Commit messages or git workflow (that's /beads territory)
- Specific file modification lists as checklists (that's /beads territory)
- Duplicated design doc content (reference it, don't copy it)
- Test commands or CI pipeline steps (that's /beads territory)

The boundary: **plans describe WHAT to build with enough implementation guidance to prevent the executing agent from re-deriving design decisions. Beads add execution mechanics: file modification lists, commit messages, test commands, and session structure.** Pseudocode, contract shapes, and failure criteria are plan-level concerns because they encode design intent. Git workflow, file lists, and test commands are bead-level concerns because they encode execution mechanics.

**Step 3.1 — Reconcile Overview:**

After writing all sub-plans, review whether the overview needs updating. Sub-plans may reveal:
- A task was harder than estimated — update complexity in Task Summary
- A dependency was missed — update Dependency Graph
- An FR was partially covered — update FR Coverage table
- A task should be split — add new rows to Task Summary and Sub-Plans table

Update the overview to reflect what sub-plans actually contain, so the overview remains the single source of truth for plan structure.

---

### Phase 3b: Companion Documents (COMPREHENSIVE only)

For COMPREHENSIVE plans, produce these companion documents alongside the sub-plans. These are living documents — updated during implementation as tests are written and security findings are addressed.

**Scope-aware companion docs:** For plans where >70% of Implementation Status is "Exists" (non-greenfield), companion docs should focus on **verification of existing behavior** rather than planning new behavior:
- E2E test plans become smoke tests verifying existing flows still work after modifications
- Security checklists become audit checklists verifying existing controls
- Test matrices document existing test coverage and identify gaps, not plan all-new tests

**Step 3b.1 — E2E Test Plan:**

Save to: `${PROJECT_ROOT}/docs/plans/{feature}/e2e-test-plan.md`

```markdown
# End-to-End Test Plan: {Feature Name}

> Acceptance-level validation for {feature} against the active architecture.

## Scope

{What this E2E plan validates — integrated behavior across which layers.}

Out of scope for pass criteria:
- {Explicitly excluded areas}

## Environment

- {Required infrastructure — databases, caches, external services}
- {Test data setup requirements}

## Smoke Checks

- {Health endpoints, startup validation, seed data visibility}

## Critical Path Scenarios

### 1. {Primary workflow}
1. {Step 1}
2. {Step 2}
...
{Validate state changes, audit records, version increments}

### 2. {Concurrency/isolation}
### 3. {Error handling/recovery}
### 4. {Cross-cutting concerns}
```

**Step 3b.2 — Security Hardening Checklist:**

If the design's security analysis identified security requirements, operationalize them as a prioritized checklist. This turns security findings from the design/review into trackable implementation items.

Save to: `${PROJECT_ROOT}/docs/plans/{feature}/security-hardening-checklist.md`

```markdown
# Security Hardening Checklist: {Feature Name}

## Scope

This checklist operationalizes security requirements from the design's
security analysis and any adversarial review findings.

## Priority 0 (Blocker)

- [ ] {Critical security requirement — e.g., RLS migration parity}
  - [ ] {Sub-item with specific verification}
  - [ ] {Sub-item}

## Priority 1 (High)

- [ ] {High-priority security requirement}
  - [ ] {Verification step}

## Priority 2 (Medium)

- [ ] {Medium-priority requirement}

## Exit Criteria

- [ ] All Priority 0 items complete and merged
- [ ] All Priority 1 items complete and merged
- [ ] Priority 2 items complete or explicitly deferred with owner and target date
```

Skip this document if the design's security analysis concluded "No significant security implications."

**Step 3b.3 — Test Scenario Matrix:**

Maps every use case to planned test classes and methods. This is a living document updated during implementation — initial version captures planned coverage, implementation fills in actual test evidence.

Save to: `${PROJECT_ROOT}/docs/plans/{feature}/test-scenario-matrix.md`

```markdown
# Test Scenario Matrix

> Maps every use case to implemented unit, integration, and architecture tests.
> Living document — update when tests are added or modified.

## Summary

| Metric | Count |
|--------|-------|
| Test projects | {N} |
| Use cases covered | {N}/{N} |
| Planned test cases | {N} |

## Use Case → Test Mapping

### UC-{MODULE}-{NNN}: {Title}

| Layer | Test Class | Tests | Count |
|-------|-----------|-------|-------|
| Unit | `{Validator}Tests` | {test method names} | {N} |
| Integration | `{Lifecycle}Tests` | {test method names} | {N} |
| **Total** | | | **{N}** |
```

Derive initial test mapping from the design's per-feature test plans. During implementation, update with actual test class names and method counts.

---

### Phase 4: Self-Review

**2 rounds minimum. Exit on 2 consecutive clean rounds.**

Run self-review BEFORE presenting to the user. The agent should catch its own issues rather than showing unreviewed work.

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

**Theme 6: Plan/Beads Boundary**
- [ ] Pseudocode is algorithmic intent, not compilable source code?
- [ ] Contract shapes match design's api-surface definitions (not invented here)?
- [ ] No sub-plan contains commit messages, git workflow, or test commands?
- [ ] No sub-plan contains file modification checklists (that's /beads)?
- [ ] Implementation guidance encodes design decisions, not execution mechanics?

**Known limitation:** Self-review is performed by the same agent that wrote the plan. Mitigate by following themes as a checklist. Invite the user to spot-check the tasks they're least confident about.

**PAUSE 2:** Decision Gate (Pattern 1 from stage-gates.md) — present the plan summary and ask for approval.

Present the plan summary as formatted markdown:

```markdown
## Implementation Plan Complete

**Feature:** {name}
**Mode:** {BRIEF | STANDARD | COMPREHENSIVE}
**Tasks:** {N} across {N} phases
**Critical path:** {task chain} ({N} tasks)
**FR coverage:** {N}/{N} Must-Haves covered
**Risk items:** {N} tasks flagged as high-risk (addressed in Phase 1)
```

Then:

```
AskUserQuestion:
  question: "Is the implementation plan ready for /beads?"
  header: "Plan"
  multiSelect: false
  options:
    - label: "Plan approved (Recommended)"
      description: "Decomposition, ordering, and coverage are correct. Proceed to /beads."
    - label: "Modify tasks"
      description: "Specific tasks need changes — I'll specify which."
    - label: "Reorder"
      description: "Task sequencing needs adjustment."
    - label: "Park"
      description: "Save the plan for later."
```

---

## BRIEF Mode Output Format

For BRIEF mode, produce a single `overview.md`. Content comes from the same phases (with Phase 3 skipped) — this template shows the expected output format:

```markdown
# Implementation Plan: {Feature Name}

**PRD:** `docs/prd/{feature}/prd.md`
**Date:** {today}

## Tasks

### T01: {Title} [Foundation]
**Implements:** FR-{NAME}
**What:** {2-3 sentences describing intent — from Phase 1}
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
├── overview.md                      # Decomposition, ordering, FR coverage, cross-cutting concerns
├── 01-foundation.md                 # Sub-plan (STANDARD+)
├── 02-create-widget.md              # Sub-plan
├── 03-list-widgets.md               # Sub-plan
├── 04-integration.md                # Sub-plan
├── ...
├── e2e-test-plan.md                 # COMPREHENSIVE: acceptance-level E2E scenarios
├── security-hardening-checklist.md  # COMPREHENSIVE: operationalized security findings
├── test-scenario-matrix.md          # COMPREHENSIVE: UC → test class mapping (living doc)
└── diagrams/
    └── dependency-graph.md          # Visual component relationships (if complex)
```

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "plan approved" / "accept" | Plan complete | Proceed to /beads |
| "refine" / "modify" | Gaps or ordering issues | Return to relevant phase |
| "park" | Save for later | Archive; user resumes later |
| "abandon" | Don't build this | Document decision rationale |

**On approval:** "Plan approved. Run /beads to create executable work packages."

---

## Anti-Patterns

**Horizontal-Only Decomposition** — "Task 1: All database work. Task 2: All API work. Task 3: All UI." This produces no testable increment until the last task completes. Default to vertical slices instead — each task delivers a thin end-to-end slice that can be tested independently.

**Deferred Risk** — Saving integrations and hard problems for the end. If the external API doesn't work as expected, you want to know in Phase 1, not Phase 3. Early risk discovery means cheaper course corrections — late risk discovery means rework or redesign.

**Testing as Phase N** — "Phase 4: Write all the tests." Each task should include its own test expectations. Testing is part of every task, not a separate phase. If you can't define test criteria for a task, the task isn't well-defined enough.

**The 200-Task Plan** — Over-decomposing into trivial tasks. If a task is "add import statement", it's too small. Merge into coherent behaviour units. The overhead of managing many tiny tasks exceeds the benefit of granularity.

**Plan-as-Design** — If writing the plan surfaces architectural decisions, the design is incomplete. Plans decompose decisions already made, they don't make new ones. The right response is to return to technical-design, not to embed design decisions in sub-plans.

**Copy-Paste Sub-Plans** — Duplicating design doc content into every sub-plan. Reference it instead. Duplication drifts and creates conflicting sources of truth. When the design changes, only one location should need updating.

**Hollow Sub-Plans** — Sub-plans that say "implement the save endpoint" without pseudocode, contract shapes, or pattern references. If the design produced this detail, the sub-plan should carry it through. The executing agent shouldn't have to re-derive algorithmic intent from prose descriptions. The design did the thinking — the plan preserves it at the task level.

**Misaligned Decomposition** — Sub-plans that don't mirror the design's feature decomposition. If the design has `features/applications/` and `features/role-templates/`, the plan should have `02-application-feature.md` and `04-role-template-feature.md` — not a different grouping that forces the agent to mentally map between decomposition schemes.

---

## Reference Files

For project-specific patterns: check project CLAUDE.md for pattern reference files
For ASCII diagram conventions: `../_shared/references/ascii-conventions.md`

---

*Skill Version: 4.1*
*v4.1: Production feedback from Organizations, Authentication, Languages runs. Gap analysis renamed to Step 1.0b (explicit named step before decomposition, not buried in Step 1.4d). "Do NOT use Explore agents for gap analysis" — use Grep/Glob for element-by-element checks. Re-planning guidance (overwrite existing plans: read old, compare, remove stale files, note delta). PAUSE 1 must show artifacts inline before AskUserQuestion. Test coverage as first-class step (precise counts, not estimates).*

*v4.0: Verification Mode (>90% exists). Gap analysis as single source of truth. Design Feedback section. Agent efficiency. PAUSE 1 lighter for non-greenfield.*

*v3.9: Failure Criteria exemption for verification/audit tasks.*
*v3.8: Production feedback from 3 runs (Entitlements, Applications, Roles). Non-greenfield fast path: run gap analysis FIRST (Step 1.1), reorder Phase 1 when >70% exists. Gap-driven decomposition strategy added. Structured gap analysis checklist (entity, contract, command, query, endpoint, frontend — use Grep/Glob not Explore agents). Task sizing table for modifications (pattern replacement/field addition/behavioral change/architecture change). Scope-excluded UC handling (not a blocker). PAUSE 1 adaptive: single gate for ≤8 tasks, multi-step for >8. Companion docs scope-aware for non-greenfield. Failure criteria extraction from decision records/*.md with step-by-step process.*

*v3.7: Adversarial review fixes. UC Coverage Ordering column, Tier 1 blockers, failure criteria extraction, gap analysis always required, PAUSE 1 validates all 3 coverage tables.*

*v3.6: UC Coverage table (Step 1.4b), Design Coverage Matrix (Step 1.4c), Implementation Gap Analysis (Step 1.4d), mandatory Failure Criteria.*
*v3.5: Prerequisites expanded with use cases, browser E2E plans, ADRs, and patterns paths. Phase 3b added to collaborative model. BRIEF skip list made explicit. ASCII conventions path corrected.*
*v3.4: AskUserQuestion stage gates. PAUSE 1 uses Guided Review Workflow (Pattern 5) with Batch Review for task validation, Decision Gate for FR coverage, and Decision Gate for ordering. PAUSE 2 uses Decision Gate (Pattern 1) for plan approval. Fallback to prose-based patterns when AskUserQuestion is unavailable.*
*v3.3: Companion documents for COMPREHENSIVE plans: e2e-test-plan.md (acceptance-level E2E scenarios), security-hardening-checklist.md (operationalized security findings with priority tiers), test-scenario-matrix.md (UC → test class living mapping). Dependency graph diagram for complex plans. All patterns validated against AMPS actions project (17 sub-plans + 3 companion docs).*
*v3.2: Plan/beads boundary shifted — sub-plans now include pseudocode (algorithmic intent), contract shapes, failure criteria, and pattern references. Sub-plan template restructured with Tasks/Objective/Approach/Pseudocode/Contract Shapes sections (modelled on identity project's plans). Feature decomposition alignment — sub-plans mirror design's feature structure. Updated self-review Theme 6 for new boundary. Hollow Sub-Plans and Misaligned Decomposition anti-patterns added.*
*v3.1: Duration targets, kill criteria check before decomposition, prose-based artifact import (no hardcoded shell), self-review moved before user presentation (merged PAUSE 2+3), structured PAUSE response options, conditional issue tracker for uncovered FRs, overview reconciliation after sub-plans, plan/beads boundary check in self-review, concrete pattern guidance in sub-plans, anti-patterns explain WHY*
