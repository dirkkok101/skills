---
name: beads
description: >
  Use when the plan is approved, user says "create beads", "beads for...",
  or plan documents exist.
argument-hint: "[feature-name] or path to plan"
---

# Beads: Plan → Intent-Based Work Packages

**Philosophy:** A bead is a self-contained work package that an agent can pick up, understand, and execute without needing to read the full plan or design. The plan decided WHAT to build and in what order. Beads translate that into packages an agent can act on — each one carrying just enough context to produce working, tested code. Beads contain intent, not implementation. The agent writes code by understanding codebase patterns, not by copying snippets from the bead.

**Core Principles:**

1. **One bead per pattern artifact** — each bead aligns to a single pattern doc and produces one commit
2. **Surgical context** — each bead loads only the files needed for its single concern
3. **Self-contained** — an agent can execute without reading other beads
4. **Traceable** — every bead maps to FRs from the PRD
5. **Verifiable** — every bead has executable test commands
6. **Test gates** — test verification at semantic boundaries (NOT /review or /simplify between beads)

**Duration targets:** BRIEF ~10-15 minutes, STANDARD ~20-40 minutes, COMPREHENSIVE ~45-90 minutes. Most time should be spent on Phase 3 (self-assessment). If bead creation is fast but assessment reveals many "Needs" items, the plan's sub-plans may lack detail — consider going back to refine them.

## Why This Matters

A plan with 8 well-ordered tasks is useless if the executing agent can't figure out what to do with each one. Beads bridge the gap between planning and execution by packaging each task with:
- **Clear objective** — what to achieve in 1-2 sentences
- **Surgical context** — exactly which files to read and why
- **Pattern reference** — which pattern doc governs this artifact
- **Acceptance criteria** — how to know it's done (not "make sure it works")
- **Verification commands** — executable test commands, not vague instructions
- **Scope boundaries** — what's in scope and what explicitly isn't
- **Commit scope** — exactly one conventional commit per bead

The result: an agent can load a bead, read the referenced files, implement, verify, commit, and move on — without asking questions or guessing at intent.

---

## Trigger Conditions

Run this skill when:
- Plan has been approved (`/plan` completed)
- User says "plan approved", "create beads", "beads for..."
- Plan exists at `${PROJECT_ROOT}/docs/plans/{feature}/overview.md`

## No Interactive Review

This skill does NOT use AskUserQuestion. Beads are a mechanical decomposition of an already-approved plan. The user does not have context to evaluate individual beads. Create all beads, run self-assessment, present a one-line summary. Validation is done by `/review-beads CONVERGE`, not by the user during creation.

---

## Mode Selection

| Mode | Input Required | When | Output |
|------|---------------|------|--------|
| **BRIEF** | Single overview.md with inline tasks | BRIEF scope, 3-6 tasks | Beads created directly from overview tasks |
| **STANDARD** | overview.md + sub-plan files | STANDARD scope, typical feature | Beads created from sub-plans |
| **COMPREHENSIVE** | overview.md + sub-plans + risk register | COMPREHENSIVE scope, multi-service | Beads + risk-aware ordering + parallel tracks |

---

## Collaborative Model

```
Phase 0: Discover Project Documentation (build doc map)
Phase 1: Load Plan & Decompose into Pattern-Aligned Beads
Phase 2: Create Beads (epic, tasks, gates, dependencies)
Phase 3: Self-Assessment Gate (per-bead readiness + cross-bead review)
  ── Output: "{N} beads created. Run /review-beads or /execute." ──
```

**No user approval of individual beads.** The user approved the plan — beads are a mechanical decomposition of that plan. The user does NOT have enough context to evaluate individual bead descriptions. Do NOT present beads for review via AskUserQuestion. Do NOT ask the user to evaluate bead content, granularity, or dependencies.

Create all beads, run self-assessment, then present a ONE-LINE summary: "{N} beads created for {feature}. Self-assessment: all Ready. Run /review-beads CONVERGE for validation, or /execute to start."

The only user decision is: execute or validate first. Everything else is automated.

---

## Prerequisites

The skill needs these upstream artifacts, but their **exact paths vary by project**. Phase 0 discovers the actual locations — do not assume hardcoded paths.

**Required artifacts (discovered in Phase 0):**
- **Plan overview** (primary input) — task summary, dependency graph, FR coverage
- **Sub-plans** (STANDARD+ mode) — per-task intent, scope, acceptance criteria
- **Design docs** — API surfaces, data models, UI mockups, test plans
- **Pattern docs** — the pattern doc each bead aligns to
- **PRD** — FR references and acceptance criteria

**Optional artifacts (discovered in Phase 0, used when present):**
- **Decisions / ADRs** — architectural decisions constraining implementation
- **Architecture docs** — system context, data flow, infrastructure diagrams
- **Learnings** — compound learnings from past features
- **Reference docs** — cross-project integration patterns

Do not re-derive information that exists in these artifacts. Import it, reference it, build on it. Do not assume file names — use the doc map built in Phase 0.

---

## Bead Size Heuristic

**The right size is ONE pattern artifact:**

- One entity definition
- One EF configuration
- One set of contracts for an entity
- One mapper (EntityMapper OR DTOMapper, never both)
- One command (SaveCommand OR DeleteCommand, never both)
- One query (GetQuery OR GridQuery, never both)
- One endpoint (Save OR Get OR Grid, never multiple)
- One frontend component (List OR Capture, never both)
- One service

**Split signals (any of these → the bead is too coarse):**
- Bead touches more than one pattern doc
- Bead spans both API and Contracts projects
- Bead combines commands with queries (CQRS violation)
- Bead combines both data flow directions (Entity→DTO and DTO→Entity)
- Bead spans both backend and frontend
- Bead produces more than one conventional commit

**Context budget per bead:**
- **BRIEF mode:** Max 5 context files per bead
- **STANDARD mode:** Max 8 context files per bead
- **COMPREHENSIVE mode:** Max 12 context files per bead

If a single-pattern bead exceeds the context budget for its mode → split by sub-concern.
If the pattern artifact is trivially small → may combine per Grouping Exceptions.
If a bead genuinely needs more files than the budget, it's a split signal — the bead is likely too coarse.

**Large bead splitting heuristic:** If a bead will modify >8 files or references >3 pattern docs, it MUST be split. Split by sub-concern: separate data flow directions, separate API boundary from business logic, separate read-path from write-path. (Context files that are read-only references do not count toward the 8-file limit — only files the bead will create or modify.)

**Grouping exceptions (MAY combine):**
- Entity + Enum definitions (enums are part of entity definition)
- DTOMapper + DataContext (DataContext is input to DTOMapper)
- Multiple small endpoints for same entity IF each is under ~20 lines (e.g., Get + Lookup can combine)
- Models + Enum Constants (same concern on frontend)
- Capture State + Capture Page IF state is simple (single entity, no lifecycle)
- **Small feature slice** — entity + contracts + command + query + validator + endpoints + DI for a SINGLE simple entity (≤5 endpoints, no lifecycle, no complex validation) MAY be one bead if the total is ≤8 modified files. The principle: each bead should produce something independently testable via the API. A command without an endpoint isn't testable. If the feature is small enough to implement and test in one commit, it should be one bead.

**Entity beads that add new database tables/collections** must include the schema migration step in their scope (e.g., EF Core migration, Prisma migrate, Alembic revision, Flyway script). Without the migration, tests fail with cryptic DB errors that waste execution time debugging.

**Column constraint changes** (nullable→non-nullable, new FK, new unique index) must include test seed updates in the same bead. Changing a column from nullable to non-nullable breaks every test that inserts into that table with a null value. This is predictable — scope it upfront, not as a reactive fix.

**E2E / integration beads requiring different execution contexts** (Aspire AppHost, browser automation, Docker compose) should be tagged `execution-context:{type}` and placed in a separate epic or explicitly marked "separate-session" so the executor knows upfront they can't run in a standard test session.

