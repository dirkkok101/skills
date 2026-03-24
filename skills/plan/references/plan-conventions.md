# Plan Conventions Reference

Stable templates, checklists, and anti-patterns for the `/plan` skill. The main [SKILL.md](../SKILL.md) contains the workflow phases, PAUSE gates, and decision logic.

---

## Sub-Plan Document Template

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

### Sub-Plan Content Rules

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

---

## Coverage Matrix Templates

### FR Coverage

Every Must-Have FR from the PRD must appear in at least one task.

```markdown
### FR Coverage
| FR | Task(s) | Status |
|----|---------|--------|
| FR-{MODULE}-{NAME} | T01, T03 | Covered |
| FR-{MODULE}-{NAME} | T02 | Covered |
| FR-{MODULE}-{NAME} | — | Gap (deferred?) |
```

Flag any uncovered Must-Have FRs as blocking issues. If the project uses an issue tracker, offer to create tracked items: "These Must-Have FRs have no covering task. Want me to create tracked issues for them?"

### UC Coverage

Every use case from the PRD must be executable end-to-end across the task sequence. A UC may span multiple tasks — that's fine, but the full scenario flow must be covered. If tasks covering a UC can run in parallel (per the dependency graph), verify the UC has no ordering dependency between them.

```markdown
### UC Coverage
| UC | Title | Tier | Task(s) | Ordering | End-to-End? |
|----|-------|------|---------|----------|-------------|
| UC-{MODULE}-001 | {title} | 1 | T02, T03, T05 | Sequential (T02->T03->T05) | Full scenario covered |
| UC-{MODULE}-002 | {title} | 2 | T03 | Single task | Covered |
| UC-{MODULE}-003 | {title} | 1 | T02 | — | Steps 3-5 not covered (failure paths) |
```

For Tier 1 UCs, verify:
- Every scenario step has a covering task
- Every failure path has a covering task
- Every business rule (BR-*) maps to a validation task
- If UC tasks are parallelizable, the UC doesn't require them in sequence

UC Coverage gap handling:
- **Tier 1 UC gap** -> blocker, do not proceed until resolved
- **Tier 2 UC gap** -> may be deferred with explicit owner and rationale
- **UC tied to scope-excluded FR** -> mark as `Scope Exclusion` in the table, not as a gap or blocker. Reference the design's Scope Exclusions section. This is NOT a planning failure — it's an intentional design decision.

### Design Coverage Matrix

Every design element (endpoint, entity, command, query, contract, mapper) must have a covering task. This goes beyond FR coverage — a design may specify 6 endpoints for a single FR.

```markdown
### Design Coverage
| Design Element | Type | Source File | Task | Status |
|---------------|------|------------|------|--------|
| POST /api/v1/widgets | endpoint | api-surface.md | T03 | Covered |
| WidgetDTO | contract | api-surface.md | T02 | Covered |
| SaveWidgetCommand | command | api-surface.md | T03 | Covered |
| GetWidgetQuery | query | api-surface.md | T04 | Covered |
| Widget entity | entity | data-model.md | T01 | Covered |
| widget.saved audit | audit | design.md | — | Gap |
```

Derive the element list from the design's api-surface files (endpoints, contracts, commands, queries) and data-model (entities, migrations). Flag gaps as blocking issues.

---

## Companion Document Specifications (COMPREHENSIVE only)

These companion documents are produced alongside sub-plans for COMPREHENSIVE plans. They are living documents — updated during implementation as tests are written and security findings are addressed.

**Scope-aware companion docs:** For plans where >70% of Implementation Status is "Exists" (non-greenfield), companion docs should focus on **verification of existing behavior** rather than planning new behavior:
- E2E test plans become smoke tests verifying existing flows still work after modifications
- Security checklists become audit checklists verifying existing controls
- Test matrices document existing test coverage and identify gaps, not plan all-new tests

### E2E Test Plan

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

### Security Hardening Checklist

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

### Test Scenario Matrix

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

## Use Case -> Test Mapping

### UC-{MODULE}-{NNN}: {Title}

| Layer | Test Class | Tests | Count |
|-------|-----------|-------|-------|
| Unit | `{Validator}Tests` | {test method names} | {N} |
| Integration | `{Lifecycle}Tests` | {test method names} | {N} |
| **Total** | | | **{N}** |
```

Derive initial test mapping from the design's per-feature test plans. During implementation, update with actual test class names and method counts.

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

## Implementation Gap Analysis Procedure

### Decision Logic (Run BEFORE Decomposition)

```
IF Implementation Status shows > 90% "Exists":
  -> Verification Mode: produce gap-analysis.md + companion docs
  -> If remaining work is trivial (< 3 discrete items): single verification sub-plan
  -> If remaining work is non-trivial (3+ distinct gaps with real implementation): separate sub-plans per gap are acceptable
  -> The gap analysis IS the primary artifact — sub-plans detail specific fixes

