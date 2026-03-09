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
Phase 0: Import & Prerequisites
Phase 1: Decomposition (with kill criteria check)
  ── PAUSE 1: "Here's the decomposition. Right tasks? Right order?" ──
Phase 2: Overview Document
Phase 3: Sub-Plans (STANDARD+)
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

**Align with design's feature decomposition:** If the design uses feature-first decomposition (`docs/designs/{feature}/features/{sub-feature}/`), sub-plans should mirror this structure. Each design feature area typically maps to one sub-plan (e.g., `features/applications/` → `02-application-feature.md`). This alignment ensures sub-plans can directly reference their feature's api-surface.md, test-plan.md, and ui-mockup.md without ambiguity.

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

Flag any uncovered Must-Have FRs as blocking issues. If the project uses an issue tracker, offer to create tracked items: "These Must-Have FRs have no covering task. Want me to create tracked issues for them?"

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

Response options:
- **Accept** — decomposition is correct, proceed to write overview and sub-plans
- **Modify** — adjust tasks, sizing, or ordering (specify which)
- **Escalate** — decomposition reveals the design is incomplete or scope is wrong; return upstream

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

**Failure Criteria:** (include known pitfalls)
- {What NOT to do — common mistakes, design constraints that must hold}

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

**PAUSE 2:** Present completed plan with summary.

```markdown
## Implementation Plan Complete

**Feature:** {name}
**Mode:** {BRIEF | STANDARD | COMPREHENSIVE}
**Tasks:** {N} across {N} phases
**Critical path:** {task chain} ({N} tasks)
**FR coverage:** {N}/{N} Must-Haves covered
**Risk items:** {N} tasks flagged as high-risk (addressed in Phase 1)

Ready for review:
1. "Accept" / "plan approved" → Proceed to /beads
2. "Modify {task}" → Iterate on specific task
3. "Reorder" → Change task sequencing
4. "Park" → Save for later
5. "Abandon" → Document decision rationale
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
For ASCII diagram conventions: `_shared/references/ascii-conventions.md`

---

*Skill Version: 3.3*
*v3.3: Companion documents for COMPREHENSIVE plans: e2e-test-plan.md (acceptance-level E2E scenarios), security-hardening-checklist.md (operationalized security findings with priority tiers), test-scenario-matrix.md (UC → test class living mapping). Dependency graph diagram for complex plans. All patterns validated against AMPS actions project (17 sub-plans + 3 companion docs).*
*v3.2: Plan/beads boundary shifted — sub-plans now include pseudocode (algorithmic intent), contract shapes, failure criteria, and pattern references. Sub-plan template restructured with Tasks/Objective/Approach/Pseudocode/Contract Shapes sections (modelled on identity project's plans). Feature decomposition alignment — sub-plans mirror design's feature structure. Updated self-review Theme 6 for new boundary. Hollow Sub-Plans and Misaligned Decomposition anti-patterns added.*
*v3.1: Duration targets, kill criteria check before decomposition, prose-based artifact import (no hardcoded shell), self-review moved before user presentation (merged PAUSE 2+3), structured PAUSE response options, conditional issue tracker for uncovered FRs, overview reconciliation after sub-plans, plan/beads boundary check in self-review, concrete pattern guidance in sub-plans, anti-patterns explain WHY*