**Compilation unit check:** After decomposing, verify each bead: "Can the codebase compile after ONLY this bead is implemented?" If not (e.g., bead removes a type that the next bead's code depends on), either merge the beads or mark them as an **atomic group** — they must be implemented together and produce a single compilable commit. Common cases: replacing a type system (boolean flags → OneOf result types), extracting a shared interface that multiple consumers reference.

**Frontend beads should be coarser than backend.** The natural frontend unit is "feature works end-to-end" — a component without routes is dead code, routes without grid integration are unreachable. Combine into coherent UI slices:
- "Create child route components + register routes" (not one bead per component)
- "Update grids + remove modals" (not separate grid-change and modal-removal beads)
The backend "one pattern artifact per bead" rule doesn't apply to frontend where components, routes, and state are tightly coupled.

**Verification beads can be batched.** Instead of 3 separate verify beads (contracts, commands, endpoints), one "verify backend implementation against design" bead that covers all related concerns is more efficient and produces the same result.

**Frontend verification beads must have a clear "verify or fix" policy.** Either:
- **"Verify and document"** — explicitly no fixes, output is a gap list for future beads
- **"Verify and fix"** — specific UI changes listed in scope
Don't leave it ambiguous — "verify frontend compliance" with no fix policy leads to beads that document gaps without resolving them, which feels incomplete.

**Never combine:**
- Entity/EF Config with Contracts (different projects)
- EntityMapper with DTOMapper (opposite data flow)
- Commands with Queries (CQRS)
- Endpoints with Commands/Queries (HTTP wiring vs business logic)
- Validators with Endpoints (validation rules vs HTTP lifecycle)
- **Backend with Frontend** (different tech stacks, different review cycles)

---

## Bead Decomposition Tables

The tables below show decomposition for a typical .NET/Angular vertical-slice architecture. **For other tech stacks, adapt the tables to your project's pattern docs.** The principle is the same: one bead per pattern artifact, resolved from the doc map built in Phase 0.

If your project uses different patterns (e.g., Python/FastAPI handlers, Go services, React components), build your decomposition table from your `docs/patterns/` directory using this algorithm:

**Decomposition Adaptation Algorithm:**
1. List all pattern docs in `docs/patterns/` (from Phase 0 doc map)
2. For each pattern doc, identify: what artifact it produces, what it depends on, what depends on it
3. Build a dependency-ordered table: each pattern doc → one bead type
4. Apply the same principles: one bead per pattern artifact, split signals (spans two projects → split), grouping exceptions (trivially small → combine)

Example for Python/FastAPI:
```
| # | Bead Type | Pattern Doc | Depends On |
|---|-----------|-------------|------------|
| 1 | {Module} Models | models.md | — |
| 2 | {Module} Schema | schema.md | #1 |
| 3 | {Module} Repository | repository.md | #1 |
| 4 | {Module} Service | service.md | #3 |
| 5 | {Module} Router | router.md | #4 |
| 6 | {Module} Tests | testing.md | #5 |
```

The tables below are the exemplar for .NET/Angular vertical-slice architecture.

### Backend Bead Decomposition (per entity/feature)

Each entity/feature in a module produces these beads, each aligned to ONE pattern doc. The "Pattern Key" column identifies which pattern to look up in the doc map built by Phase 0 — the actual file path comes from the map, not from a hardcoded location.

| # | Bead Title Convention | Pattern Key | What It Produces | Depends On (compile-order) |
|---|----------------------|-------------|------------------|------------|
| 1 | `{Entity} Entity + Enums` | `entity` | Entity class, enum types, base class inheritance | — (or cross-module entity deps) |
| 2 | `{Entity} EF Configuration` | `ef-configuration` | `IEntityTypeConfiguration<T>`, indexes, relationships, `HasConversion<string>()` | #1 |
| 3 | `{Entity} Contracts` | `requests` | DTO class, GridItemDTO, SaveRequest (inherits DTO), Response types — ALL in Contracts project | #1 |
| 4 | `{Entity} EntityMapper` | `entity-mapper` | DI-registered EntityMapper class, `EntityMapperResult<T>`, create/update logic | #1, #3 |
| 5 | `{Entity} DTOMapper` | `dto-mapper` | DI-registered DTOMapper class, DTOMapperDataContext if lookup data needed | #1, #3 |
| 6 | `{Entity} SaveCommand` | `commands` | SaveCommand class, upsert logic via EntityMapper | #4 |
| 7 | `{Entity} DeleteCommand` | `commands` | DeleteCommand class, `ExecuteDeleteAsync`, dependency checks | #1 |
| 8 | `{Entity} Lifecycle Commands` | `commands` | Enable/Disable/Suspend/Resume commands (if applicable) | #1 |
| 9 | `{Entity} GetQuery` | `queries` | GetQuery class, dual identifier support, 404-not-403 | #5 |
| 10 | `{Entity} GridQuery + QueryParameters` | `queries` | GridQuery, QueryParameters builder class, PagedResponse | #5 |
| 11 | `{Entity} LookupQuery` | `queries` | LookupQuery returning `NamedDTO[]` for dropdown binding | #5 |
| 12 | `{Entity} Validators` | `endpoints` | FluentValidation validator classes for each request type | #3 |
| 13 | `{Entity} Save Endpoint` | `endpoints` | IdentityEndpoint wiring SaveCommand | #6 |
| 14 | `{Entity} Get Endpoint` | `endpoints` | IdentityEndpoint wiring GetQuery | #9 |
| 15 | `{Entity} Grid Endpoint` | `endpoints` | POST endpoint wiring GridQuery | #10 |
| 16 | `{Entity} Delete Endpoint` | `endpoints` | IdentityEndpoint wiring DeleteCommand | #7 |
| 17 | `{Entity} Lookup Endpoint` | `endpoints` | IdentityEndpoint wiring LookupQuery | #11 |
| 18 | `{Entity} Lifecycle Endpoints` | `endpoints` | Enable/Disable/Suspend endpoints (if applicable) | #8 |
| 19 | `{Entity} Service Registration` | `service-registration` | `Add{Feature}Services()` in Services.cs | #4, #5, #6, #7, #9, #10, #11 |

**Not every entity needs all 19.** The skill should:
- Check the discovered `api-surface` doc for which endpoints exist → only create beads for those
- Check the discovered `data-model` doc for lifecycle states → only create lifecycle beads if applicable
- Check for lookup endpoints → only create lookup bead if the entity is dropdown-bindable
- Skip delete if the entity has no delete endpoint in the design

## Frontend Bead Decomposition (per feature)

Each feature's UI produces these beads:

| # | Bead Title Convention | Pattern Key | What It Produces | Depends On |
|---|----------------------|-------------|------------------|------------|
| 20 | `{Feature} Models + Enums` | `enums`, `feature-service` | TypeScript interfaces, `as const` enum objects | Backend test gate |
| 21 | `{Feature} Feature Service` | `feature-service` | Colocated HTTP service class, Promise-based API | #20 |
| 22 | `{Feature} List Page` | `list-page` | Standalone component with grid/table view | #21 |
| 23 | `{Feature} Capture Page` | `capture-page` | Standalone component with form fields | #21 |
| 24 | `{Feature} Capture State` | `capture-state` | Component-level Injectable for child route state management | #23 |
| 25 | `{Feature} Embedded List` | `embedded-list` | Child grid component with `model()` two-way binding (if children) | #21 |
| 26 | `{Feature} Routing` | `routing` | Lazy-loaded routes, child routes, canDeactivate guard | #22, #23 |

Not every feature needs all 7. Check the discovered `ui-mockup` doc:
- No capture page → skip #23, #24
- No child entities → skip #25
- No list page → skip #22

## Test Bead Decomposition

| # | Bead Title Convention | Pattern Key | What It Produces | Depends On |
|---|----------------------|-------------|------------------|------------|
| 27 | `{Feature} Integration Tests` | per discovered test plan | Backend integration tests | Last backend impl bead |
| 28 | `{Feature} UI Tests` | per discovered test plan | Frontend unit/component tests | Last frontend impl bead |

**Test bead sizing:** For greenfield test beads, target **≤15 new tests**. For modification/verification test beads (testing changes to existing code), target **≤25 tests** — modification tests are more cohesive because they test closely related changes, and splitting them by arbitrary count forces artificial seams between overlapping concerns. If the design's test plan specifies 40+ test cases for greenfield, decompose into per-area test beads (e.g., "MFA tests", "password flow tests", "magic link tests"). A 40-test bead is a mini-project, not a focused work package — the executing agent will either rush through it or close it incomplete.

## Infrastructure / Cross-Cutting Decomposition

The entity CRUD tables above don't apply to infrastructure features — authorization model rewrites, RLS policy additions, middleware changes, endpoint migrations, configuration refactors. These features have no entities to CRUD. Instead, decompose based on **plan task boundaries and compilation units**.

**When to use this section:** If the plan's tasks don't map to entity CRUD operations (no "Implement {Entity} CRUD"), use this decomposition method instead of the backend/frontend tables above.

**Decomposition algorithm for infrastructure features:**

1. **Start from plan tasks, not pattern tables.** Each plan task → 1-3 beads based on compilation units. A "compilation unit" is a set of changes that must be deployed together for the codebase to compile.

2. **Group by compile independence.** Ask: "Can this subset of changes compile independently from the rest?" If yes, it's a bead. If changes in two different files must exist simultaneously for compilation, they belong in the same bead.

3. **Split signals (same as entity beads):**
   - Bead modifies >8 files → split by concern
   - Bead spans API + Contracts projects → split by project
   - Bead combines creation + deletion of different abstractions → split
   - Bead touches both infrastructure (middleware, DI) and feature code → split

4. **Common infrastructure bead types:**

| Bead Type | What It Produces | Example |
|-----------|-----------------|---------|
| Constants/Definitions | New enum values, policy names, scope constants | `feat(auth): add permission type constants` |
| Interface/Contract | New interface, abstract class, or shared type | `feat(auth): add IPermissionEvaluator interface` |
| Implementation | Handler, service, middleware, guard | `feat(auth): add PermissionTypeHandler` |
| Registration/Wiring | DI registration, middleware pipeline, route config | `feat(auth): register permission services` |
| Migration/Configuration | Schema migration, config changes, seed data | `feat(auth): add permission type migration` |
| Endpoint Modification | Modify existing endpoints (authorization, validation) | `feat(auth): add scope authorization to approve endpoint` |
| Bulk Update | Apply same change across many files (e.g., add attribute to 20 endpoints) | `feat(auth): add authorization policies to admin endpoints` |

5. **Dependency wiring for infrastructure:** Wire compile-order dependencies only (Step 1.4b applies here too). Common pattern:
```
Constants ──┬── Interface ──── Implementation ──┐
            └── Migration                       ├── Registration → Test Gate
Endpoint Modifications (parallel, independent) ─┘
```

6. **Bulk update beads:** When a plan task says "apply X to all 93 endpoints," create per-module or per-feature beads, not one mega-bead. Each bead modifies endpoints in one feature directory. These are naturally parallel — no compile dependency between modifying endpoints in different features.

---

## Test Gates (NOT Review/Simplify Gates)

**Important: Do NOT insert `/review` or `/simplify` gate beads.** Earlier beads intentionally lay groundwork for later beads — review and simplify skills treat unused code as dead code and delete it, breaking the pipeline. Code review and simplification happen AFTER all beads in an epic are complete, not between beads.

Instead, insert **test gates** at semantic boundaries. Test gates verify that code works correctly before downstream beads build on it.

### Gate Types: Hard vs Soft

For multi-agent execution, distinguish two gate types to maximize parallel throughput:

**Hard gate** — downstream CANNOT start until this passes. Creates a `br dep add` dependency edge. Use for gates where downstream work would produce broken code:
- Schema migration gate before any bead that queries the new table/column
- Backend test gate before frontend beads (frontend can't test against broken API)
- Cross-module integration gate when Module B imports types from Module A

**Soft checkpoint** — downstream CAN start optimistically, but must verify this passed before committing. Does NOT create a `br dep add` dependency edge — instead, add a note in the downstream bead's description: `⚠ Soft checkpoint: verify {gate bead title} passed before committing.` Use for gates where downstream work is structurally independent but logically related:
- Compilation check gates (downstream agents can start — if compilation fails, they'll catch it in their own build step)
- UC verification gates when downstream beads are in a different feature slice
- Module completion gate (nothing depends on it — it's the epic terminus)

**Default:** All gates are **hard** unless explicitly marked soft. When in doubt, keep it hard — a slightly deeper critical path is safer than a broken build from optimistic parallelism.

`bv --robot-plan` computes parallel tracks from dependency edges. Soft checkpoints don't appear as edges, so they automatically widen the parallelism window without any change to br commands.

### Test Gate Placement

```
[backend impl beads] → test({feature}): integration tests [HARD]
  → [frontend impl beads] → test({feature}): UI tests [SOFT]
```

| # | Bead Title Convention | Type | Gate | Depends On | Purpose |
|---|----------------------|------|------|------------|---------|
| 1 | `test({feature}): integration tests` | test | Hard | Last backend impl bead (service registration) | **Blocks ALL frontend beads** — frontend can't test against broken API |
| 2 | `test({feature}): UI tests` | test | Soft | Last frontend impl bead (routing) | Advisory before UC gate — UC gate can start optimistically |

**Critical rule:** Frontend beads MUST depend on the backend test gate, never on raw backend implementation beads. This ensures backend code compiles and passes tests before frontend work begins.

### UC Verification Gates

After all feature slices contributing to a use case are tested:

```
test(A): UI tests + test(B): UI tests → verify({module}): UC-{ID}
```

| # | Bead Title Convention | Type | Gate | Depends On | Purpose |
|---|----------------------|------|------|------------|---------|
| 3 | `verify({module}): UC-{ID}` | test | Soft | All feature test gates for this UC | End-to-end scenario flow verification |

### Module Completion Gate

After all UC gates pass:

```
verify: UC-001 + verify: UC-002 → verify({module}): module complete
```

| # | Bead Title Convention | Type | Gate | Depends On | Purpose |
|---|----------------------|------|------|------------|---------|
| 4 | `verify({module}): module complete` | test | Soft | All UC verify gates | Final integration test. **Last bead in the epic.** Epic terminus — nothing depends on it. |

### Dependency Flow Visualization

For a module with features A and B, use case UC-001 spanning both:

```
Feature A (minimized DAG — compile-order edges only):
  bd-a1 (entity) ──┬── bd-a2 (EF config)
                    └── bd-a3 (contracts) ──┬── bd-a4 (entity mapper) → bd-a5 (save cmd) → bd-a12 (save endpoint) ──┐
                                            ├── bd-a5b (DTO mapper) ──┬── bd-a6 (get query) → bd-a13 (get endpoint) ┤
                                            │                        ├── bd-a7 (grid query) → bd-a14 (grid ep)     ┤
                                            │                        └── bd-a8 (lookup query) → bd-a15 (lookup ep) ┤
                                            ├── bd-a9 (delete cmd) → bd-a16 (delete endpoint) ─────────────────────┤
                                            └── bd-a10 (validators) ───────────────────────────────────────────────→┤
                                                                                         bd-a11 (registration) ←───┘
                                                → test(A): integration tests [HARD]
                                                  → bd-a17 (models) → bd-a18 (service) → bd-a19 (list page)
                                                  → bd-a20 (capture) → bd-a21 (routing)
                                                    → test(A): UI tests [SOFT]

Feature B:
  (same pattern — parallel with Feature A at all levels)

UC + Module (soft checkpoints — no br dep add edges):
  test(A): UI tests + test(B): UI tests
    ⚠→ verify(module): UC-001 [SOFT]
      ⚠→ verify(module): module complete [SOFT — EPIC CLOSES]
```

### When to Review Code

Run `/review` and `/simplify` AFTER the epic's `verify({module}): module complete` gate passes — when all beads are implemented and tested. At that point, all code exists and nothing is "dead code waiting for a future bead."

### Trust Hierarchy

When test or verification gates find issues, the fix priority follows this hierarchy (highest trust → lowest):

1. **ADRs & Patterns** — architectural intent, non-negotiable
2. **PRD** — business requirements
3. **Design docs** (api-surface, data-model, ui-mockup) — technical specification
4. **Plans & Sub-plans** — implementation breakdown
5. **Beads** — must conform to everything above
6. **Implementation code** — must conform to the bead's intent

---

## Critical Sequence

### Phase 0: Discover Project Documentation

Before creating beads, discover what documentation actually exists in the project. Projects vary — patterns may be flat or nested, decisions may live in `docs/adr/` or inside `docs/designs/{feature}/decisions/`, architecture docs may exist as a separate folder or be embedded in pattern docs. This phase builds a **doc map** that all subsequent phases reference.

**Context-aware Phase 0:** If upstream docs are already in conversation context (because prior skills like /discovery, /prd, /technical-design, /plan were run in this same session), skip the full doc tree scan. Instead:
1. Confirm the doc paths are still valid (quick glob check, not full content re-read)
2. Build the doc map from already-loaded context
3. Proceed directly to Phase 1

This avoids re-reading 20+ documents that are already in the context window. The full Phase 0 scan is needed only on cold starts where no upstream docs have been loaded.

**Step 0.1 — Scan the docs tree:**

Glob `docs/**/*.md` to find every markdown file in the documentation hierarchy. Group results by top-level directory:

```markdown
## Doc Tree Discovery

| Directory | Files Found | Examples |
|-----------|-------------|---------|
| docs/plans/ | {N} | overview.md, 01-scaffold.md, ... |
| docs/designs/ | {N} | design.md, api-surface.md, ... |
| docs/patterns/ | {N} | endpoints.md, queries.md, ... |
| docs/adr/ | {N} | 001-use-fastendpoints.md, ... |
| docs/architecture/ | {N} | system-context.md, ... |
| docs/prd/ | {N} | prd.md |
| docs/learnings/ | {N} | architecture.md, gotcha.md, ... |
| docs/reference/ | {N} | integration-patterns.md, ... |
| docs/reviews/ | {N} | review-20260303.md, ... |
```

**Step 0.2 — Build the doc map:**

For each category, resolve the actual file paths. The doc map is a lookup table that the rest of the skill uses instead of hardcoded paths.

**Plans (required):**
- Glob `docs/plans/{feature}/overview.md` and `docs/plans/{feature}/[0-9]*.md`
- If not found at this path, try `docs/plans/*/overview.md` and check for the feature name
- Record: `plan.overview`, `plan.sub-plans[]`

**Design docs (required for decomposition):**

Design docs may be organized in different ways. Search for these in order of specificity:

```
# Nested feature structure (e.g., Actions):
docs/designs/{feature}/features/{subfeature}/api-surface.md
docs/designs/{feature}/features/{subfeature}/backend.md
docs/designs/{feature}/features/{subfeature}/ui-mockup.md
docs/designs/{feature}/features/{subfeature}/test-plan.md

# Flat design structure:
docs/designs/{feature}/api-surface.md
docs/designs/{feature}/data-model.md
docs/designs/{feature}/ui-mockup.md

# Numbered prefix (e.g., 01-language-management):
docs/designs/[0-9]*-{feature}*/...

# Platform/infrastructure design:
docs/designs/{platform-service}/design.md
docs/designs/{platform-service}/diagrams/data-model.md
```

Map discovered files to semantic keys:

| Semantic Key | What It Contains | Search Terms |
|-------------|-----------------|--------------|
| `api-surface` | Endpoint routes, request/response shapes | `api-surface.md`, `api-spec.md`, `endpoints.md` |
| `data-model` | Entities, relationships, lifecycle states | `data-model.md`, `domain-model.md`, `backend.md` (check content) |
| `ui-mockup` | Pages, components, user flows | `ui-mockup.md`, `ui-mockups.md`, `frontend.md` |
| `test-plan` | Test scenarios, coverage matrix | `test-plan.md`, `test-scenarios.md` |
| `design-overview` | Problem statement, constraints, approach | `design.md`, `README.md` |

Record: `design.{key}` → actual file path. A feature may have multiple design docs per key if it has subfeatures.

**Pattern docs (required for bead alignment):**

Patterns may be flat (`docs/patterns/queries.md`) or nested (`docs/patterns/api/queries.md`). Search both:

```
docs/patterns/**/*.md
```

Map discovered files to pattern keys used in the decomposition tables:

| Pattern Key | Search Terms (filename contains) |
|------------|--------------------------------|
| `entity` | `entity`, `entities`, `domain-model` |
| `ef-configuration` | `ef-config`, `entity-type-config`, `persistence` |
| `requests` | `request`, `contracts`, `dto` |
| `entity-mapper` | `entity-mapper`, `entity-mapping` |
| `dto-mapper` | `dto-mapper`, `dto-mapping` |
| `commands` | `command` |
| `queries` | `quer` |
| `endpoints` | `endpoint` |
| `service-registration` | `service-reg`, `registration`, `di-config` |
| `feature-service` | `feature-service`, `http-service`, `angular-web` |
| `list-page` | `list-page`, `grid-page` |
| `capture-page` | `capture-page`, `form-page`, `detail-page` |
| `capture-state` | `capture-state`, `page-state` |
| `embedded-list` | `embedded-list`, `child-grid` |
| `routing` | `routing`, `routes` |
| `enums` | `enum` |
| `vertical-slice` | `vertical-slice`, `feature-implementation` |

If a pattern key has no match, record it as `MISSING` — this will be flagged in Step 3.1 (Pre-Assessment Verification).

**Decisions / ADRs (optional, used in gate bead context):**

Decisions may live in two places:
- `docs/adr/*.md` — project-level ADRs
- `docs/designs/{feature}/decisions/*.md` — feature-specific decisions

Scan both. Record: `decisions[]` → list of `{path, title, scope}` where scope is "project" or the feature name.

**Architecture docs (optional, used in gate bead context):**

- `docs/architecture/*.md` — standalone architecture docs
- `docs/designs/{platform-service}/diagrams/*.md` — infrastructure diagrams
- `docs/patterns/overview.md` — pattern index (often contains architecture overview)

Record: `architecture[]` → list of `{path, title}`.

**Learnings (optional, referenced in bead context):**
- `docs/learnings/*.md`

Record: `learnings[]` → list of `{path, category}`.

**Reference docs (optional, used in cross-project beads):**
- `docs/reference/*.md`

Record: `reference[]` → list of `{path, title}`.

**PRD (required for FR traceability):**
- `docs/prd/{feature}/prd.md` or `docs/prd/prd.md` or `docs/prd/*.md`

Record: `prd` → actual file path.

**Step 0.2b — Build path map (actual file locations):**

Before creating beads, discover where code actually lives in the project. Do NOT assume paths — glob for them:

```
# Find actual entity locations
glob: **/Features/**/*Entity*.cs OR **/Models/**/*.cs
# Find actual endpoint locations
glob: **/Features/**/*Endpoint*.cs OR **/Endpoints/**/*.cs
# Find actual frontend component locations
glob: **/src/app/**/*.component.ts
# Find actual test locations
glob: **/*Tests*/**/*Test*.cs OR **/*.spec.ts
```

Build a path map: `{entity name} → {actual directory}`. Use this map when writing bead descriptions — never use assumed paths like `src/app/features/` or `Features/{Entity}/`.

**Step 0.3 — Validate completeness:**

Check that the minimum required docs exist:

| Required | Found | Action If Missing |
|----------|-------|--------------------|
| Plan overview | ✅/❌ | **Block** — cannot create beads without a plan |
| At least one design doc with endpoint info | ✅/❌ | **Block** — cannot determine which beads to create |
| At least one design doc with entity/model info | ✅/❌ | **Warn** — entity beads will lack data model context |
| At least one pattern doc | ✅/❌ | **Warn** — beads will reference patterns by key without a file path |
| PRD | ✅/❌ | **Warn** — FR traceability will be incomplete |

If any blocking items are missing, stop and tell the user which upstream skill to run first.

**Step 0.4 — Record doc map (do NOT present to user):**

Record the doc map internally. Do NOT present it to the user or ask for confirmation — proceed directly to decomposition:

```markdown
## Documentation Map

**Feature:** {name}
**Project root:** {PROJECT_ROOT}

### Design Docs
| Key | Path | Status |
|-----|------|--------|
| api-surface | docs/designs/{feature}/features/{sub}/api-surface.md | Found |
| data-model | docs/designs/{feature}/diagrams/domain-model.md | Found |
| ui-mockup | docs/designs/{feature}/features/{sub}/ui-mockup.md | Found |
| test-plan | docs/designs/{feature}/features/{sub}/test-plan.md | Found |

### Pattern Docs
| Key | Path | Status |
|-----|------|--------|
| entity | docs/patterns/entity.md | Found |
| commands | docs/patterns/commands.md | Found |
| queries | docs/patterns/queries.md | Found |
| endpoints | docs/patterns/endpoints.md | Found |
| feature-service | docs/patterns/angular-web.md | Found |
| capture-state | — | MISSING |

### Decisions / ADRs
| Path | Scope | Title |
|------|-------|-------|
| docs/designs/{feature}/decisions/soft-delete.md | {feature} | Soft delete pattern |
| docs/adr/001-fastendpoints.md | project | Use FastEndpoints |

### Learnings
| Path | Category |
|------|----------|
| docs/learnings/architecture.md | architecture |
| docs/learnings/gotcha.md | gotcha |
```

If any pattern keys are MISSING, note them but continue — the self-assessment in Phase 3 will flag beads that reference missing patterns.

---

### Phase 1: Load Plan & Decompose into Pattern-Aligned Beads

**Step 1.0 — Scope Growth Check:**

Before creating beads, review brainstorm kill criteria. As you map tasks to beads, watch for scope growth — if splitting tasks produces significantly more beads than the plan anticipated, the feature may be larger than originally scoped:
- Plan estimated {N} tasks → bead mapping produces {M} beads
- If M > N × 1.5, flag: "Bead count ({M}) significantly exceeds plan task count ({N}). This suggests the work is larger than estimated. Kill criterion '{criterion}' may be at risk. Continue or return to plan?"

**Step 1.1 — Read Plan Coverage Tables (BEFORE decomposition):**

Read the plan's authoritative coverage tables. These are the source of truth — do NOT re-derive from design docs.

```
From plan overview.md, extract:
  FR Coverage table      → which FRs are covered by which tasks
  UC Coverage table      → which UCs are covered, with ordering constraints
  Design Coverage Matrix → which design elements (endpoints, entities, commands, queries) map to tasks
  Implementation Status  → gap analysis: New / Modify / Exists per element
  Failure Criteria       → per-task "Do NOT" guidance from design decisions
```

**Non-greenfield detection:** Check the Implementation Status table:
```
IF > 90% "Exists": Verification Mode — fast path (see below)
IF > 70% "Exists": Gap-driven — create beads only for "New" and "Modify" elements
IF < 30% "Exists": Greenfield — use standard pattern decomposition
ELSE: Hybrid — mix of greenfield beads for "New" and modify beads for "Modify"
```

**Verification Mode fast path (>90% exists):** The plan's Design Coverage Matrix already has element-by-element status. Skip the decomposition analysis — map directly from the plan:
- Each "Modify" element → 1 modification bead
- Each cluster of "Exists" elements in the same feature → 1 verification bead per feature (not per element)
- Test gates only (no UC/module verify gates for ≤10 implementation beads)
- Rely on plan's coverage tables for FR/UC/Design traceability. Spot-check source docs for file paths only (confirm they exist, don't re-read content).
- **Lighter bead descriptions:** For verification beads, use a compact format: objective + checklist + verification command. Skip the full template (In Scope, Out of Scope, Approach, Given/When/Then) — a verification bead is a checklist, not a construction blueprint.

**beads.md is the single source of truth.** Write all bead descriptions to `docs/plans/{feature}/beads.md`. This is the authoritative record — human-readable, diffable, and persistent. Create beads in br with short titles + dependencies + labels. For bead descriptions in br, use `br comments add` with a one-liner: "Full description: see docs/plans/{feature}/beads.md #{bead-number}". Do NOT duplicate the full description in br comments — it creates sync risk and wastes tokens.

**Verify "New" elements before decomposing:** For each element the plan marks as "New" in the Implementation Status, run a quick glob/grep to confirm it doesn't actually exist in the codebase. Plans can be stale — an element marked "New" may have been created since the plan was written. If it exists, reclassify as "Exists" or "Modify" before creating beads. Do this in Phase 1, not Phase 3 — wrong-type beads are expensive to fix.

**Scope growth check:** When comparing bead count to plan task count:
- Exclude gate beads from the count (they're mechanical, not scope growth)
- **Always compare against sub-task count.** The plan's top-level task count is too coarse — a plan with 16 tasks and 40 sub-tasks should produce ~40 implementation beads, not ~16. If the plan doesn't have explicit sub-tasks, count the distinct deliverables mentioned in each task's description.
- The 1.5x threshold applies to sub-task count: if sub-tasks = 40 and implementation beads = 64, that's 1.6x — technically over threshold but reasonable for infrastructure features where each sub-task may need 1-2 beads for compile independence. Flag if >2x.
- For Verification Mode (>90% exists): exempt from the threshold entirely — verification beads naturally multiply because each plan task decomposes into multiple verification concerns.
- For infrastructure/cross-cutting features: the entity decomposition tables don't set the expectation. The bead count is driven by compilation units, not entities × pattern types.

**br correction protocol:** br has no update-description command. When CONVERGE fixes a bead, use `br comments add` with a `## CORRECTION (review-beads round N)` header. Executing agents should read comments bottom-up (newest first). The original wrong content will still exist in earlier comments.

**br ID capture:** `br create ... --json` output can be fragile to parse inline. Preferred approach: create all beads first (titles + types + priorities), then query for IDs in a single batch with `br list --status open --json` or `br search "{feature}" --json`. Wire dependencies and add comments in a second pass using the queried IDs. This is more reliable than parsing each `br create` output inline and recovers gracefully if any single create command has unexpected output.

**Checkpoint/resume:** Before creating beads, check if beads already exist for this feature (search by epic title or feature label). If found:
- Present: "{N} beads already exist for {feature}. Delete and recreate, or resume?"
- Resume: skip to Phase 3 (self-assessment) on existing beads
- Delete: remove all existing beads, then proceed with full creation

**Incremental bead creation (plan updates):** When adding beads for a plan update (e.g., v0.1 → v0.2) rather than creating a full bead set from scratch:
- **Detect existing beads.md** — glob for `docs/plans/{feature}/beads*.md`. If found, create a versioned file (e.g., `beads-v0.2.md`) rather than overwriting. The original beads.md remains the record for the earlier version.
- **Reuse the existing epic** — do not create a new epic. Add new beads under the existing feature epic. If the epic is closed, reopen it.
- **Bead numbering** — use a version-prefixed convention to avoid ID collisions: `bd-v2-01`, `bd-v2-02`, etc. This makes it clear which plan version each bead belongs to.
- **Dependencies on existing beads** — new beads MAY depend on already-completed beads from the prior version (e.g., "depends on bd-007: Entity already exists"). Wire these as normal `br dep add` edges — br handles closed dependencies correctly.
- **Phase 0 can be skipped** — see "Context-aware Phase 0" below.

**Step 1.1b — Read Plan Sub-Plans and Design Docs:**

For each task in the plan, capture:
- Title and phase
- Objective (from sub-plan)
- Dependencies (from plan's dependency graph)
- FR references (from FR Coverage table — not re-derived)
- Acceptance criteria (from sub-plan or PRD)
- Scope boundaries (from sub-plan's in/out scope)
- **Failure Criteria** (from sub-plan — extracted from design decisions, "Do NOT" rules)

Additionally, read design docs (using paths from `design.*` in the doc map) to identify pattern-level detail:
- `design.api-surface` — endpoint routes, response codes, contract shapes
- `design.data-model` — entity fields, relationships, constraints
- `design.ui-mockup` — component hierarchy, form fields

**Step 1.2 — Decompose into Pattern-Aligned Beads:**

The decomposition strategy depends on the Implementation Status from Step 1.1:

**Greenfield path (<30% exists):** For each task in the plan, decompose into one bead per pattern artifact using the Backend/Frontend Bead Decomposition tables below.

**Hybrid path (30-70% exists):** Mix of greenfield and modification beads:
- **Status = "New":** Create standard pattern beads per decomposition tables (greenfield)
- **Status = "Modify":** Create ONE focused modification bead titled "Modify {Element}" with WHAT needs to change
- **Status = "Exists" (no changes):** Create a lightweight verification bead: "Verify {Element} matches design". The bead's success criteria are a checklist comparing existing code against design spec. This catches subtle issues (wrong return type, missing field) that coarse gap analysis misses.

**Gap-driven path (>70% exists):** For each design element in the plan's Design Coverage Matrix:
- **Status = "New":** Create standard pattern beads
- **Status = "Modify":** Create ONE focused modification bead with WHAT needs to change
- **Status = "Exists" (no changes):** Create a lightweight verification bead ONLY if the gap analysis or plan flags potential mismatches. If the plan says "Exists — matches design" with no caveats, do NOT create a verification bead — it will be a no-op that wastes an execution slot. Verification beads are for "exists but might not match" situations, not for confirming already-confirmed elements.

**Verification Mode (>90% exists):** Create verification beads that check existing code against design, plus targeted modification beads for the few gaps. Feature gates focus on "verify existing flows still work after changes."

**Verification bead template:**
```markdown
## Objective
Verify {Element} matches the design specification.

## Verification Checklist
- [ ] Class/file exists at expected path
- [ ] All properties/fields match design (names, types, constraints)
- [ ] Relationships/dependencies match design
- [ ] Pattern compliance (correct base class, correct conventions)

## Success Criteria
- All checklist items pass
- If any item fails → create a follow-up "Modify {Element}" bead

## In Scope — Test Alignment
If any verification fix changes observable behavior (status codes, response shapes,
error messages), update existing tests that assert on the changed behavior IN THE
SAME BEAD. Do not leave test alignment for a separate unplanned commit.

## Context to Load
- {Implementation files to verify}
- {Test files that assert on this element's behavior}

## Verification
- **Command:** `{build command}` — confirms no regressions
- **Commit:** No commit if all checks pass. If fixes needed, commit per fix.
```

**Step 1.2a — Identify entities and features:**

For greenfield: Read design docs to identify all entities and features.
For gap-driven: Read the plan's Design Coverage Matrix — it already lists every element with its status. Only create beads for "New" and "Modify" elements.

**Step 1.2b — Create backend beads:**

For greenfield: Create beads per entity from the Backend Bead Decomposition table.
For gap-driven: Create beads only for elements marked "New" or "Modify" in the plan's Design Coverage Matrix. Resolve each bead's pattern doc from the doc map.

**Step 1.2c — Create frontend beads:**

For greenfield: Create beads from the Frontend Bead Decomposition table.
For gap-driven: Create beads only for frontend elements marked "New" or "Modify".

**Step 1.2d — Create test beads:**
- One backend integration test bead per feature (depends on last backend impl bead)
- One frontend UI test bead per feature (depends on last frontend impl bead)
- For gap-driven: test beads verify BOTH new code AND that existing flows still work

**Step 1.2e — Apply grouping exceptions:**
Review the bead list for trivially small beads that can be combined per the Grouping Exceptions list in the Bead Size Heuristic section. Only combine when BOTH beads would be under ~20 lines of implementation.

**Step 1.2f — Auto-detect gate scale:**
```
IF total implementation beads ≤ 5 AND plan tasks ≤ 3:
  → BRIEF gates only (backend test + frontend test, no UC/module verify gates)
IF Verification Mode (>90% exists) AND implementation beads ≤ 10:
  → Lightweight gates (test gates only, skip UC/module verify — code mostly works already)
ELSE:
  → Standard gate structure per Step 1.3
```

**Step 1.3 — Insert Test Gates:**

After creating all implementation beads, insert test and verification gates:

1. **Identify feature slices** — group implementation beads by feature/entity
2. **Identify the last backend bead** per feature (usually service registration)
3. **Identify the last frontend bead** per feature (usually routing)
4. **Create test gates** (2 per feature):
   - `test({feature}): integration tests` — depends on last backend impl bead
   - `test({feature}): UI tests` — depends on last frontend impl bead
5. **Create UC verification gates** (1 per use case):
   - `verify({module}): UC-{ID}` — depends on all contributing feature test gates
6. **Create module completion gate** (1):
   - `verify({module}): module complete` — depends on all UC verify gates — **last bead in epic**

**Wire dependencies:**
- Test gates depend on the last impl bead of their phase
- Frontend impl beads depend on the backend test gate (NOT on backend impl beads)
- UC verify gates depend on all contributing feature test gates
- Module verify gate depends on all UC verify gates
- Epic depends on the module verify gate (making it the last bead)

**Do NOT insert /review or /simplify gate beads between implementation beads.** These skills treat code built for future beads as "dead code" and delete it. Run /review and /simplify AFTER the epic completes.

**Step 1.4 — Map Dependencies:**

Import dependencies from the plan's dependency graph. Beads inherit the ordering from the plan — don't re-derive it.

Within each feature's decomposed beads, wire internal dependencies following the decomposition tables:
- entity → EF config → contracts → mappers → commands/queries → endpoints → validators → registration

Test gates depend on the last implementation bead in their group and block the next group's first implementation bead.

**Step 1.4b — Dependency Minimization (multi-agent optimization):**

After wiring pattern-internal dependencies, minimize the DAG to maximize parallel execution tracks. For each dependency edge A → B, ask: "Will the codebase fail to compile if B is implemented before A?" If not, remove the edge. The goal is the **minimum DAG that preserves compilation order**, not the maximum DAG that preserves logical sequence.

**Common false dependencies to prune:**
- Contracts ↛ EF configuration — different projects, no compile dependency
- Validators ↛ commands/queries — validators reference request types from Contracts, not command/query classes
- Separate endpoint beads for the same entity — no compile dependency between GET and POST endpoints
- EntityMapper ↛ DTOMapper — opposite data flow directions, independent
- LookupQuery ↛ GridQuery — independent query types

**True dependencies to keep (compile-order):**
- Entity → EF configuration (EF config references the entity type)
- Entity → Contracts (DTOs mirror entity shape)
- Contracts → EntityMapper (mapper maps between entity and DTO)
- Contracts → DTOMapper (mapper maps between entity and DTO)
- EntityMapper → SaveCommand (command uses mapper)
- DTOMapper → GetQuery / GridQuery (queries use mapper)
- Commands/Queries → Endpoints (endpoints wire commands/queries)
- All impl beads → Service Registration (DI registers all services)

**Pruned decomposition table (per entity):**

After minimization, the dependency graph fans out after Contracts instead of forming a deep chain:

```
Entity ──┬── EF Config
         └── Contracts ──┬── EntityMapper → SaveCommand ──→ Save Endpoint ──┐
                         ├── DTOMapper ──┬── GetQuery → Get Endpoint ──────┤
                         │               ├── GridQuery → Grid Endpoint ────┤
                         │               └── LookupQuery → Lookup Endpoint─┤
                         ├── DeleteCommand → Delete Endpoint ──────────────┤
                         └── Validators ─────────────────────────────────→ ┤
                                                          Service Reg ←────┘
```

This produces ~4 parallel tracks after Contracts instead of the 1 deep chain from the unpruned table. `bv --robot-plan` computes tracks from the DAG — markdown annotations alone don't affect scheduling.

**Step 1.5 — Identify Parallel Tracks:**

Mark beads that can execute in parallel (no dependency between them). Parallel tracks must be reflected in the dependency wiring itself — if two beads are parallel, they MUST NOT have a dependency edge between them (even a transitive one through shared parents that would serialize them). `bv --robot-plan` computes tracks from the DAG, not from markdown annotations.

After wiring, verify: for any bead set with ≥10 implementation beads, `bv --robot-plan` should show ≥3 tracks. If it shows fewer, revisit Step 1.4b — false dependencies are likely still present.

```markdown
### Parallel Tracks
- Track A: bd-002 → bd-005 (user-facing flow)
- Track B: bd-003 → bd-006 (admin flow)
- Track C: bd-004 → bd-008 (validation flow)
- Tracks merge at: bd-009 (service registration)
```

**No PAUSE points in this skill.** Create all beads, run self-assessment, resolve any issues, present the one-line summary. No user interaction during creation.

---

### Phase 2: Create Beads

This phase creates work packages in the project's issue tracker. The examples below use `br` (beads-rust); adapt commands to your issue tracker as configured in your CLAUDE.md.

**Delegation for large bead sets (>40 beads):** For bead sets exceeding ~40 beads, the beads.md file will be too large to write inline (~100KB+). Delegate Phase 2 to a general-purpose sub-agent:
1. **Main context:** Complete Phase 0 (doc map) + Phase 1 (decomposition, dependency graph, parallel tracks). Produce a structured decomposition — bead titles, dependencies, FR mappings, gate placement — as the sub-agent's input.
2. **Sub-agent:** Writes beads.md (full bead descriptions) + creates beads in br (titles, dependencies, labels, comment pointers). Give the sub-agent the full decomposition, the doc map, and explicit instructions to follow the bead description format.
3. **Main context:** Run Phase 3 (self-assessment) on the sub-agent's output. The main context can verify cross-bead consistency, dependency integrity, and FR coverage without re-reading every bead description.

The sub-agent will make micro-decisions (exact file paths for Context to Load, Given/When/Then wording, Approach section guidance). Accept that these may need spot-check correction — Phase 3's proportional path validation catches the most impactful errors.

**Step 2.1 — Create Epic:**

Create a parent work item for the feature to link all beads under. Example: `br create "Feature: {feature-name}" --type feature -p 2`

Record epic ID for linking all beads.

**Step 2.2 — Create Each Implementation Bead:**

For each implementation bead, create a work item with the full bead description. Example: `br create "{Bead title}" --type task -p 2 --tag "FR-{MODULE}-{NAME}"`

**Bead Description Format:**

```markdown
## Objective
{What to achieve — ONE pattern artifact}

## Implements
{FR-IDs and/or UC-IDs this bead contributes to}

## Pattern
{Resolved from doc map pattern key — e.g., `commands` → `docs/patterns/commands.md`}

## Depends On
- bd-{id}: {title}
- (or "None" if no dependencies)

## In Scope
- {Specific deliverable 1}
- {Specific deliverable 2}

## Out of Scope
- {What is NOT in this bead — name the bead that handles it}

## Success Criteria
- {Observable outcome}

## Failure Criteria
- ❌ {Design decision constraint: "Do NOT use [rejected approach] — use [chosen approach] per [decision ref]"}
- ❌ {Pattern constraint: "Do NOT [anti-pattern] — use [correct pattern] per project pattern doc"}
- ❌ {Scope constraint: "Do NOT modify code outside this feature's scope"}

Failure criteria are propagated from the plan's sub-plan Failure Criteria section (extracted from design decisions). They encode the design's rejected alternatives as explicit "Do NOT" rules. Do NOT use generic criteria — every failure criterion should trace to a specific design decision or ADR.

## Context to Load
- **Read:** `{file path}` — {why}
- **Pattern:** `{file path}` — {why}
- **Reference:** `{doc path}` — {what to check}
- **Tests:** `{test file path}` — {tests that assert on this bead's changed behavior}
- **Downstream consumers:** `{file path}` — {files that import/reference types this bead changes}
- **First bead in module?** Also load: `docs/designs/{module}/design.md`, `docs/designs/{module}/data-model.md`, `docs/prd/{module}/prd.md`

## Files (reservation globs)
- `{file path or glob}` ({create|modify|delete})

List every file the bead will create, modify, or delete. Use exact paths for known files, globs for pattern-generated sets (e.g., `src/Features/Roles/**/*SaveCommand*.cs`). The `(create)` / `(modify)` / `(delete)` suffix tells coordinating agents the conflict risk — two agents creating new files in different directories won't conflict even without reservation, but two agents modifying the same file will.

This section is consumed by Agent Mail's `file_reservation_paths` — the executing agent passes these globs directly to claim file locks before starting work.

**Contract change beads** (DTOs, request/response types, models) must list downstream consumers — components, endpoints, or services that import the changed type. A model shape change that breaks 3 consumers is in-scope for the bead, or the consumers must be listed in "Out of Scope" with a note saying which bead handles them.

**Always include test files** that assert on the behavior being changed. For modification/migration beads, this means the test files for the endpoints or services being modified — not just the implementation files. A bead that changes a status code from 400→422 needs to list the test file that asserts on 400, or the executing agent will miss the test regression.

**Path validation (Phase 3) — proportional to bead count:** Verify that file paths in "Context to Load" actually exist. Scale the effort to the bead count:
- **≤20 beads:** Verify every path in every bead using glob/grep.
- **20-50 beads:** Verify every path in the first bead of each feature slice + spot-check 30% of remaining beads (random selection).
- **50+ beads:** Rely on Phase 0 code discovery paths. Spot-check 10 beads (prioritize beads with the most context files, and any bead touching unfamiliar directories). If Phase 0 was thorough, most paths will be correct.

Wrong paths are a common source of execution friction — the executing agent wastes time finding the right file. If a path doesn't exist, check for common mismatches: flat vs nested feature structure (e.g., `Features/Applications/Save/` vs `Features/Applications/Shared/Mappers/`), renamed files, or moved directories. Fix the path before finalizing the bead.

**Dependency validation (Phase 3):** For each bead, verify that referenced fields, types, and infrastructure actually exist in the codebase. If a bead references `Organization.BootstrapCompletedAt` and that field doesn't exist, the bead has an unmet dependency — it cannot be marked "Ready." Either add a prerequisite bead to create the missing infrastructure, or flag the bead as blocked.

## Approach
{Brief guidance on HOW to approach the work — not implementation code.
Reference design decisions and pattern docs.}

**For non-greenfield beads:** The approach must reference the ACTUAL code path, not the design's idealized approach. If the design says "call ConsumeAndRotateAsync" but the real fix is in ClaimsPrincipalBuilder, the approach should say "trace the token flow from {file} — the actual modification point is in {file}, not the command." The "Context to Load" section gets the right files loaded; the "Approach" section should explain what to do with them based on actual code, not design pseudocode.

## Acceptance Criteria
Given {precondition}
When {action}
Then {expected result}

## Verification
- **Test:** `{executable test command}` — verifies {what}
- **Build:** `{executable build command}` — confirms no regressions
- **Commit:** `{type}({scope}): {message}`
```

**Commit scope per bead — each bead produces ONE commit with a conventional commit message:**

```
feat({feature}): add {Entity} entity and enums
feat({feature}): add {Entity} EF configuration
feat({feature}): add {Entity} contracts
feat({feature}): add {Entity} entity mapper
feat({feature}): add {Entity} DTO mapper
feat({feature}): add {Entity} save command
feat({feature}): add {Entity} delete command
feat({feature}): add {Entity} get query
feat({feature}): add {Entity} grid query
feat({feature}): add {Entity} lookup query
feat({feature}): add {Entity} validators
feat({feature}): add {Entity} save endpoint
feat({feature}): add {Entity} get endpoint
feat({feature}): add {Entity} grid endpoint
feat({feature}): add {Entity} delete endpoint
feat({feature}): add {Entity} lookup endpoint
feat({feature}): add {Entity} service registration
feat({feature}): add {feature} models
feat({feature}): add {feature} service
feat({feature}): add {feature} list page
feat({feature}): add {feature} capture page
feat({feature}): add {feature} routing
test({feature}): add {feature} integration tests
test({feature}): add {feature} UI tests
```

**Step 2.3 — Create Test and Verification Gate Beads:**

For each gate identified in Step 1.3, create a gate bead.

**UC gate beads** verify end-to-end scenario flows, not just code quality:

```markdown
## Objective
Verify use case UC-{ID} end-to-end: {scenario description from plan's UC Coverage table}

## Scenario Verification
{Derive from plan's UC Coverage table — the Ordering column shows which tasks must execute sequentially}

### Main Scenario
1. {UC step 1} → verify {expected state}
2. {UC step 2} → verify {expected state}
3. {UC step N} → verify {postcondition}

### Error Paths
- {UC failure path 1} → verify {error handling}
- {UC failure path 2} → verify {recovery}

## Verification
- **Scenario test:** `{test command filtering UC-specific tests}`
- **Review:** `/review` on all contributing features
- **Build:** `{build command}`
```

UC gates depend on all contributing feature test gates. They verify SCENARIO FLOW (does the end-to-end user journey work?), not just code correctness (does each function work in isolation?).

**Module verification gate** runs the full integration test suite across all features. Include reference docs from `reference[]` in the doc map for cross-project alignment. This is the last bead in the epic.

Label all gate beads with `review` or `test` tag to distinguish them from implementation beads.

**Step 2.4 — Apply Labels:**

Categorise each bead by concern area (e.g., model, service, api, ui, test, integration, config, verify, gate). Labels help with parallel track identification and progress reporting. Do NOT use "review" or "simplify" as labels — these gate types are prohibited.

**Step 2.5 — Set Dependencies:**

Register dependencies between beads as specified in the plan's dependency graph plus the internal pattern dependencies. Verify:
- No circular dependencies
- The dependency tree reflects the plan's ordering plus pattern-internal ordering
- First bead(s) have no blockers and are ready to execute
- Frontend impl beads depend on backend test gate (NOT on backend impl beads)
- Test gates correctly placed after last impl bead per phase
- UC gates depend on all contributing feature test gates
- Module gates depend on all UC gates

**Stage gate dependency rules (hard edges only — soft checkpoints are advisory, not `br dep add`):**
- Backend test gate (HARD) depends on last backend impl bead
- Frontend impl beads depend on backend test gate (NEVER on backend impl beads directly)
- UI test gate (SOFT) — no `br dep add` from UI test gate to UC verify; UC verify notes "⚠ Soft checkpoint: verify test({feature}): UI tests passed before committing"
- UC verify gate (SOFT) — no `br dep add` to module gate; module gate notes the soft dependency
- Module verify gate (SOFT) — epic terminus, nothing depends on it
- Epic depends on module verify gate (for tracking, not blocking)

---

### Phase 3: Self-Assessment Gate

Every bead must pass a readiness check internally. This catches missing context, ambiguous objectives, and oversized beads. Resolve all issues before outputting the one-line summary. Do NOT present individual bead assessments to the user.

**Step 3.1 — Pre-Assessment Verification:**

Before assessing individual beads, verify structural integrity using the Phase 0 doc map:
- All context file references in beads point to files that actually exist in the codebase
- All pattern keys resolve to actual files in the doc map (flag any `MISSING` patterns from Phase 0)
- All FR references match FRs in the PRD (at `prd` in the doc map)
- Check `learnings[]` from the doc map for relevant learnings that should be referenced but aren't
- Check `decisions[]` from the doc map for ADRs/decisions that constrain any bead's implementation
- If decisions exist for the feature, add them to relevant bead context (especially gate beads)

**Step 3.2 — Assess Each Bead:**

For each bead, answer: "Can an agent execute this bead with the information provided, without needing to ask questions or guess at intent?"

| Status | Meaning | Action |
|--------|---------|--------|
| Ready | Clear objective, known pattern, manageable context | Proceed |
| Needs: [X] | Missing specific information | Resolve before presenting |
| Too Large | Context exceeds agent working memory | Split into sub-beads |

**Common "Needs" items:**
- Needs: pattern reference — which existing code to follow isn't specified
- Needs: clarification — objective has multiple interpretations
- Needs: context file — a dependency exists but isn't listed
- Needs: acceptance criteria — "done" state is ambiguous
- Needs: learning applied — a relevant past lesson isn't referenced
- Needs: verification command — test command is vague or missing

For gate beads, assess: "Does this gate bead have a clear scope, specific file paths to review, and executable verification commands?"

**Step 3.3 — Resolve Issues:**

For "Needs" items:
- Research and add the missing information to the bead
- Clarify the objective with more specific language
- Add concrete pattern references from the codebase

For "Too Large" items:
- Split into focused sub-beads
- Each sub-bead gets its own assessment
- Update dependencies for the new beads

**Step 3.4 — Cross-Bead Review:**

After individual assessment, review the full bead set against these themes:

**Completeness:**
- [ ] Every Must-Have FR covered by at least one bead?
- [ ] Every bead has acceptance criteria from the PRD?
- [ ] Every bead has executable verification commands?
- [ ] Dependencies imported from plan?

**Independence:**
- [ ] Each bead executable without reading other beads?
- [ ] Context references sufficient for the agent to proceed?
- [ ] No implicit knowledge required beyond what's referenced?
- [ ] Scope boundaries (in/out) defined?

**Pattern Alignment:**
- [ ] Each implementation bead references exactly one pattern doc?
- [ ] Each bead produces exactly one conventional commit?
- [ ] No bead combines commands with queries (CQRS)?
- [ ] No bead spans both API and Contracts projects?
- [ ] No bead combines both data flow directions?
- [ ] Backend and frontend are never combined in one bead?

**Sizing:**
- [ ] No bead exceeds agent context budget?
- [ ] No bead too small to test meaningfully (or combined per grouping exceptions)?
- [ ] Each bead produces a committable unit of work?

**Clarity:**
- [ ] Objectives state intent, not implementation?
- [ ] Success criteria are observable and testable?
- [ ] Failure criteria flag realistic anti-patterns?
- [ ] Context references point to files that exist?

**Traceability:**
- [ ] Every implementation bead tags the FR(s) it implements?
- [ ] FR coverage table has no Must-Have gaps?
- [ ] Beads reference design decisions where relevant?

**Test Gate Completeness:**
- [ ] Every feature slice has test gates for both backend and frontend?
- [ ] Frontend beads never depend directly on backend impl beads (depend on backend test gate)?
- [ ] Every use case has a verification gate?
- [ ] Module epic ends with `verify({module}): module complete` as final bead?
- [ ] Test/verify gates have executable verification commands?
- [ ] No `/review` or `/simplify` gate beads between implementation beads?

**Parallelism (multi-agent readiness):**
- [ ] Critical path depth ≤ ceil(total_beads / 3)? (heuristic: 3 agents should stay busy)
- [ ] At least 3 beads ready at the start (no dependencies)?
- [ ] No single bead blocks more than 40% of remaining beads?
- [ ] Hard gate beads fan out to ≥3 parallel tracks?
- [ ] Every bead has a `## Files (reservation globs)` section?

If any parallelism check fails, revisit dependency wiring in Step 1.4b — the graph is likely over-constrained. Common fix: remove pattern-sequence edges that aren't compile-order edges.

**File Reservation Completeness:**
- [ ] Every bead lists all files it will create, modify, or delete?
- [ ] Globs are specific enough to avoid overlapping reservations between parallel beads?
- [ ] No two parallel beads (no dependency edge) modify the same file?

**Step 3.5 — Record Assessment:**

```markdown
## Bead Readiness Assessment

| Bead | Status | Notes |
|------|--------|-------|
| bd-001: {title} | Ready | Pattern clear from existing code |
| bd-002: {title} | Ready | Service pattern known |
| bd-003: {title} | Needs: pattern | Which method handles detection? |
| bd-004: {title} | Too Large | Covers 3 different flows |

### Resolutions Applied

**bd-003:** Added context reference to DetectionService pattern
**bd-004:** Split into:
- bd-004a: Detection flow integration test
- bd-004b: Identification flow integration test
- bd-004c: Blocking flow integration test
```

**Re-assess until ALL beads show "Ready" and cross-bead review passes.**

**Step 4 — FR Coverage Check (with Acceptance Criteria):**

```markdown
### FR Coverage
| FR | Bead(s) | ACs Covered | Status |
|----|---------|-------------|--------|
| FR-{MODULE}-{NAME} (Must) | bd-{id} | AC1 ✅, AC2 ✅, AC3 ✅ | Covered |
| FR-{MODULE}-{NAME} (Must) | bd-{id}, bd-{id} | AC1 ✅, AC2 ✅, AC3 ⚠ | Partial — AC3 (error case) not in any bead |
| FR-{MODULE}-{NAME} (Should) | — | — | Deferred |
```

**Acceptance criteria level tracking:** For each Must-Have FR, read the PRD's Given/When/Then acceptance criteria. Verify each criterion maps to at least one bead's success criteria. An FR with 4 acceptance criteria where only 2 are addressed by beads is "Partial" not "Covered."

All Must-Have FRs must be fully covered (all ACs addressed). Flag any gaps as blocking.

**Step 4b — Design Decision Coverage Check:**

Verify that every design decision (from the plan's Design Decision Coverage table) is propagated as a failure criterion in at least one bead.

```markdown
### Design Decision Coverage
| Decision | Source | Bead(s) with Failure Criteria | Status |
|----------|--------|-------------------------------|--------|
| {decision} | decisions/{slug}.md | bd-{id}: "Do NOT use [rejected]" | ✅ Propagated |
| {decision} | decisions/{slug}.md | — | ⚠ NOT propagated — add to relevant bead |
```

Unpropagated design decisions are blocking — an executing agent without the failure criterion may re-derive the rejected approach.

**After self-assessment, present a brief status line — NOT a detailed review:**

```
"{N} beads created for {feature}. Self-assessment: all Ready.
Run /review-beads CONVERGE for validation, or /execute to start."
```

If the user wants more detail, they can ask. Do NOT proactively present coverage matrices, dependency trees, or bead tables. The user already approved the plan — they trust the decomposition.

If self-assessment found issues that were resolved, briefly note them:

```markdown
## Beads Complete

**Feature:** {name}
**Beads:** {N} implementation + {T} test/verify gates = {total}
**Non-greenfield:** {summary — e.g., "3 New, 5 Modify, 12 Verify"}
**Self-Assessment:** {N} Ready, {N} Resolved, {N} Split
**FR Coverage:** {N}/{N} Must-Have FRs fully covered (all ACs addressed)
**UC Coverage:** {N}/{N} UCs with end-to-end scenario flow
**Design Decision Coverage:** {N}/{N} decisions propagated as failure criteria

### Parallelism
- **Ready at start:** {N} beads (target: ≥3)
- **Critical path depth:** {N} (target: ≤ ceil({total_impl} / 3) = {target})
- **Max fan-in:** {bead title} blocks {N}% of remaining beads (target: ≤40%)
- **Parallel tracks:** {N} (from dependency DAG)

### Dependency Flow
{Compact ASCII showing bead phases and test gates}

### Issues Resolved During Self-Assessment
- {bd-{id}: what was fixed}
- {bd-{id}: what was split and why}
```

Do NOT use AskUserQuestion. Present the one-line summary and stop. The user will tell you what to do next.

---

## Bead Description — What Goes In, What Stays Out

### What Beads Contain

**Clear objective** — what to achieve, not how to code it:
```
Add verification tracking to the Account entity so the system can
distinguish verified from unverified accounts.
```

**Pattern reference** — which pattern doc governs this artifact:
```
- Pattern: {resolved `entity` key from doc map} — follow entity definition patterns
```

**Observable criteria** — testable outcomes, not vague goals:
```
- Property exists on Account entity
- Defaults to false for new accounts
- Persists correctly through the data layer
- Serialises in API responses
```

**Context references** — pointers to files, not duplicated content:
```
- Read: src/models/account.{ext} — understand existing status flag pattern
- Pattern: IsActive property — follow same structure and defaults
```

**Approach guidance** — rationale and direction, not code:
```
Follow the existing boolean property pattern. Use the same default
and persistence approach as IsActive. See design.md §Alternatives
for why we chose a boolean flag over a status enum.
```

**Executable verification** — commands that can be run, not descriptions:
```
- Test: {project test command} --filter "Account*Verified"
- Build: {project build command}
- Commit: feat(models): add IsVerified property to Account
```

### What Beads Do NOT Contain

**Source code** — the agent writes code from patterns, not from bead content. Including implementation creates false confidence and prevents the agent from adapting to the actual codebase state.

**Test code** — the agent designs tests from acceptance criteria. Pre-written tests can't account for the actual implementation shape.

**Duplicated content** — reference upstream docs, don't copy them. When the design changes, only one location should need updating.

---

## Examples

### Good Implementation Bead

```markdown
## Objective
Add IsVerified boolean property to Account entity to track when an account
has completed the verification process.

## Implements
- FR-ACCOUNT-VERIFY: Track account verification status

## Pattern
`entity` → `docs/patterns/entity.md` (resolved from doc map)

## Depends On
- None (first bead in sequence)

## In Scope
- IsVerified property on Account entity
- Default value for new accounts
- Data layer persistence
- API serialisation

## Out of Scope
- Verification workflow logic (bd-002)
- Email notifications (bd-004)
- Admin UI for verification status (bd-005)

## Success Criteria
- Property exists on Account entity
- Defaults to false for new accounts
- Persists correctly through data layer
- Appears in API responses

## Failure Criteria
- Don't add redundant properties that duplicate existing flags
- Don't break existing data serialisation or migrations

## Context to Load
- **Read:** `src/models/account.{ext}` — understand existing status flag pattern
- **Pattern:** `IsActive` property — follow same structure and defaults
- **Reference:** `docs/designs/account-verification/design.md` — design rationale

## Files (reservation globs)
- `src/models/account.{ext}` (modify)
- `src/migrations/*_AddIsVerified.{ext}` (create)

## Approach
Add boolean property following the pattern established by IsActive.
Use the same default value approach and persistence configuration.

## Acceptance Criteria
Given a new account is created
When no verification has occurred
Then IsVerified is false

Given an account exists
When the verification process completes
Then IsVerified is set to true and persisted

## Verification
- **Test:** `{project test command} --filter "Account*Verified"`
- **Build:** `{project build command}`
- **Commit:** `feat(models): add IsVerified property to Account`
```

### Good Test Gate Bead

```markdown
## Objective
Run integration tests for the {feature} feature slice. All backend beads
are complete — verify the code compiles and tests pass.

## Depends On
- bd-{id}: {last backend bead} (last backend bead)

## In Scope
- All backend code in the feature directory
- Integration tests covering all endpoints

## Success Criteria
- `{build command}` succeeds
- `{test command} --filter "Role"` passes — all tests green

## Verification
- **Command:** `{build command} && {test command} --filter "Role"`
- **Commit:** `test(roles): verify backend integration tests pass`
```

### Bad Bead

```markdown
## Task 2

Add the IsVerified property:
  isVerified = false

Then add this test:
  test Account_HasIsVerifiedProperty:
      account = new Account(isVerified: true)
      assert account.isVerified == true

See plan for details.
```

**Why bad:**
- Contains implementation code (agent should write this from patterns)
- Contains test code (agent should design tests from criteria)
- Vague "see plan" — no specific context references
- No pattern reference — agent doesn't know which pattern to follow
- No success/failure criteria — agent can't self-verify
- No scope boundaries — agent might drift into related work
- No verification commands — agent doesn't know how to test
- No commit scope — agent doesn't know the commit message

---

## Example: Plan Task → Pattern Beads

**Plan says:**
> Task 3: Implement Role CRUD — Save, Get, Grid, Delete endpoints with full project pattern alignment

**`/beads` skill produces (reading api-surface.md to confirm which endpoints exist):**

```
bd-001: Role Entity + Enums
bd-002: Role EF Configuration
bd-003: Role Contracts (RoleDTO, RoleGridItemDTO, SaveRoleRequest, SaveRoleResponse, DeleteRoleResponse)
bd-004: Role EntityMapper
bd-005: Role DTOMapper
bd-006: Role SaveCommand
bd-007: Role DeleteCommand
bd-008: Role GetQuery
bd-009: Role GridQuery + QueryParameters
bd-010: Role LookupQuery
bd-011: Role Validators
bd-012: Role Save Endpoint
bd-013: Role Get Endpoint
bd-014: Role Grid Endpoint
bd-015: Role Delete Endpoint
bd-016: Role Lookup Endpoint
bd-017: Role Service Registration
  → test(roles): integration tests
bd-018: {Feature} Models + Enums
bd-019: {Feature} Feature Service
bd-020: {Feature} List Page
bd-021: {Feature} Capture Page
bd-022: {Feature} Routing
  → test(roles): UI tests
  → verify(roles): UC-ROLE-001
  → verify(roles): module complete
```

**17 backend + 5 frontend + 4 test/verify gates = 26 beads** for one feature. Each bead is a focused, single-pattern, single-commit unit of work.

---

## Bead Count Comparison

For a typical module with 3 entities, 3 UI features, and 2 use cases:

**Before (coarse task-level beads):**
- ~10 coarse task-level beads + ~3 review beads = ~13 total
- Each bead bundles 3-5 pattern artifacts
- Agent must hold multiple concerns in context
- One failing concern blocks the entire bead

**After (pattern-granular + test gates):**
- ~45 pattern-aligned impl beads (15 backend × 3 entities + 5 frontend × 3 features + 6 tests)
- ~6 test gates (2 per feature × 3 features)
- ~2 UC verify gates (1 per UC × 2 UCs)
- ~1 module verify gate
- **Total: ~54 beads**

**Why more beads is better:**
1. Each bead is faster to execute — smaller context, single concern, clear pattern reference
2. Each bead is independently verifiable — one commit, one test scope, one review target
3. Parallelism — independent beads (e.g., EntityMapper and DTOMapper) can execute concurrently across multiple agents via `bv --robot-plan` track computation
4. Defects caught early — gate beads at feature boundaries, not after the entire module
5. Frontend never builds on broken backend — test gates enforce verification before UI work
6. Git history is useful — each commit is one pattern artifact, easy to revert or cherry-pick
7. Eliminates the "fix everything at the end" anti-pattern — quality is continuous, not deferred
8. Test gates are fast — running tests on a single feature takes seconds, not hours

---

## Bead Quality Signal

The ultimate test of bead quality is execution. If agents frequently need to ask questions during /execute, the beads need improvement. Well-written beads should be executable with minimal or no clarification.

Track this across features: if the same types of questions recur (missing pattern references, ambiguous criteria, unclear scope), capture that as a compound learning so future beads avoid the same gaps.

---

## Anti-Patterns

**The Code Bead** — Including source code or test code in the bead description. The agent should write code from codebase patterns, not copy from beads. Code in beads becomes stale, creates false confidence, and prevents the agent from learning project conventions. Beads that contain code also tend to be fragile — any refactoring of the codebase invalidates the bead's snippets.

**The Kitchen Sink** — Packing everything into one bead because "it's all related." If a bead touches multiple pattern docs or spans both API and Contracts projects, it's too large. Split by pattern artifact. Large beads produce large diffs that are harder to review and more likely to conflict with parallel work.

**The CQRS Violation** — Combining commands and queries in one bead. These have fundamentally different data flow directions and responsibilities. SaveCommand and GetQuery should always be separate beads.

**The Cross-Stack Bead** — Combining backend and frontend work in one bead. Different tech stacks, different review cycles, different test frameworks. Backend test gates must pass before frontend work begins.

**Vague Verification** — "Make sure it works" or "Test thoroughly." Give executable commands with specific filters. If you can't write a verification command, the acceptance criteria aren't specific enough — fix the criteria first, then the verification follows naturally.

**Plan Duplication** — Copying paragraphs from the design doc or plan into every bead. Reference the upstream doc with a file path and section pointer. Duplication drifts and creates conflicting sources of truth — when the design changes, every bead with copied content becomes stale.

**Missing Scope Boundaries** — Without an "Out of Scope" section, agents tend to expand their work into adjacent areas. Explicit boundaries prevent scope creep and keep each bead focused. The most effective boundaries name the OTHER bead that handles the excluded work.

**Dependency Amnesia** — Creating beads without importing the plan's dependency graph. Dependencies should flow directly from the plan. Re-deriving them risks introducing circular dependencies or breaking the critical path that was carefully designed in /plan.

**Skipped Test Gates** — Not inserting TEST gate beads or allowing frontend beads to depend directly on backend implementation beads. Frontend beads MUST depend on the backend test gate, never on raw backend impl beads. However, do NOT insert `/review` or `/simplify` gate beads — only test and verify gates. `/review` and `/simplify` run AFTER the epic completes, not between beads.

---

## BRIEF Mode

For BRIEF scope (3-6 tasks from a BRIEF plan), create beads directly from the overview's inline task descriptions. No sub-plans to import — the overview IS the plan.

The bead format is identical. The only difference is that you extract objectives and criteria from the overview's inline task descriptions rather than from separate sub-plan files.

For BRIEF scope, test gates are simplified:
- One test gate after all backend beads
- One test gate after all frontend beads (if applicable)
- Skip UC and module verify gates (there's typically only one use case in BRIEF scope)

---

## Output Structure

Beads live in the project's issue tracker (e.g., `br` database), not as files. The output of this skill is:
- An epic linking all beads
- Individual implementation beads with full descriptions and pattern references
- Test gate beads at feature boundaries
- Verify gate beads at UC and module boundaries
- Dependencies set between all beads (implementation → test gates → next phase)
- Labels applied for categorisation
- Self-assessment completed with all beads Ready

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "beads approved" / "accept" | All beads ready | Proceed to /execute |
| "adjust bd-{id}" | Modify specific bead | Update and re-assess |
| "reassess" | Re-run assessment gate | Return to Phase 3 |
| "back to plan" | Plan needs changes | Return to /plan |

**On approval:** "Beads approved. Run /execute to start implementation."

---

*Skill Version: 5.18 — [Version History](VERSIONS.md)*
