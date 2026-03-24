# Bead Review Checklists & Calibration Reference

Extracted from the review-beads skill. This file contains the verbose category checklists, granularity decomposition tables, and severity calibration examples. The main SKILL.md retains finding classification and phase structure.

For shared severity model and finding quality standards, see: `../../_shared/references/review-finding-taxonomy.md`

---

## Category Checklists (Phase 4: Bead-by-Bead Deep Review)

For each bead, review against all 11 categories. Not every category applies to every bead — skip inapplicable checks.

### Category 1: FR Coverage

- [ ] Every Must-Have FR in the PRD has at least one bead
- [ ] No phantom FRs — bead doesn't claim to implement an FR that doesn't exist in the PRD
- [ ] Coverage is complete, not partial — if FR requires backend + frontend, both exist
- [ ] PRD acceptance criteria are reflected in bead success criteria (Given/When/Then alignment)
- [ ] FR priority matches bead existence — Must-Have FRs are never deferred

### Category 2: Use Case Coverage

- [ ] Every main scenario step has a bead (or is covered by a bead's scope)
- [ ] Every extension flow has a bead or is in a bead's failure criteria
- [ ] Every alternative flow has a bead or is in a bead's out-of-scope with justification
- [ ] Error conditions appear as failure criteria in relevant beads
- [ ] Actor-specific behavior is preserved — if UC says "admin sees X", the bead doesn't genericize to "user sees X"

### Category 3: Design Compliance

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

### Category 4: Architecture Compliance

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

### Category 5: API Pattern Compliance

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

### Category 6: Web Pattern Compliance

- [ ] UI component library — beads reference the project's component library first (check project CLAUDE.md or pattern docs for component names)
- [ ] Feature-colocated services — HTTP service class lives with the feature, not in a shared folder
- [ ] Signal state — component state uses Angular signals, not BehaviorSubjects
- [ ] Standalone components — no NgModules, no CommonModule imports
- [ ] Zoneless — no manual change detection (no `ChangeDetectorRef`, no `NgZone.run`)
- [ ] Routing — lazy-loaded routes, child routes for list-to-capture navigation, canDeactivate guards
- [ ] Enum patterns — `as const` objects, not TypeScript enums
- [ ] Model definitions — interfaces (not classes) for DTOs, matching backend property names

### Category 7: Test Coverage

- [ ] Test plan from design doc is traceable to test beads
- [ ] Test beads specify executable commands (`dotnet test --filter`, `ng test`)
- [ ] Negative test cases present — what should fail, not just what should succeed
- [ ] RLS test cases — if entity has tenant isolation, tests verify it
- [ ] Integration test infrastructure — bead references Testcontainers Postgres (not in-memory)
- [ ] UI test infrastructure — bead references Vitest (not Jasmine/Karma)

### Category 7b: Test & Verification Gates

**Gate policy:** `/review` and `/simplify` gate beads between implementation beads are prohibited (they treat preparatory code as "dead code" and delete it). Only test and verify gates are allowed. If `/review` or `/simplify` gates are found, classify as DECISION (not FAIL) — the user chooses whether to remove them. Older beads sets may have been generated before this policy; removal is the recommended resolution but not automatic.

- [ ] **No `/review` or `/simplify` gate beads between sequential implementation beads** — flag as DECISION if found between impl beads that build on each other (dangerous — may delete preparatory code). Gates at phase boundaries before test beads are defensible and may be kept — note as observation, not DECISION.
- [ ] Backend test gate blocks frontend beads (frontend depends on backend test gate)
- [ ] UC verification gates exist for each use case (verify scenario flow, not just code review)
- [ ] Module verification gate exists as final bead in epic
- [ ] Cadence check — no more than 4-5 implementation beads between consecutive test gates
- [ ] Gate beads have executable verification commands (test commands, not vague "review code")
- [ ] Gate beads have correct dependency wiring (impl -> test -> next phase)
- [ ] No empty gates — every gate specifies what tests to run
- [ ] No orphaned gates — every gate has downstream beads that depend on it
- [ ] For Verification Mode (>90% exists): lightweight gates acceptable (test only, no UC/module verify for <=10 impl beads)

### Category 8: Bead Quality

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

### Category 9: No Backwards Compatibility

- [ ] No compatibility shims — no old API route preservation alongside new routes
- [ ] No adapter layers — no translation between old and new contract shapes
- [ ] No old API preservation — deprecated endpoints are removed, not maintained
- [ ] Cleanup beads exist — if old code is being replaced, a bead removes the old code
- [ ] No migration beads — app is pre-deployment, no incremental data migrations

### Category 10: Cross-Module Dependencies

- [ ] Dependencies match wired links — `br dep list` matches bead's `## Depends On`
- [ ] No hidden assumptions — bead doesn't assume another module's entity/service exists without a dependency
- [ ] Shared contracts created before consuming beads — if Feature B uses Feature A's DTO, the contracts bead for A is wired as a dependency
- [ ] Cross-module beads specify which module provides what

### Category 11: Granularity

**Backend granularity rules — one bead per:**
- Entity definition (+ enums — these group)
- EF configuration
- Contract set (DTOs, requests, responses for ONE entity)
- EntityMapper (create/update mapping, ONE direction: DTO->Entity)
- DTOMapper (read mapping, ONE direction: Entity->DTO)
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

## Granularity Decomposition Tables (Phase 3)

These tables define the expected bead count derived from design documents.

### From Data Model (per entity)

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

### From API Surface (per entity)

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

### From UI Mockup (per feature)

| Design Artifact | Expected Bead | Condition |
|----------------|---------------|-----------|
| TypeScript interfaces | `{Feature} Models + Enums` | Always |
| HTTP service | `{Feature} Feature Service` | Always |
| List/grid page | `{Feature} List Page` | Has list page |
| Capture/form page | `{Feature} Capture Page` | Has capture page |
| Component state | `{Feature} Capture State` | Has capture with complex state |
| Embedded child grid | `{Feature} Embedded List` | Has child entities |
| Route definitions | `{Feature} Routing` | Always |

### From Stage Gate Rules (test/verify gates only)

| Boundary | Expected Gates | Count |
|----------|---------------|-------|
| Per feature backend | test (integration tests) | 1 |
| Per feature frontend | test (UI tests) | 1 |
| Per use case | verify (UC scenario) | 1 |
| Module | verify (module complete) | 1 |

### Expected Bead Count Template

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
| {Feature} | 5 (models, service, list, capture, routing) | Full UI |
| Permissions | 4 (models, service, list, routing) | No capture page |

### Stage Gates

| Level | Count |
|-------|-------|
| Feature ({N}) x 6 | {Nx6} |
| Use Case ({N}) x 2 | {Nx2} |
| Module x 2 | 2 |

### Tests

| Type | Count |
|------|-------|
| Integration tests ({N} features) | {N} |
| UI tests ({N} features) | {N} |

### Total Expected: {sum}
### Total Actual: {bead count from br}
### Delta: {difference}
```

---

## Severity Calibration

**Every finding gets a severity. Calibrate carefully — inflation kills trust.**

For the shared FAIL/WARN severity model, see: `../../_shared/references/review-finding-taxonomy.md`

The calibration below maps the four-level internal severity (CRITICAL, HIGH, MEDIUM, LOW) to concrete bead-review examples. CRITICAL and HIGH map to FAIL; MEDIUM and LOW map to WARN.

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
