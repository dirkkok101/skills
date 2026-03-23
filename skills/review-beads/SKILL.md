---
name: review-beads
description: >
  Adversarial bead compliance review against ALL upstream artifacts — PRD, design,
  architecture, patterns, ADRs, use cases, and plans. Beads are the last checkpoint
  before code is written. If a bead is wrong, the implementation will be wrong.
  Reviews 11 categories: FR coverage, UC coverage, design compliance, architecture
  compliance, API patterns, web patterns, test coverage, stage gates, bead quality,
  backwards compatibility, cross-module dependencies, and granularity. Use when
  beads are created (/beads completed), user says "review beads", or before /execute.
argument-hint: "[feature-name] or [epic-id]"
---

# Review Beads: Adversarial Bead Compliance Review

**Philosophy:** "If I hand this bead to an agent with no other context, will it build the software correctly?" Every finding must pass a second filter: "Am I sure this is actually wrong, or does it just look different from what I expected?" False positives erode trust faster than missed defects.

**Duration targets:** BRIEF ~15-20 minutes (single entity, <15 beads), STANDARD ~30-60 minutes (typical module, 15-60 beads), COMPREHENSIVE ~60-120 minutes (multi-module or full platform). Most time is Phase 3 (granularity decomposition) and Phase 4 (bead-by-bead deep review).

## Why This Matters

Beads are the contract between planning and execution. A defective bead produces defective code — and the executing agent has no way to know, because the bead IS its source of truth. Upstream docs (PRD, design, architecture) encode decisions that took hours to reach. If beads don't faithfully carry those decisions forward, the entire pipeline from requirements to code breaks silently. This review catches the break before it costs implementation time.

---

## Trigger Conditions

Run this skill when:
- Beads have been created (`/beads` completed)
- User says "review beads", "check beads", "bead review"
- Before starting `/execute` on a new set of beads
- After significant bead modifications or re-planning

Do NOT use for:
- Reviewing code (use `/review`)
- Reviewing plans before beads exist (use `/review-plan`)
- Reviewing PRD requirements (use `/review-prd`)
- Reviewing designs (use `/review-design`)

## Stage Gates — AskUserQuestion

At every PAUSE point in this skill, **call the `AskUserQuestion` tool** to present structured options to the user. Do not present options as plain markdown text — use the tool. The YAML blocks at each PAUSE point show the exact parameters to pass.

For pattern details and examples: `../_shared/references/stage-gates.md`

> **Fallback:** Only if `AskUserQuestion` is not available as a tool (check your tool list), fall back to presenting options as markdown text and waiting for freeform response.

---

## Mode Selection

| Mode | When | Scope |
|------|------|-------|
| **BRIEF** | Single entity/feature, <15 beads | Skip batch execution section, abbreviated matrices |
| **STANDARD** | Typical module, 15-60 beads | Full review, single reviewer |
| **COMPREHENSIVE** | Multi-module, 60+ beads, or critical path | Full review + batch execution across modules |
| **CONVERGE** | Fix all issues until 0 FAILs | Selected depth + auto-fix loop |

### CONVERGE Mode

When the user says "converge", "fix all issues", or selects CONVERGE mode, run the autoresearch convergence loop. CONVERGE can be combined with any review depth:

- `CONVERGE` alone → uses STANDARD depth
- `CONVERGE + COMPREHENSIVE` → uses COMPREHENSIVE depth

**CONVERGE changes to the normal review flow:**
- **Skip all interactive stage gates.** CONVERGE implies "just go."
- **Replace interactive findings presentation** with a summary table classified as MECHANICAL / JUSTIFIED_DEVIATION / DECISION.
- **WARNs are listed** but NOT auto-fixed. Trivial WARNs (additive-only, <10 lines) may be auto-fixed.
- **READ-ONLY does not apply** — beads are modified directly to fix MECHANICAL findings.

**The loop:**

1. **Review** — Run at the selected depth. Use progressive loading:
   - Wave 1: Plan overview + bead list (catches coverage gaps)
   - Wave 2: Design docs + pattern docs for specific beads with findings
   - Wave 3: Agents for broad ADR/architecture surveys
2. **Classify** findings:
   - **MECHANICAL** — wrong FR reference, stale dependency, missing context file, count error. Auto-fix.
   - **JUSTIFIED_DEVIATION** — bead deviates from pattern with documented rationale. Verify and PASS.
   - **DECISION** — design contradiction, scope question, architectural choice. Escalate via AskUserQuestion.
3. **Fix** MECHANICAL findings. **Cascade check:** after fixing a bead, grep all beads for related terms.
4. **Re-review** — Run again on fixed beads.
5. **Compare** — Did FAILs decrease? If increased, revert and stop.
6. **Repeat** until 0 FAILs or max 5 rounds.

**Authority hierarchy for mechanical fixes:**
```
ADRs > Pattern docs > Architecture docs > PRD > Design (api-surface, data-model) > Plan (overview, sub-plans) > Beads
```

**Same-session detection:** If beads were generated in the current conversation, flag as same-session. Increase spot-checks to 5 minimum. Phase 2 confidence is LOW.

**Non-greenfield bead review:** If the plan's Implementation Status shows >70% "Exists":
- Verification beads ("verify X matches design") may omit Failure Criteria — the success criteria checklist IS the constraint
- "Modify" beads should specify WHAT needs to change, not just the endpoint/entity name
- Do NOT flag verification beads as incomplete because they lack implementation guidance