IF Implementation Status shows > 70% "Exists" (but < 90%):
  -> Non-Greenfield Fast Path: derive tasks from gaps, not design work decomposition
  -> Skip importing design's Work Decomposition section
  -> Tasks focus on "what to change" not "what to build"
  -> Companion docs focus on verification, not new behavior

IF Implementation Status shows < 30% "Exists":
  -> Greenfield Path: standard decomposition from design
  -> Import design Work Decomposition as starting point

ELSE:
  -> Hybrid: some greenfield tasks, some modification tasks
```

**Gap analysis is the single source of truth.** The gap-analysis.md file (or the overview's Implementation Status table) is the authoritative record of what exists, what needs modification, and what's new. Do NOT duplicate this information across overview, gap analysis, and sub-plans — reference it. The overview's Design Coverage table can summarize with a single line ("44/44 exist — see gap-analysis.md for modification details") when all elements exist.

**Design feedback:** If the gap analysis or decomposition reveals a design-level issue (architectural tension, missing specification, contradicted assumption), document it as a `## Design Feedback` section in the overview — not buried in sub-plan context paragraphs. This surfaces issues that should go back to `/technical-design` without blocking plan completion.

### Gap Analysis Approach

Use targeted Grep/Glob for element-by-element checks, not Explore agents. Explore agents over-report existence without catching field-level gaps.

For small modules (< 20 design elements): run Grep/Read calls directly.
For large modules (20+ design elements): partition gap analysis agents by layer with no overlap:
- Agent A: data layer (entities, configs, enums, migrations)
- Agent B: backend logic (commands, queries, validators, mappers, services)
- Agent C: contracts only (DTOs, requests, responses)
- Agent D: frontend (components, services, routing, models)
- Agent E: cross-cutting (DI registration, audit events, tests)

Explore agents are useful for initial context loading (Phase 0) but not for the gap analysis itself.

**Verify ALL agent claims — absence AND modification.** If an agent reports "file not found" or "tests missing," confirm with a targeted Grep. If an agent reports "field X should be Y," verify against the design doc (not just the code). Agents miss files in non-obvious locations and confidently report modifications against invented requirements.

**Test project discovery:** Do NOT assume test files are in `test/` or `tests/`. Search the entire repository for test projects (`*.Tests`, `*.Test`, `spec` directories). The gap analysis prompt should say "search the entire repository for test files related to {module}" not "search test/ directory."

**Test mapping precision:** When test counts exceed design cases, note which mappings were verified vs inferred. Mark approximate counts with `~` and flag for verification during execution.

### Re-planning (Overwriting Existing Plans)

When a plan directory already exists:
1. Read the old plan's overview to understand prior state
2. Run gap analysis against current code (not old plan)
3. List all old sub-plan and companion doc files explicitly
4. Remove old files before writing new ones (prevents orphaned files)
5. Note in the overview what changed from the prior plan and why

**Agent result verification:** Always verify agent claims about **absence** ("no tests exist", "file not found") with targeted Grep/Glob. Presence claims are generally reliable; absence claims need spot-checking. Agents can miss files that exist in non-obvious locations.

### Structured Checklist

For each design element type, search the codebase:

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

### Implementation Status Table

```markdown
### Implementation Status
| Design Element | Type | Status | Notes |
|---------------|------|--------|-------|
| Widget entity | entity | Exists | Schema matches design |
| WidgetDTO | contract | Exists | Missing new field "Category" |
| SaveWidgetCommand | command | Modify | Exists but uses old return type pattern (need updated pattern per design decision) |
| GetWidgetQuery | query | New | Not yet implemented |
| Widget grid UI | frontend | New | Not yet implemented |
```

Mark each element as:
- **New** — nothing exists, build from scratch per design
- **Modify** — exists but needs changes to match design (specify WHAT changes)
- **Exists** — already matches design, verify only (no bead needed unless verification fails)

For greenfield features, every element is "New" — but still document the table to confirm nothing was assumed to exist.

### Task Sizing for Modifications

| Modification Type | Size | Example |
|-------------------|------|---------|
| Pattern replacement (same logic, new type) | S | Change return type from old pattern to new per design decision |
| Field addition (cascades to DTO + mapper + tests) | M | Add `Category` field across entity, DTO, mapper, validator |
| Behavioral change (new logic path) | L | Add audit event wiring where none existed |
| Architecture change (cascading rework) | XL | Move from commands to event-driven pattern |
