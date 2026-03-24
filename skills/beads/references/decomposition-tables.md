# Beads Decomposition Reference

Stable decomposition content extracted from the beads skill. This file is the authoritative reference for bead sizing, decomposition tables, test gates, and adaptation to non-.NET projects.

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

### Decomposition Adaptation Algorithm

If your project uses different patterns (e.g., Python/FastAPI handlers, Go services, React components), build your decomposition table from your `docs/patterns/` directory using this algorithm:

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

### Backend Bead Decomposition (per entity/feature)

Each entity/feature in a module produces these beads, each aligned to ONE pattern doc. The "Pattern Key" column identifies which pattern to look up in the doc map built by Phase 0 — the actual file path comes from the map, not from a hardcoded location.

| # | Bead Title Convention | Pattern Key | What It Produces | Depends On |
|---|----------------------|-------------|------------------|------------|
| 1 | `{Entity} Entity + Enums` | `entity` | Entity class, enum types, base class inheritance | — (or cross-module entity deps) |
| 2 | `{Entity} EF Configuration` | `ef-configuration` | `IEntityTypeConfiguration<T>`, indexes, relationships, `HasConversion<string>()` | #1 |
| 3 | `{Entity} Contracts` | `requests` | DTO class, GridItemDTO, SaveRequest (inherits DTO), Response types — ALL in Contracts project | #1 |
| 4 | `{Entity} EntityMapper` | `entity-mapper` | DI-registered EntityMapper class, `EntityMapperResult<T>`, create/update logic | #1, #3 |
| 5 | `{Entity} DTOMapper` | `dto-mapper` | DI-registered DTOMapper class, DTOMapperDataContext if lookup data needed | #1, #3 |
| 6 | `{Entity} SaveCommand` | `commands` | SaveCommand class, upsert logic via EntityMapper | #4 |
| 7 | `{Entity} DeleteCommand` | `commands` | DeleteCommand class, `ExecuteDeleteAsync`, dependency checks | #1, #2 |
| 8 | `{Entity} Lifecycle Commands` | `commands` | Enable/Disable/Suspend/Resume commands (if applicable) | #1 |
| 9 | `{Entity} GetQuery` | `queries` | GetQuery class, dual identifier support, 404-not-403 | #5 |
| 10 | `{Entity} GridQuery + QueryParameters` | `queries` | GridQuery, QueryParameters builder class, PagedResponse | #5 |
| 11 | `{Entity} LookupQuery` | `queries` | LookupQuery returning `NamedDTO[]` for dropdown binding | #5 |
| 12 | `{Entity} Validators` | `endpoints` | FluentValidation validator classes for each request type | #3 |
| 13 | `{Entity} Save Endpoint` | `endpoints` | IdentityEndpoint wiring SaveCommand | #6, #12 |
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

### Frontend Bead Decomposition (per feature)

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

### Test Bead Decomposition

| # | Bead Title Convention | Pattern Key | What It Produces | Depends On |
|---|----------------------|-------------|------------------|------------|
| 27 | `{Feature} Integration Tests` | per discovered test plan | Backend integration tests | Last backend impl bead |
| 28 | `{Feature} UI Tests` | per discovered test plan | Frontend unit/component tests | Last frontend impl bead |

**Test bead sizing:** Each test bead should target **≤15 new tests**. If the design's test plan specifies 40+ test cases, decompose into per-area test beads (e.g., "MFA tests", "password flow tests", "magic link tests"). A 40-test bead is a mini-project, not a focused work package — the executing agent will either rush through it or close it incomplete.

---

## Test Gates

**Important: Do NOT insert `/review` or `/simplify` gate beads.** Earlier beads intentionally lay groundwork for later beads — review and simplify skills treat unused code as dead code and delete it, breaking the pipeline. Code review and simplification happen AFTER all beads in an epic are complete, not between beads.

Instead, insert **test gates** at semantic boundaries. Test gates verify that code works correctly before downstream beads build on it.

### Test Gate Placement

```
[backend impl beads] → test({feature}): integration tests
  → [frontend impl beads] → test({feature}): UI tests
```

| # | Bead Title Convention | Type | Depends On | Purpose |
|---|----------------------|------|------------|---------|
| 1 | `test({feature}): integration tests` | test | Last backend impl bead (service registration) | **Blocks ALL frontend beads** |
| 2 | `test({feature}): UI tests` | test | Last frontend impl bead (routing) | Blocks UC gate |

**Critical rule:** Frontend beads MUST depend on the backend test gate, never on raw backend implementation beads. This ensures backend code compiles and passes tests before frontend work begins.

### UC Verification Gates

After all feature slices contributing to a use case are tested:

```
test(A): UI tests + test(B): UI tests → verify({module}): UC-{ID}
```

| # | Bead Title Convention | Type | Depends On | Purpose |
|---|----------------------|------|------------|---------|
| 3 | `verify({module}): UC-{ID}` | test | All feature test gates for this UC | End-to-end scenario flow verification |

### Module Completion Gate

After all UC gates pass:

```
verify: UC-001 + verify: UC-002 → verify({module}): module complete
```

| # | Bead Title Convention | Type | Depends On | Purpose |
|---|----------------------|------|------------|---------|
| 4 | `verify({module}): module complete` | test | All UC verify gates | Final integration test. **Last bead in the epic.** |

### Dependency Flow Visualization

For a module with features A and B, use case UC-001 spanning both:

```
Feature A:
  bd-a1 (entity) → bd-a2 (EF) → bd-a3 (contracts) → bd-a4 (mappers)
    → bd-a5 (commands) → bd-a6 (queries) → bd-a7 (endpoints)
    → bd-a8 (validators) → bd-a9 (registration)
      → test(A): integration tests
        → bd-a10 (models) → bd-a11 (service) → bd-a12 (list page)
        → bd-a13 (capture) → bd-a14 (routing)
          → test(A): UI tests

Feature B:
  bd-b1 → ... → bd-b9
    → test(B): integration tests
      → bd-b10 → ... → bd-b14
        → test(B): UI tests

UC + Module:
  test(A): UI tests + test(B): UI tests
    → verify(module): UC-001
      → verify(module): module complete [EPIC CLOSES]
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