**Token budget:** COMPREHENSIVE reviews with 50+ beads read 30-60 documents. Models with <200K context may need two-pass approach.

**Report:** For quick convergences (≤3 rounds, ≤10 findings), use compact format:
`{N} findings → {N} fixed in {N} rounds. {N} decisions escalated. WARNs: {N}.`

---

## Finding Quality Standards

These standards are non-negotiable. Every finding must meet ALL of them:

1. **Re-read the bead** (via `br show <bead-id>`) before writing any finding — do not flag based on cached/stale reads
2. **Quote the specific defect** from the bead text — "the bead says X" or "the bead omits X"
3. **Check both description AND wired dependencies** — a finding about missing dependencies must verify `br dep list <bead-id>`
4. **Verify against the authoritative source doc**, not the plan — plans are lower trust than designs (see Trust Hierarchy in `/beads` skill)
5. **The issue must cause a concrete problem during execution** — "an agent executing this bead would produce [wrong outcome]" or "an agent would have to guess about [ambiguous thing]"

### What NOT to Flag

- **Missing ADR references that CLAUDE.md already covers** — CLAUDE.md is always loaded; referencing ADRs it already mandates is redundant
- **Missing global pattern references** — i18n, toast notifications, error handling patterns that are project-wide conventions agents already follow
- **Redundant transitive dependencies** — if A depends on B and B depends on C, A does not need to explicitly depend on C
- **Description style preferences** — ordering of sections, wording choices, formatting variations
- **Issues in upstream docs** — tag as `UPSTREAM_DOC` and list separately; these are not bead defects

---

## Trust Hierarchy

When reviewing beads, verify against sources in this order (highest trust first):

1. **ADRs & Pattern docs** — architectural intent, non-negotiable
2. **PRD** — business requirements, Must-Have FRs
3. **Design docs** (api-surface, data-model, ui-mockup) — technical specification
4. **Use cases** — actor workflows, extension/alternative flows
5. **Plans & Sub-plans** — implementation breakdown (lower trust — may have drifted)
6. **Beads** — must conform to everything above

If a bead contradicts a higher-trust source, the bead is wrong. If a plan contradicts the design, cite the design, not the plan.

---

## Finding Classification

Every finding has a **class** (what's wrong) and a **severity** (FAIL or WARN):

| Class | Meaning | Default Severity |
|-------|---------|-----------------|
| `MISSING_BEAD` | Required bead does not exist | **FAIL** |
| `WRONG_CONTENT` | Bead exists but description is incorrect | **FAIL** |
| `WRONG_DEPENDENCY` | Dependency wiring is incorrect | **FAIL** |
| `EMPTY_GATE` | Gate bead has no scope or verification commands | **FAIL** |
| `ORPHANED_GATE` | Gate bead exists but nothing depends on it | **WARN** |
| `WRONG_TYPE` | Bead type is incorrect | **WARN** |
| `GRANULARITY` | Bead is too coarse or too fine | **WARN** |
| `STALE_REF` | Context reference points to wrong/missing file | **FAIL** (MECHANICAL — auto-fixable) |
| `CROSS_MODULE` | Cross-module dependency not wired | **FAIL** |
| `UPSTREAM_DOC` | Issue is in the upstream doc, not the bead | **WARN** (not a bead defect — note separately) |

**Severity model alignment:** This skill uses FAIL/WARN to match review-prd, review-design, and review-plan. FAIL = blocks /execute. WARN = quality improvement, doesn't block.

---

## Severity Calibration

**Every finding gets a severity. Calibrate carefully — inflation kills trust.**

### CRITICAL

The build won't compile, data will be wrong, security is vulnerable, a Must-Have FR is violated, or a required bead is missing entirely. An agent executing the bead set will produce broken software.

Examples:
- Must-Have FR has zero bead coverage
- Bead references entity property that doesn't exist in data model
- Missing bead for entity that other beads depend on
- Security-sensitive endpoint has no authorization bead
- Bead wires to wrong entity (Role bead references Permission table)

### HIGH

An agent will guess wrong. The bead provides enough information to execute, but the execution will produce incorrect results that won't be caught until review or testing.

Examples:
- Empty gate bead — no file paths, no verification commands
- Orphaned gate — gate exists but nothing blocks on it
- Stale context reference — file moved or renamed
- Wrong pattern reference — bead says `commands` pattern but should be `queries`
- Missing dependency — bead will fail because prerequisite doesn't exist yet
- Frontend bead depends on backend impl bead instead of test gate

### MEDIUM

An agent would likely succeed but could be confused, leading to suboptimal implementation or wasted time asking questions.

Examples:
- Bead objective is ambiguous — two valid interpretations
- Success criteria are vague — "works correctly" instead of testable outcomes
- Missing out-of-scope section — agent might drift into adjacent work
- Bead combines two small pattern artifacts that COULD be separate (borderline grouping)

### LOW

Cosmetic or minor quality issues that don't affect execution.

Examples:
- Inconsistent bead title convention
- Missing FR tag that's obvious from context
- Verification command uses wrong test filter (but close)
- Bead could reference a learning doc but doesn't need to

---

## Critical Sequence

### Phase 1: Document Loading

**Load every upstream document before reviewing any bead.** Do not start reviewing beads until all source material is loaded.

**Step 1.1 — Identify the feature and bead set:**

```bash
br list --status open --json   # or filter by epic
br dep tree <epic-id>          # dependency visualization
```

Record: epic ID, bead count, feature name.

**Step 1.2 — Load upstream documents:**

Read ALL of the following that exist (use the project's doc structure):

| Document | Path Pattern | Purpose |
|----------|-------------|---------|
| PRD | `docs/prd/{feature}/prd.md` | FR definitions, acceptance criteria, priorities |
| Design — API surface | `docs/designs/{feature}/**/api-surface.md` | Endpoints, shapes, HTTP methods, error responses |
| Design — Data model | `docs/designs/{feature}/**/data-model.md` | Entities, properties, constraints, relationships |
| Design — UI mockup | `docs/designs/{feature}/**/ui-mockup.md` | Screens, components, interactions, states |
| Design — Test plan | `docs/designs/{feature}/**/test-plan.md` | Test scenarios, coverage matrix |
| Design — Overview | `docs/designs/{feature}/design.md` | Problem statement, constraints, chosen approach |
| Use cases | `docs/use-cases/UC-*.md` | Actor workflows, extension flows, error conditions |
| Plan overview | `docs/plans/{feature}/overview.md` | Task summary, dependency graph, FR coverage |
| Sub-plans | `docs/plans/{feature}/[0-9]*.md` | Per-task intent, scope, criteria |
| Pattern docs | `docs/patterns/**/*.md` | Pattern keys referenced by beads |
| ADRs | `docs/adr/*.md` | Architectural decisions |
| Architecture docs | `docs/architecture/*.md` | Multi-tenancy, auth, CQRS context |
| Learnings | `docs/learnings/*.md` | Past gotchas and corrections |

**Step 1.3 — Build the source index:**

For each document loaded, record what it provides:

```markdown
## Source Index

| Source | Key Content | Trust Level |
|--------|------------|-------------|
| PRD | 12 FRs (8 Must, 3 Should, 1 Could), 2 NFRs | 2 (high) |
| API Surface | 14 endpoints across 3 entities | 3 (design) |
| Data Model | 3 entities, 2 enums, 5 relationships | 3 (design) |
| UI Mockup | 2 list pages, 2 capture pages, 1 embedded list | 3 (design) |
| ADR-0004 | Enums over string constants | 1 (highest) |
| ADR-0005 | EnumDTO/NamedDTO for UI binding | 1 (highest) |
```

---

### Phase 2: FR/UC Gap Analysis

**Step 2.1 — Build FR Coverage Matrix:**

For each FR in the PRD, identify which bead(s) implement it. Check bead descriptions for `## Implements` sections and FR tags.

**Acceptance criteria depth check:** For each Must-Have FR, read the PRD's Given/When/Then acceptance criteria. Verify each criterion maps to at least one bead's success criteria. An FR is "Full" only if ALL acceptance criteria are addressed. If 2 of 4 criteria are missing from any bead, the FR is "Partial" — flag as FAIL.

```markdown
## FR Coverage Matrix

| FR ID | Priority | Description | Bead(s) | Coverage |
|-------|----------|-------------|---------|----------|
| FR-ROLE-CREATE | Must | Create new role | bd-006 (SaveCommand), bd-012 (Save Endpoint) | Full |
| FR-ROLE-LIST | Must | List roles with grid | bd-009 (GridQuery), bd-014 (Grid Endpoint), bd-020 (List Page) | Full |
| FR-ROLE-DELETE | Must | Delete role | — | MISSING |
| FR-ROLE-ASSIGN | Should | Assign role to user | bd-008 (Lifecycle) | Partial — no UI bead |
```

**Coverage statuses:**
- **Full** — all backend + frontend + test beads exist
- **Partial** — some beads exist but gaps remain (specify what's missing)
- **MISSING** — no beads at all (CRITICAL if Must-Have)
- **Deferred** — explicitly out of scope per PRD (Should/Could only)

**Step 2.2 — Build UC Coverage Matrix:**

For each use case, trace the main scenario steps and extension/alternative flows to beads.

```markdown
## UC Coverage Matrix

| UC ID | Step/Flow | Description | Bead(s) | Coverage |
|-------|-----------|-------------|---------|----------|
| UC-001 | Main.1 | Admin navigates to roles list | bd-020 (List Page), bd-022 (Routing) | Full |
| UC-001 | Main.2 | Admin clicks "New Role" | bd-021 (Capture Page) | Full |
| UC-001 | Main.3 | Admin fills form and saves | bd-006 (SaveCommand), bd-012 (Save Endpoint) | Full |
| UC-001 | Ext.3a | Duplicate name error | bd-011 (Validators) | Full |
| UC-001 | Ext.3b | Server error during save | — | MISSING — no error handling bead |
| UC-001 | Alt.1 | Admin cancels without saving | bd-021 (Capture Page) | Implicit in canDeactivate |
```

**Step 2.3 — Flag gaps:**

Any Must-Have FR with coverage status `MISSING` or `Partial` is a CRITICAL finding of class `MISSING_BEAD`. Any UC main scenario step with `MISSING` coverage is HIGH.

---

### Phase 3: Granularity Decomposition

**This is the most important phase.** Count the expected beads from the design documents, then compare against actual beads. Mismatches reveal missing beads, over-combined beads, or unnecessary beads.

**Step 3.1 — Count expected beads from design:**

Read the design docs and derive what the bead set SHOULD contain.

**From data model (per entity):**

| Design Artifact | Expected Bead | Condition |
|----------------|---------------|-----------|
| Entity definition | `{Entity} Entity + Enums` | Always |
| Entity with relationships/indexes | `{Entity} EF Configuration` | Always |
| Entity exposed via API | `{Entity} Contracts` | Always |
| Entity with create/update | `{Entity} EntityMapper` | Has save endpoint |
| Entity returned via API | `{Entity} DTOMapper` | Has get/grid endpoint |
| Entity with create/update | `{Entity} SaveCommand` | Has save endpoint |
| Entity with delete | `{Entity} DeleteCommand` | Has delete endpoint |
| Entity with lifecycle states | `{Entity} Lifecycle Commands` | Has enable/disable/suspend |
| Entity with get-by-id | `{Entity} GetQuery` | Has get endpoint |
| Entity with grid/list | `{Entity} GridQuery + QueryParameters` | Has grid endpoint |
| Entity as dropdown source | `{Entity} LookupQuery` | Has lookup endpoint |

**From API surface (per entity):**

| Design Artifact | Expected Bead | Condition |
|----------------|---------------|-----------|
| Save endpoint | `{Entity} Save Endpoint` | Always with save |
| Get endpoint | `{Entity} Get Endpoint` | Always with get |
| Grid endpoint | `{Entity} Grid Endpoint` | Always with grid |
| Delete endpoint | `{Entity} Delete Endpoint` | Always with delete |
| Lookup endpoint | `{Entity} Lookup Endpoint` | Has lookup |
| Lifecycle endpoints | `{Entity} Lifecycle Endpoints` | Has lifecycle |
| Any endpoint | `{Entity} Validators` | Always |
| All of the above | `{Entity} Service Registration` | Always (last backend bead) |

**From UI mockup (per feature):**

| Design Artifact | Expected Bead | Condition |
|----------------|---------------|-----------|
| TypeScript interfaces | `{Feature} Models + Enums` | Always |
| HTTP service | `{Feature} Feature Service` | Always |
| List/grid page | `{Feature} List Page` | Has list page |
| Capture/form page | `{Feature} Capture Page` | Has capture page |
| Component state | `{Feature} Capture State` | Has capture with complex state |
| Embedded child grid | `{Feature} Embedded List` | Has child entities |
| Route definitions | `{Feature} Routing` | Always |

**From stage gate rules:**

| Boundary | Expected Gates | Count |
|----------|---------------|-------|
| Per feature backend | `/review` + `/simplify` + test | 3 |
| Per feature frontend | `/review` + `/simplify` + test | 3 |
| Per use case | `/review` + `/simplify` | 2 |
| Module | `/review` + `/simplify` | 2 |

**Step 3.2 — Derive expected bead count:**

```markdown
## Expected Bead Count Derivation

### Entities: {list}

| Entity | Backend Beads | Condition Notes |
|--------|--------------|-----------------|
| Role | 17 (full CRUD + lookup + lifecycle) | All endpoints in API surface |
| Permission | 11 (CRUD, no lifecycle, no lookup) | No lifecycle states in data model |
| Entitlement | 8 (read-only + grid) | No save/delete in API surface |

### Frontend Features: {list}

| Feature | Frontend Beads | Condition Notes |
|---------|---------------|-----------------|
| Roles | 5 (models, service, list, capture, routing) | Full UI |
| Permissions | 4 (models, service, list, routing) | No capture page |

### Stage Gates

| Level | Count |
|-------|-------|
| Feature ({N}) × 6 | {N×6} |
| Use Case ({N}) × 2 | {N×2} |
| Module × 2 | 2 |

### Tests

| Type | Count |
|------|-------|
| Integration tests ({N} features) | {N} |
| UI tests ({N} features) | {N} |

### Total Expected: {sum}
### Total Actual: {bead count from br}
### Delta: {difference}
```

**Step 3.3 — Identify decomposition mismatches:**

For each delta, determine whether it's:
- **Missing bead** (`MISSING_BEAD`) — expected bead doesn't exist
- **Over-combined** (`GRANULARITY`) — expected bead is merged into a larger bead
- **Correctly grouped** — per grouping exceptions in `/beads` skill
- **Extra bead** — bead exists but design doesn't warrant it (flag for verification)

**Step 3.4 — Write decomposition specs for splits:**

For each `GRANULARITY` finding that recommends splitting, provide a concrete decomposition:

```markdown
### Decomposition: bd-005 "Role Mappers" → 2 beads

**Current bead:** Combines EntityMapper and DTOMapper
**Violation:** EntityMapper (DTO→Entity) and DTOMapper (Entity→DTO) are opposite data flows — never combine per bead size heuristic

**Split into:**
1. `{Entity} EntityMapper` — Pattern: `entity-mapper`, depends on: Entity + Contracts beads
2. `{Entity} DTOMapper` — Pattern: `dto-mapper`, depends on: Entity + Contracts beads

**Dependencies to rewire:**
- SaveCommand should depend on EntityMapper (not the combined bead)
- GetQuery should depend on DTOMapper (not the combined bead)
```

**Step 3.5 — Finding verification:**

Before recording any finding from this phase, **re-read the bead** via `br show <bead-id>`. Verify:
- The bead actually says what you think it says
- The dependency wiring is actually wrong (check `br dep list`)
- The issue causes a concrete execution problem

---

### Phase 4: Bead-by-Bead Deep Review

For each bead, review against all 11 categories. Not every category applies to every bead — skip inapplicable checks.

#### Category 1: FR Coverage

- [ ] Every Must-Have FR in the PRD has at least one bead
- [ ] No phantom FRs — bead doesn't claim to implement an FR that doesn't exist in the PRD
- [ ] Coverage is complete, not partial — if FR requires backend + frontend, both exist
- [ ] PRD acceptance criteria are reflected in bead success criteria (Given/When/Then alignment)
- [ ] FR priority matches bead existence — Must-Have FRs are never deferred

#### Category 2: Use Case Coverage

- [ ] Every main scenario step has a bead (or is covered by a bead's scope)
- [ ] Every extension flow has a bead or is in a bead's failure criteria
- [ ] Every alternative flow has a bead or is in a bead's out-of-scope with justification
- [ ] Error conditions appear as failure criteria in relevant beads
- [ ] Actor-specific behavior is preserved — if UC says "admin sees X", the bead doesn't genericize to "user sees X"

#### Category 3: Design Compliance

**API surface alignment:**
- [ ] Every endpoint in the design has a bead
- [ ] Request/response shapes in bead match the design (property names, types, nesting)
- [ ] HTTP methods match (POST for save, POST for grid, GET for get, DELETE for delete)
- [ ] Validation rules in design appear in validator bead
- [ ] Error responses in design appear in bead failure criteria
- [ ] Route paths match design conventions

**Data model alignment:**
- [ ] Every entity in the design has entity + EF config beads
- [ ] Property names in bead match design (exact casing, exact types)
- [ ] Constraints in design (required, max length, unique) appear in EF config bead
- [ ] Enum values in bead match design exactly
- [ ] Column naming convention matches project standard (PascalCase per pattern alignment)
- [ ] Relationships in design are reflected in EF config bead

**UI mockup alignment:**
- [ ] Every screen in the design has a component bead
- [ ] Component type matches design (list page vs capture page vs embedded list)
- [ ] Interactions in design (click, filter, sort, validate) are in bead scope
- [ ] States in design (loading, empty, error, success) are in bead success/failure criteria

#### Category 4: Architecture Compliance

**ADR checklist — verify each applicable ADR:**

| ADR | Check | Applies To |
|-----|-------|-----------|
| Enums over strings (ADR-0004) | Status/kind/mode fields use enums, not string constants | Entity, Contracts, EF Config beads |
| EnumDTO/NamedDTO (ADR-0005) | Dropdown-bindable fields use EnumDTO/NamedDTO | Contracts, DTOMapper beads |
| Entity mapper result | SaveCommand uses EntityMapperResult, not OneOf | SaveCommand beads |
| Separate requests superseded | SaveRequest inherits DTO, Guid.Empty for create | Contracts beads |
| PascalCase columns | EF config uses PascalCase column naming | EF Config beads |
| IEntityTypeConfiguration | EF config uses IEntityTypeConfiguration<T>, not extension methods | EF Config beads |
| POST for GridList | Grid endpoint uses POST, not GET | Grid Endpoint beads |

**Multi-tenancy & RLS:**
- [ ] Entities implementing ITenantEntity have RLS considerations in beads
- [ ] Beads that query across tenants note bypass requirements
- [ ] No bead assumes cross-org data access without explicit RLS bypass scoping

**Authorization:**
- [ ] Endpoint beads specify authorization requirements
- [ ] Platform admin UX pattern followed — org-scoped, never cross-org views

**CQRS:**
- [ ] No bead combines a command and a query
- [ ] Commands and queries have separate beads with correct pattern references

#### Category 5: API Pattern Compliance

- [ ] Vertical slice structure — features are self-contained directories
- [ ] Endpoint base class — beads reference correct endpoint base (e.g., `IdentityEndpoint`)
- [ ] Save pattern — upsert via EntityMapper, not separate create/update
- [ ] Get pattern — dual identifier support (ID + slug/name), 404-not-403
- [ ] Grid pattern — POST endpoint, QueryParameters builder class, PagedResponse
- [ ] Delete pattern — `ExecuteDeleteAsync`, dependency checks, explicit transaction
- [ ] Lookup pattern — returns `NamedDTO[]` for dropdown binding
- [ ] Contracts placement — ALL DTOs, requests, responses in Contracts project, not API project
- [ ] Validators — FluentValidation, in API project (not Contracts)
- [ ] Service registration — `Add{Feature}Services()` in a central registration point
- [ ] Mapper patterns — EntityMapper uses EntityMapperResult, DTOMapper has DataContext if needed

#### Category 6: Web Pattern Compliance

- [ ] UI component library — beads reference `@nxgn-solutions/ui` components first (`nxgn-grid-page-title`, `nxgn-data-grid`, `nxgn-capture-page-title`)
- [ ] Feature-colocated services — HTTP service class lives with the feature, not in a shared folder
- [ ] Signal state — component state uses Angular signals, not BehaviorSubjects
- [ ] Standalone components — no NgModules, no CommonModule imports
- [ ] Zoneless — no manual change detection (no `ChangeDetectorRef`, no `NgZone.run`)
- [ ] Routing — lazy-loaded routes, child routes for list-to-capture navigation, canDeactivate guards
- [ ] Enum patterns — `as const` objects, not TypeScript enums
- [ ] Model definitions — interfaces (not classes) for DTOs, matching backend property names

#### Category 7: Test Coverage

- [ ] Test plan from design doc is traceable to test beads
- [ ] Test beads specify executable commands (`dotnet test --filter`, `ng test`)
- [ ] Negative test cases present — what should fail, not just what should succeed
- [ ] RLS test cases — if entity has tenant isolation, tests verify it
- [ ] Integration test infrastructure — bead references Testcontainers Postgres (not in-memory)
- [ ] UI test infrastructure — bead references Vitest (not Jasmine/Karma)

#### Category 7b: Test & Verification Gates

**Gate policy:** `/review` and `/simplify` gate beads between implementation beads are prohibited (they treat preparatory code as "dead code" and delete it). Only test and verify gates are allowed. If `/review` or `/simplify` gates are found, classify as DECISION (not FAIL) — the user chooses whether to remove them. Older beads sets may have been generated before this policy; removal is the recommended resolution but not automatic.

- [ ] **No `/review` or `/simplify` gate beads** between implementation beads — flag as DECISION, recommend removal
- [ ] Backend test gate blocks frontend beads (frontend depends on backend test gate)
- [ ] UC verification gates exist for each use case (verify scenario flow, not just code review)
- [ ] Module verification gate exists as final bead in epic
- [ ] Cadence check — no more than 4-5 implementation beads between consecutive test gates
- [ ] Gate beads have executable verification commands (test commands, not vague "review code")
- [ ] Gate beads have correct dependency wiring (impl → test → next phase)
- [ ] No empty gates — every gate specifies what tests to run
- [ ] No orphaned gates — every gate has downstream beads that depend on it
- [ ] For Verification Mode (>90% exists): lightweight gates acceptable (test only, no UC/module verify for ≤10 impl beads)

#### Category 8: Bead Quality

- [ ] **Objective** states intent, not implementation — no code, no pseudo-code
- [ ] **No source code** in bead description — beads contain intent, agents write code from patterns
- [ ] **Context references exist** — `## Context to Load` section with specific file paths
- [ ] **Pattern references are specific** — points to actual pattern doc path, not just "follow patterns"
- [ ] **In/Out scope bounded** — explicit boundaries, out-of-scope names the other bead
- [ ] **Success criteria are testable** — observable outcomes, not "make sure it works"
- [ ] **Failure criteria are realistic AND design-decision-traced** — not generic ("Do NOT over-engineer") but specific ("Do NOT use [rejected approach] per [decision ref]"). Cross-reference against the plan's Design Decision Coverage table — every decision should appear as a failure criterion in at least one bead.
- [ ] **Verification commands are executable** — real commands with correct filters/paths
- [ ] **Commit message specified** — conventional commit format, one per bead
- [ ] **Implements section present** — FR/UC traceability

#### Category 9: No Backwards Compatibility

- [ ] No compatibility shims — no old API route preservation alongside new routes
- [ ] No adapter layers — no translation between old and new contract shapes
- [ ] No old API preservation — deprecated endpoints are removed, not maintained
- [ ] Cleanup beads exist — if old code is being replaced, a bead removes the old code
- [ ] No migration beads — app is pre-deployment, no incremental data migrations

#### Category 10: Cross-Module Dependencies

- [ ] Dependencies match wired links — `br dep list` matches bead's `## Depends On`
- [ ] No hidden assumptions — bead doesn't assume another module's entity/service exists without a dependency
- [ ] Shared contracts created before consuming beads — if Feature B uses Feature A's DTO, the contracts bead for A is wired as a dependency
- [ ] Cross-module beads specify which module provides what

#### Category 11: Granularity

**Backend granularity rules — one bead per:**
- Entity definition (+ enums — these group)
- EF configuration
- Contract set (DTOs, requests, responses for ONE entity)
- EntityMapper (create/update mapping, ONE direction: DTO→Entity)
- DTOMapper (read mapping, ONE direction: Entity→DTO)
- Each command (SaveCommand OR DeleteCommand OR lifecycle command — never combined)
- Each query (GetQuery OR GridQuery OR LookupQuery — never combined)
- Each endpoint (Save OR Get OR Grid OR Delete OR Lookup — never combined)
- Validator set (for one entity's request types)
- Service registration

**Frontend granularity rules — one bead per:**
- Models + enums (may group — same concern)
- Feature service
- List page
- Capture page (may include capture state if state is simple)
- Embedded list (per child entity)
- Routing

**Never combine (automatic GRANULARITY finding if violated):**
- Entity + Contracts (different projects)
- EntityMapper + DTOMapper (opposite data flow)
- Commands + Queries (CQRS violation)
- Endpoints + Commands/Queries (HTTP wiring vs business logic)
- Validators + Endpoints (validation rules vs HTTP lifecycle)
- List Page + Capture Page (different routes)
- Feature Service + any Component (service vs presentation)
- Routing + Components (infrastructure vs feature)
- Backend + Frontend (different tech stacks)

**Grouping exceptions (acceptable combinations):**
- Entity + Enum definitions
- DTOMapper + DataContext
- Multiple small endpoints for same entity IF each is under ~20 lines
- Models + Enum Constants (frontend)
- Capture State + Capture Page IF state is simple

---

### Phase 5: Cross-Bead Consistency

After reviewing individual beads, check cross-cutting concerns:

**Dependency graph integrity:**
- [ ] No circular dependencies (`br dep cycles`)
- [ ] Dependency graph is a DAG
- [ ] First bead(s) have zero dependencies and are ready to execute
- [ ] Epic depends on `verify({module}): module complete` gate (last bead)
- [ ] No `/review` or `/simplify` gate beads exist between implementation beads (these break future beads by deleting preparatory code)

**Naming consistency:**
- [ ] Entity names consistent across all beads (same casing, same abbreviation)
- [ ] Enum values consistent between entity beads and contracts beads
- [ ] Property names consistent between data model design and bead descriptions

**Pattern reference consistency:**
- [ ] Same pattern doc referenced by same bead type across entities (e.g., all SaveCommand beads reference `commands` pattern)
- [ ] No bead references a non-existent pattern doc

**Gate wiring:**
- [ ] Frontend beads depend on backend test gate, NEVER on backend impl beads
- [ ] Gate chain is complete: `/review` → `/simplify` → test (no missing link)
- [ ] UC gates depend on ALL contributing feature test gates (not a subset)
- [ ] Module gate depends on ALL UC gates

---

### Phase 6: Synthesize Report

**Step 6.1 — Write the review report:**

Write to `docs/reviews/review-beads-{feature}-{date}.md`.

```markdown
# Bead Review: {Feature Name}

> **Date:** {date}
> **Reviewer:** /review-beads skill v1.0
> **Beads reviewed:** {count} ({impl} implementation + {gates} gates + {tests} tests)
> **Upstream docs loaded:** {count}

## Executive Summary

**Verdict:** {PASS | PASS WITH FINDINGS | FAIL — MUST REMEDIATE}

| Severity | Count |
|----------|-------|
| CRITICAL | {N} |
| HIGH | {N} |
| MEDIUM | {N} |
| LOW | {N} |
| UPSTREAM_DOC | {N} |

{1-3 sentence summary of the most important issues}

## FR Coverage Matrix

{From Phase 2, Step 2.1}

## UC Coverage Matrix

{From Phase 2, Step 2.2}

## Granularity Decomposition

### Expected Bead Count Derivation
{From Phase 3, Step 3.2}

### Decomposition Specs
{From Phase 3, Step 3.4 — for each recommended split}

## Findings

### CRITICAL ({N})

#### C{N}. {Title}
| Field | Value |
|-------|-------|
| **Bead** | `{bead-id}: {title}` |
| **Class** | {finding class} |
| **Category** | {review category number and name} |
| **Defect** | "{quoted text from bead or description of omission}" |
| **Source** | {upstream doc path and section} |
| **Impact** | {what goes wrong during execution} |
| **Fix** | {concrete resolution} |

### HIGH ({N})
{Same format}

### MEDIUM ({N})
{Same format, abbreviated — no Source field}

### LOW ({N})
{One-line each: bead-id, class, issue, fix}

### UPSTREAM_DOC ({N})
{Issues in upstream docs, not bead defects. Listed for awareness.}
| Doc | Issue | Suggested Fix |
|-----|-------|---------------|

## Stage Gate Analysis

| Level | Expected | Actual | Status |
|-------|----------|--------|--------|
| Feature ({N}) × 6 | {expected} | {actual} | {OK / MISSING / EXTRA} |
| Use Case ({N}) × 2 | {expected} | {actual} | {OK / MISSING} |
| Module × 2 | {expected} | {actual} | {OK / MISSING} |

Gate wiring issues: {list or "None"}
Cadence violations: {list or "None — max {N} impl beads between gates"}

## Recommended Actions

### Immediate (block /execute)
1. {action} — fixes C{N}, C{N}
2. {action} — fixes C{N}

### Before first gate
1. {action} — fixes H{N}, H{N}

### Can fix during execution
1. {action} — fixes M{N}

## Post-Decomposition Bead Inventory

{Updated bead list reflecting all recommended splits and additions}

| # | Bead ID | Title | Type | Status |
|---|---------|-------|------|--------|
| 1 | bd-001 | {title} | impl | OK |
| 2 | bd-002 | {title} | impl | SPLIT → bd-002a, bd-002b |
| 3 | — | {new bead title} | impl | NEW (MISSING_BEAD fix) |
| 4 | bd-003 | {title} | gate | EMPTY — needs scope |
```

**Step 6.2 — Present executive summary to user:**

Read only the executive summary (~30 lines) from the report. Present it with the verdict.

**PAUSE:** Present findings and collect user decision.

Present the executive summary as formatted markdown, then:

```
AskUserQuestion:
  question: "How should we handle the bead review findings?"
  header: "Findings"
  multiSelect: false
  options:
    - label: "Fix all (Recommended)"
      description: "Remediate all CRITICAL and HIGH findings before /execute"
    - label: "Fix critical only"
      description: "Remediate CRITICAL findings only, accept HIGH as risk"
    - label: "Review specifics"
      description: "Walk me through the findings — I'll decide per-finding"
    - label: "Approved as-is"
      description: "Accept beads without changes. Findings are acceptable risk."
    - label: "Back to /beads"
      description: "Findings reveal structural issues. Regenerate beads."
```

If "Review specifics": use Guided Review (Pattern 5) to walk through findings by severity, starting with CRITICAL. For each finding, present the full detail and ask approve/reject/modify.

If "Fix all" or "Fix critical only": proceed to remediation — update bead descriptions via `br update`, add missing beads via `br create`, rewire dependencies via `br dep add/remove`.

---

## Batch Execution (COMPREHENSIVE mode)

For reviewing beads across multiple modules, use parallel agents with these rules:

### Worker Isolation

- Each worker owns ONE module's review output file
- Workers MUST NOT read or write each other's output files
- Each worker runs the full Phase 1-6 sequence independently
- Max 5 concurrent workers

### Execution

```bash
# Launch workers (example using Task tool)
# Worker 1: /review-beads roles-module
# Worker 2: /review-beads permissions-module
# Worker 3: /review-beads entitlements-module
```

### Convergence Criteria

- **Pass:** 0 CRITICAL findings across ALL modules
- **Conditional pass:** 0 CRITICAL, <5 HIGH total — proceed with remediation plan
- **Fail:** Any CRITICAL remaining after remediation attempt — return to `/beads`

### Retry Policy

- Each worker gets ONE retry on failure (tool timeout, incomplete review)
- On second failure: flag module as requiring manual review
- Never retry more than twice — the issue is likely in the upstream docs

### Consolidation

After all workers complete, produce a cross-module summary:

```markdown
## Cross-Module Bead Review Summary

| Module | Beads | Critical | High | Medium | Low | Verdict |
|--------|-------|----------|------|--------|-----|---------|
| Roles | 30 | 0 | 2 | 5 | 3 | PASS WITH FINDINGS |
| Permissions | 22 | 1 | 1 | 3 | 1 | FAIL |
| Entitlements | 15 | 0 | 0 | 2 | 4 | PASS |

### Cross-Module Issues
{Issues that span modules — shared contracts, dependency ordering, etc.}

### Remediation Priority
1. {Module}: {critical finding} — blocks all downstream
2. {Module}: {high finding} — blocks frontend
```

---

## Anti-Patterns

**Rubber-Stamp Review** — Marking all beads as "OK" without verifying against upstream docs. The entire value of this skill is adversarial verification. If the review finds zero issues on a non-trivial bead set, something was missed — re-examine the granularity decomposition.

**Flagging Style Over Substance** — Reporting findings about bead description formatting, section ordering, or wording preferences. These don't affect execution. Focus on content that would cause an agent to produce wrong code.

**Plan-Trust Over Design-Trust** — Verifying beads against the plan instead of the design. Plans are derived from designs and may have drifted. When plan and design disagree, the design is authoritative (see Trust Hierarchy).

**Cached-Read Findings** — Writing a finding based on what you remember the bead says without re-reading it. Beads get updated. Always `br show` before writing a finding.

**Missing Granularity Analysis** — Reviewing bead content without first counting expected beads from the design. Granularity decomposition (Phase 3) is the highest-signal phase — it catches missing beads and over-combined beads that content review alone misses.

**Inflated Severity** — Rating cosmetic issues as HIGH or missing FR tags as CRITICAL. Severity inflation causes users to ignore findings. Use the calibration examples strictly.

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "fix all" / "fix critical" | Remediate findings | Update beads, then re-verify |
| "approved" / "approved as-is" | Accept beads | Proceed to `/execute` |
| "back to /beads" | Structural issues | Return to `/beads` for regeneration |
| "review specifics" | Per-finding triage | Guided review walkthrough |

When approved: **"Bead review complete. Run /execute to start implementation."**

---

*Skill Version: 2.4*
*v2.4: Production feedback from Roles review. /review+/simplify gates downgraded from FAIL to DECISION (older bead sets may have them — user decides removal). Compact report auto-selected when 0 FAILs. Non-greenfield granularity method noted (count verification beads from Implementation Status, not greenfield decomposition tables).*
*v2.3: Category 7b aligned with beads v5.2+ — /review and /simplify gates prohibited (was required). Test/verify gate checks updated. Non-greenfield granularity method noted as needing different approach from greenfield decomposition tables. From Entitlements production review feedback.*
*v2.2: Removed /review and /simplify gate checks — these gate types no longer exist in beads v5.2. Updated cross-bead consistency to check for test/verify gates and flag any /review or /simplify gates as findings (they break the pipeline).*
*v2.1: Full-pipeline adversarial review fixes. FR acceptance criteria depth check (each Given/When/Then must map to a bead success criterion). Design Decision Coverage cross-reference (failure criteria must trace to design decisions, not be generic). From end-to-end pipeline review covering PRD→design→plan→beads→review-beads.*
*v2.0: CONVERGE mode with progressive loading, cascade check, same-session detection, WARN triage. Severity model aligned to FAIL/WARN (was class-only). Finding classification now includes default severity per class. Authority hierarchy aligned with siblings. Non-greenfield bead review guidance (verification beads, modify beads). Token budget estimate. Compact report format. From adversarial review against review-prd v2.3, review-design v2.5, and review-plan v2.6.*
*v1.0: Initial release. 11 review categories, 6-phase review process, severity calibration with examples, finding classification taxonomy, granularity decomposition with expected bead count derivation, FR/UC coverage matrices, stage gate analysis, batch execution support for multi-module reviews, anti-patterns.*
