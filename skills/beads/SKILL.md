---
name: beads
description: >
  Convert approved plans into intent-based work packages through structured
  dialogue. Each bead is a self-contained unit an agent can execute independently
  — it carries the objective, context references, acceptance criteria, and
  verification commands needed to produce working code. Beads contain INTENT,
  not implementation. The agent writes code from codebase patterns, not from
  copy-paste snippets. Co-authored with the user, pausing to validate
  decomposition and readiness before finalising. Use when the plan is approved,
  user says "create beads", "beads for...", or plan documents exist.
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
6. **Stage gate cycles** — `/review` + `/simplify` at every semantic boundary

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

## Stage Gates — AskUserQuestion

At every PAUSE point in this skill, **call the `AskUserQuestion` tool** to present structured options to the user. Do not present options as plain markdown text — use the tool. The YAML blocks at each PAUSE point show the exact parameters to pass.

For pattern details and examples: `../_shared/references/stage-gates.md`

> **Fallback:** Only if `AskUserQuestion` is not available as a tool (check your tool list), fall back to presenting options as markdown text and waiting for freeform response.

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
  ── PAUSE 1: "Here's the mapping. Right beads? Right granularity?" ──
Phase 2: Create Beads (epic, tasks, gates, dependencies)
Phase 3: Self-Assessment Gate (per-bead readiness + cross-bead review)
  ── PAUSE 2: "All beads assessed and ready. Approve for /execute?" ──
```

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

**Context management still applies:**
- If a single-pattern bead still has > 4-5 context files → split by sub-concern
- If the pattern artifact is trivially small → may combine per Grouping Exceptions

**Grouping exceptions (MAY combine):**
- Entity + Enum definitions (enums are part of entity definition)
- DTOMapper + DataContext (DataContext is input to DTOMapper)
- Multiple small endpoints for same entity IF each is under ~20 lines (e.g., Get + Lookup can combine)
- Models + Enum Constants (same concern on frontend)
- Capture State + Capture Page IF state is simple (single entity, no lifecycle)

**Never combine:**
- Entity/EF Config with Contracts (different projects)
- EntityMapper with DTOMapper (opposite data flow)
- Commands with Queries (CQRS)
- Endpoints with Commands/Queries (HTTP wiring vs business logic)
- Validators with Endpoints (validation rules vs HTTP lifecycle)
- List Page with Capture Page (different routes)
- Feature Service with any Component (service vs presentation)
- Routing with Components (infrastructure vs feature)
- **Backend with Frontend** (different tech stacks, different review cycles)

---

## Bead Decomposition Tables

The tables below show decomposition for a typical .NET/Angular vertical-slice architecture. **For other tech stacks, adapt the tables to your project's pattern docs.** The principle is the same: one bead per pattern artifact, resolved from the doc map built in Phase 0.

If your project uses different patterns (e.g., Python/FastAPI handlers, Go services, React components), build your decomposition table from your `docs/patterns/` directory — each pattern doc becomes a potential bead type.

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

## Frontend Bead Decomposition (per feature)

Each feature's UI produces these beads:

| # | Bead Title Convention | Pattern Key | What It Produces | Depends On |
|---|----------------------|-------------|------------------|------------|
| 20 | `{Feature} Models + Enums` | `enums`, `feature-service` | TypeScript interfaces, `as const` enum objects | Backend test gate |
| 21 | `{Feature} Feature Service` | `feature-service` | Colocated HTTP service class, Promise-based API | #20 |
| 22 | `{Feature} List Page` | `list-page` | Standalone component, `nxgn-grid-page-title` + `nxgn-data-grid` | #21 |
| 23 | `{Feature} Capture Page` | `capture-page` | Standalone component, `nxgn-capture-page-title` + form fields | #21 |
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
| 27 | `{Feature} Integration Tests` | per discovered test plan | Backend integration tests using Testcontainers Postgres | Backend `/simplify` gate |
| 28 | `{Feature} UI Tests` | per discovered test plan | Vitest unit tests for components and service | Frontend `/simplify` gate |

---

## Stage Gate Beads

When creating beads from a plan, **automatically insert stage gate beads** at semantic boundaries. These are non-implementation beads that the `/execute` skill runs as first-class beads — loading the gate bead, running the specified skill, fixing any issues found, then proceeding.

### The Review Cycle Pattern

Each stage gate is a **two-step cycle**:

1. **`/review` bead** — Multi-perspective adversarial code review. Finds defects: missing error handling, wrong patterns, broken contracts, security gaps, requirement drift. The executing agent fixes all findings before proceeding.
2. **`/simplify` bead** — Code quality and efficiency pass. Finds reuse opportunities, dead code, over-engineering, naming issues, unnecessary complexity. The executing agent fixes all findings before proceeding.

These must be **separate beads** because they have different concerns and produce different fix patterns. `/review` catches correctness; `/simplify` catches quality.

### Stage Gate Placement Rules

Insert gates at three levels:

#### Level 1: Feature Slice Gates (per entity/feature)

After all backend implementation beads for a feature:

```
[backend impl beads] → /review({feature}): backend → /simplify({feature}): backend
  → test({feature}): integration tests
    → [frontend impl beads] → /review({feature}): frontend → /simplify({feature}): frontend
      → test({feature}): UI tests
```

| # | Bead Title Convention | Type | Depends On | Gates |
|---|----------------------|------|------------|-------|
| 1 | `/review({feature}): backend` | review | Last backend impl bead (service registration) | Blocks `/simplify` |
| 2 | `/simplify({feature}): backend` | review | Backend `/review` bead | Blocks test gate |
| 3 | `test({feature}): integration tests` | test | Backend `/simplify` bead | **Blocks ALL frontend beads** |
| 4 | `/review({feature}): frontend` | review | Last frontend impl bead (routing) | Blocks `/simplify` |
| 5 | `/simplify({feature}): frontend` | review | Frontend `/review` bead | Blocks test gate |
| 6 | `test({feature}): UI tests` | test | Frontend `/simplify` bead | Blocks UC gate |

**Critical rule:** Frontend beads MUST depend on the backend test gate (#3), never on raw backend implementation beads. This ensures backend code is reviewed, simplified, and passing tests before frontend work begins.

#### Level 2: Use Case Gates (per use case)

After all feature slices contributing to a use case are tested:

```
test(A): UI tests + test(B): UI tests → /review({module}): UC-{ID} → /simplify({module}): UC-{ID}
```

| # | Bead Title Convention | Type | Depends On | Purpose |
|---|----------------------|------|------------|---------|
| 7 | `/review({module}): UC-{ID}` | review | All feature test gates for this UC | End-to-end correctness across features |
| 8 | `/simplify({module}): UC-{ID}` | review | UC `/review` bead | Cross-feature deduplication and quality |

#### Level 3: Module Epic Gates

After all use case gates pass:

```
/simplify: UC-001 + /simplify: UC-002 → /review({module}): module complete → /simplify({module}): module complete
```

| # | Bead Title Convention | Type | Depends On | Purpose |
|---|----------------------|------|------------|---------|
| 9 | `/review({module}): module complete` | review | All UC `/simplify` gates | Final cross-feature consistency, DI, routing |
| 10 | `/simplify({module}): module complete` | review | Module `/review` bead | Final quality pass. **Last bead in the epic.** |

### Dependency Flow Visualization

For a module with features A and B, use case UC-001 spanning both:

```
Feature A:
  bd-a1 (entity) → bd-a2 (EF) → bd-a3 (contracts) → bd-a4 (mappers)
    → bd-a5 (commands) → bd-a6 (queries) → bd-a7 (endpoints)
    → bd-a8 (validators) → bd-a9 (registration)
      → /review(A): backend → /simplify(A): backend → test(A): integration tests
        → bd-a10 (models) → bd-a11 (service) → bd-a12 (list page)
        → bd-a13 (capture) → bd-a14 (routing)
          → /review(A): frontend → /simplify(A): frontend → test(A): UI tests

Feature B:
  bd-b1 → ... → bd-b9
    → /review(B): backend → /simplify(B): backend → test(B): integration tests
      → bd-b10 → ... → bd-b14
        → /review(B): frontend → /simplify(B): frontend → test(B): UI tests

UC + Module:
  test(A): UI tests + test(B): UI tests
    → /review(module): UC-001 → /simplify(module): UC-001
      → /review(module): module complete → /simplify(module): module complete [EPIC CLOSES]
```

### Trust Hierarchy

When gate beads find issues, the fix priority follows this hierarchy (highest trust → lowest):

1. **ADRs & Patterns** — architectural intent, non-negotiable
2. **PRD** — business requirements
3. **Design docs** (api-surface, data-model, ui-mockup) — technical specification
4. **Plans & Sub-plans** — implementation breakdown
5. **Beads** — must conform to everything above
6. **Implementation code** — must conform to the bead's intent

If `/review` finds code that contradicts a pattern or ADR, the **code is wrong**. If a bead contradicts the design, the **bead is wrong**. Gate beads enforce this hierarchy at every boundary.

---

## Critical Sequence

### Phase 0: Discover Project Documentation

Before creating beads, discover what documentation actually exists in the project. Projects vary — patterns may be flat or nested, decisions may live in `docs/adr/` or inside `docs/designs/{feature}/decisions/`, architecture docs may exist as a separate folder or be embedded in pattern docs. This phase builds a **doc map** that all subsequent phases reference.

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
| docs/reference/ | {N} | capstone-patterns.md, ... |
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

**Step 0.4 — Present doc map summary:**

Show the user what was discovered before proceeding to decomposition:

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
IF > 90% "Exists": Verification Mode — create verification/modify beads only
IF > 70% "Exists": Gap-driven — create beads only for "New" and "Modify" elements
IF < 30% "Exists": Greenfield — use standard pattern decomposition
ELSE: Hybrid — mix of greenfield beads for "New" and modify beads for "Modify"
```

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

**Gap-driven path (>70% exists):** For each design element in the plan's Design Coverage Matrix:
- **Status = "Exists" (no changes):** Skip — no bead needed
- **Status = "Modify":** Create ONE focused modification bead. The bead title should be "Modify {Element}" not "Add {Element}". Include in the bead description WHAT needs to change (from Implementation Status notes).
- **Status = "New":** Create standard pattern beads per the decomposition tables

**Verification Mode (>90% exists):** Create verification beads that check existing code against design, plus targeted modification beads for the few gaps. Feature gates focus on "verify existing flows still work after changes."

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
- One backend integration test bead per feature (depends on backend `/simplify` gate)
- One frontend UI test bead per feature (depends on frontend `/simplify` gate)
- For gap-driven: test beads verify BOTH new code AND that existing flows still work

**Step 1.2e — Apply grouping exceptions:**
Review the bead list for trivially small beads that can be combined per the Grouping Exceptions list in the Bead Size Heuristic section. Only combine when BOTH beads would be under ~20 lines of implementation.

**Step 1.2f — Auto-detect gate scale:**
```
IF total implementation beads ≤ 5 AND plan tasks ≤ 3:
  → BRIEF gates only (backend review + simplify, no UC/module gates)
ELSE:
  → Standard gate structure per Step 1.3
```

**Step 1.3 — Insert Stage Gate Beads:**

After creating all implementation and test beads, insert stage gate beads:

1. **Identify feature slices** — group implementation beads by feature/entity
2. **Identify the last backend bead** per feature (usually service registration)
3. **Identify the last frontend bead** per feature (usually routing)
4. **Create feature slice gates** (6 per feature: 2× `/review`, 2× `/simplify`, 2× test):
   - `/review({feature}): backend` — depends on last backend impl bead
   - `/simplify({feature}): backend` — depends on backend `/review` bead
   - `test({feature}): integration tests` — depends on backend `/simplify` bead
   - `/review({feature}): frontend` — depends on last frontend impl bead
   - `/simplify({feature}): frontend` — depends on frontend `/review` bead
   - `test({feature}): UI tests` — depends on frontend `/simplify` bead
5. **Create UC gate beads** (2 per use case: `/review` + `/simplify`):
   - Depend on all contributing feature test gates
6. **Create module gate beads** (2: `/review` + `/simplify`):
   - Depend on all UC gates
   - Module `/simplify` gate is the epic's final dependency

**Wire dependencies:**
- Gate beads depend on the last impl bead of their phase
- Frontend impl beads depend on the backend test gate (NOT on backend impl beads)
- UC gates depend on all contributing feature test gates
- Module gates depend on all UC gates
- Epic depends on the module `/simplify` gate (making it the last bead)

**Step 1.4 — Map Dependencies:**

Import dependencies from the plan's dependency graph. Beads inherit the ordering from the plan — don't re-derive it.

Within each feature's decomposed beads, wire internal dependencies following the decomposition tables:
- entity → EF config → contracts → mappers → commands/queries → endpoints → validators → registration

Review beads depend on the last implementation bead in their group and block the next group's first implementation bead. This creates natural quality gates in the dependency chain.

**Step 1.5 — Identify Parallel Tracks:**

Mark beads that can execute in parallel (no dependency between them). This helps the executing agent (or user) optimise throughput.

```markdown
### Parallel Tracks
- Track A: bd-002 → bd-005 (user-facing flow)
- Track B: bd-003 → bd-006 (admin flow)
- Tracks merge at: bd-007 (integration)
```

**PAUSE 1:** Present the task-to-bead mapping for batch review.

**Step 1:** Present the full mapping as formatted markdown:

```markdown
## Task-to-Bead Mapping

**Feature:** {name}
**Beads:** {N} implementation + {G} gates = {total} across {M} phases | {P} can run in parallel

| Plan Task | Bead | Phase | Pattern Doc | Labels | Parallel Track |
|-----------|------|-------|-------------|--------|----------------|
| T01: {task title} | bd-{id}: {Entity} Entity + Enums | 0: Foundation | api/entity.md | model | A |
| T01: {task title} | bd-{id}: {Entity} EF Configuration | 0: Foundation | api/ef-configuration.md | config | A |
| T01: {task title} | bd-{id}: {Entity} Contracts | 0: Foundation | api/requests.md | contract | A |
| — | bd-{id}: /review({feature}): backend | gate | — | review | — |
| — | bd-{id}: /simplify({feature}): backend | gate | — | review | — |
| — | bd-{id}: test({feature}): integration tests | gate | — | test | — |
| T02: {task title} | bd-{id}: {Feature} Models + Enums | 1: Frontend | web/feature-service.md | ui | B |

### Stage Gates

| Level | Gates | Count |
|-------|-------|-------|
| Feature slice | {N} features × 6 gates | {N×6} |
| Use case | {N} UCs × 2 gates | {N×2} |
| Module | 1 × 2 gates | 2 |
| **Total gate beads** | | {total} |
```

**Step 2:** Use AskUserQuestion with multi-select to review beads in batches (max 4 per batch):

```
AskUserQuestion:
  question: "Which beads need granularity adjustment? (Unselected beads are approved)"
  header: "Bead mapping"
  multiSelect: true
  options:
    - label: "bd-{id}: {bead title}"
      description: "Plan task T01 → Phase 0: Foundation, pattern: api/entity.md"
    - label: "bd-{id}: {bead title}"
      description: "Plan task T01 → Phase 0: Foundation, pattern: api/ef-configuration.md"
    - label: "bd-{id}: {bead title}"
      description: "Plan task T01 → Phase 0: Foundation, pattern: api/requests.md"
    - label: "bd-{id}: {bead title}"
      description: "Plan task T02 → Phase 1: Frontend, pattern: web/feature-service.md"
```

Repeat for additional batches if more than 4 beads. For flagged beads, collect revision notes and adjust granularity.

**Step 3:** After all batches reviewed, use AskUserQuestion decision gate:

```
AskUserQuestion:
  question: "Is the overall bead mapping correct?"
  header: "Mapping"
  multiSelect: false
  options:
    - label: "Accept (Recommended)"
      description: "Mapping is correct. Proceed to create beads."
    - label: "Adjust mapping"
      description: "Minor changes needed to specific bead granularity or grouping."
    - label: "Escalate"
      description: "Mapping reveals plan needs revision. Return to /plan."
```

---

### Phase 2: Create Beads

This phase creates work packages in the project's issue tracker. The examples below use `br` (beads-rust); adapt commands to your issue tracker as configured in your CLAUDE.md.

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
- **First bead in module?** Also load: `docs/designs/{module}/design.md`, `docs/designs/{module}/data-model.md`, `docs/prd/{module}/prd.md`

## Approach
{Brief guidance on HOW to approach the work — not implementation code.
Reference design decisions and pattern docs.}

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
review({feature}): fix /review findings for backend
refactor({feature}): apply /simplify improvements to backend
review({feature}): fix /review findings for frontend
refactor({feature}): apply /simplify improvements to frontend
```

**Step 2.3 — Create Stage Gate Beads:**

For each gate identified in Step 1.3, create a gate bead. Gate beads follow the same format as implementation beads but with skill-specific content.

**`/review` gate bead format:**

```markdown
## Objective
Run `/review` on all backend code for the {feature} feature slice. Fix all Critical and High findings before proceeding.

## Depends On
- bd-{id}: {last backend/frontend impl bead — e.g., service registration}

## In Scope
- All files changed by implementation beads since last checkpoint
- Correctness: missing error handling, wrong patterns, broken contracts
- Security: injection, auth bypass, data exposure
- Design conformance: does implementation match api-surface.md and data-model.md

## Out of Scope
- New feature work (that's the next implementation bead)
- Architecture changes (escalate to /plan if needed)

## Success Criteria
- `/review` produces 0 Critical and 0 High findings (or all are fixed)
- `dotnet build` succeeds after fixes
- `dotnet test --filter "{Feature}"` passes after fixes

## Failure Criteria
- ❌ Do NOT skip findings rated Critical or High
- ❌ Do NOT defer fixes to a later bead — fix them in this gate
- ❌ Do NOT modify code outside this feature's scope to fix findings

## Context to Load
- **Review scope:** `Features/{Feature}/` — all files in this feature directory
- **Pattern docs:** {resolved from doc map pattern keys used by this feature's beads}
- **Design docs:** {resolved from `design.api-surface`, `design.data-model` in the doc map}
- **Decisions:** {resolved from `decisions[]` in the doc map — include all feature-scoped and project-scoped decisions}
- **Architecture:** {resolved from `architecture[]` in the doc map, if any}

## Approach
1. Run `/review` scoped to the feature directory
2. For each Critical/High finding: fix the code, re-run affected tests
3. Re-run `/review` to verify findings are resolved
4. Proceed only when clean

## Verification
- **Command:** `dotnet build && dotnet test --filter "{Feature}"`
- **Commit:** `review({feature}): fix /review findings for backend`
```

**`/simplify` gate bead format:**

```markdown
## Objective
Run `/simplify` on all backend code for the {feature} feature slice. Fix reuse, quality, and efficiency issues.

## Depends On
- bd-{id}: {/review gate bead for this phase}

## In Scope
- Code quality: duplication, naming, abstraction opportunities
- Pattern consistency with established codebase conventions
- Dead code, unnecessary complexity, over-engineering
- Reuse opportunities across features

## Out of Scope
- New feature work
- Architecture changes

## Success Criteria
- `/simplify` findings applied or justified
- `dotnet build` succeeds after changes
- `dotnet test --filter "{Feature}"` passes after changes

## Failure Criteria
- ❌ Do NOT introduce new abstractions not warranted by actual duplication
- ❌ Do NOT modify code outside this feature's scope

## Context to Load
- **Review scope:** `Features/{Feature}/` — all files in this feature directory
- **Pattern docs:** {resolved from doc map pattern keys used by this feature's beads}
- **Learnings:** {resolved from `learnings[]` in the doc map — check for relevant past gotchas}

## Verification
- **Command:** `dotnet build && dotnet test --filter "{Feature}"`
- **Commit:** `refactor({feature}): apply /simplify improvements to backend`
```

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

**Module gate beads** review the entire module for cross-feature consistency — include reference docs from `reference[]` in the doc map for cross-project alignment.

Label all gate beads with `review` or `test` tag to distinguish them from implementation beads.

**Step 2.4 — Apply Labels:**

Categorise each bead by concern area (e.g., model, service, api, ui, test, integration, config, review, gate). Labels help with parallel track identification and progress reporting.

**Step 2.5 — Set Dependencies:**

Register dependencies between beads as specified in the plan's dependency graph plus the internal pattern dependencies. Verify:
- No circular dependencies
- The dependency tree reflects the plan's ordering plus pattern-internal ordering
- First bead(s) have no blockers and are ready to execute
- Frontend impl beads depend on backend test gate (NOT on backend impl beads)
- Gate beads correctly chain: `/review` → `/simplify` → test
- UC gates depend on all contributing feature test gates
- Module gates depend on all UC gates

**Stage gate dependency rules:**
- `/review` bead depends on last impl bead of phase
- `/simplify` bead depends on `/review` bead
- Test gate depends on `/simplify` bead
- Frontend impl beads depend on backend test gate (NEVER on backend impl beads directly)
- UC gates depend on all contributing feature test gates
- Module gates depend on all UC gates
- Epic depends on module `/simplify` gate

---

### Phase 3: Self-Assessment Gate

Every bead must pass a readiness check before presenting to the user. This catches missing context, ambiguous objectives, and oversized beads before they cause problems during execution.

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

**Stage Gate Completeness:**
- [ ] Every feature slice has `/review` + `/simplify` + test gates for both backend and frontend?
- [ ] Frontend beads never depend directly on backend impl beads?
- [ ] Every use case has a completion cycle (`/review` + `/simplify`)?
- [ ] Module epic ends with `/review` + `/simplify` as final beads?
- [ ] No more than 4-5 implementation beads between any two gates?
- [ ] Gate beads specify clear scope and file paths to review?
- [ ] Gate beads have executable verification commands?

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

**Step 4 — FR Coverage Check:**

```markdown
### FR Coverage
| FR | Bead(s) | Status |
|----|---------|--------|
| FR-{MODULE}-{NAME} (Must) | bd-{id} | Covered |
| FR-{MODULE}-{NAME} (Must) | bd-{id}, bd-{id} | Covered |
| FR-{MODULE}-{NAME} (Should) | — | Deferred |
```

All Must-Have FRs must be covered. Flag any gaps as blocking. If the project uses an issue tracker, offer to create tracked items for gaps.

**PAUSE 2:** Guided review of the full bead set.

**Step 1:** Present Beads Created table as formatted markdown:

```markdown
## Beads Created

**Feature:** {name}
**Epic:** {epic-id}
**Beads:** {N} implementation + {G} gates + {T} tests = {total} work packages
**Parallel tracks:** {P} beads can run in parallel

| # | Title | Phase | Pattern Doc | Labels | Status |
|---|-------|-------|-------------|--------|--------|
| bd-{id} | {Entity} Entity + Enums | 0: Foundation | api/entity.md | model | Ready |
| bd-{id} | {Entity} EF Configuration | 0: Foundation | api/ef-configuration.md | config | Ready |
| bd-{id} | {Entity} Contracts | 0: Foundation | api/requests.md | contract | Ready |
| bd-{id} | {Entity} EntityMapper | 1: Core | api/entity-mapper.md | mapper | Ready |
| bd-{id} | {Entity} DTOMapper | 1: Core | api/dto-mapper.md | mapper | Ready |
| bd-{id} | {Entity} SaveCommand | 1: Core | api/commands.md | command | Ready |
| bd-{id} | {Entity} GetQuery | 1: Core | api/queries.md | query | Ready |
| bd-{id} | {Entity} Save Endpoint | 2: API | api/endpoints.md | endpoint | Ready |
| bd-{id} | {Entity} Get Endpoint | 2: API | api/endpoints.md | endpoint | Ready |
| bd-{id} | {Entity} Service Registration | 2: API | api/service-registration.md | config | Ready |
| bd-{id} | /review({feature}): backend | gate | — | review | Ready |
| bd-{id} | /simplify({feature}): backend | gate | — | review | Ready |
| bd-{id} | test({feature}): integration tests | gate | — | test | Ready |
| bd-{id} | {Feature} Models + Enums | 3: Frontend | web/feature-service.md | ui | Ready |
| bd-{id} | {Feature} Feature Service | 3: Frontend | web/feature-service.md | ui | Ready |
| bd-{id} | {Feature} List Page | 3: Frontend | web/list-page.md | ui | Ready |
| bd-{id} | {Feature} Capture Page | 3: Frontend | web/capture-page.md | ui | Ready |
| bd-{id} | {Feature} Routing | 3: Frontend | web/routing.md | ui | Ready |
| bd-{id} | /review({feature}): frontend | gate | — | review | Ready |
| bd-{id} | /simplify({feature}): frontend | gate | — | review | Ready |
| bd-{id} | test({feature}): UI tests | gate | — | test | Ready |
| bd-{id} | /review({module}): UC-{ID} | gate | — | review | Ready |
| bd-{id} | /simplify({module}): UC-{ID} | gate | — | review | Ready |
| bd-{id} | /review({module}): module complete | gate | — | review | Ready |
| bd-{id} | /simplify({module}): module complete | gate | — | review | Ready |

### Stage Gates

| Level | Gates | Count |
|-------|-------|-------|
| Feature slice | {N} features × 6 gates | {N×6} |
| Use case | {N} UCs × 2 gates | {N×2} |
| Module | 1 × 2 gates | 2 |
| **Total gate beads** | | {total} |

### Dependency Tree
{Visual hierarchy of bead dependencies including gate beads}

### Parallel Tracks
{From Step 1.5}
```

**Step 2:** Present Self-Assessment Summary and Resolutions Applied:

```markdown
### Self-Assessment Summary
| Category | Count |
|----------|-------|
| Ready | {N} |
| Resolved | {N} (details below) |
| Split | {N} into {M} sub-beads |

### Resolutions Applied
**bd-{id}:** {What was resolved and how}
**bd-{id}:** {Split into bd-{id}a, bd-{id}b — reason}
```

**Step 3:** Present FR Coverage table:

```markdown
### FR Coverage
| FR | Bead(s) | Status |
|----|---------|--------|
| FR-{MODULE}-{NAME} (Must) | bd-{id} | Covered |
| FR-{MODULE}-{NAME} (Must) | bd-{id}, bd-{id} | Covered |
| FR-{MODULE}-{NAME} (Should) | — | Deferred |
```

**Step 4:** Use AskUserQuestion decision gate:

```
AskUserQuestion:
  question: "All beads assessed as Ready. Approve for /execute?"
  header: "Beads"
  multiSelect: false
  options:
    - label: "Beads approved (Recommended)"
      description: "All beads are ready. Proceed to /execute."
    - label: "Adjust specific bead"
      description: "Modify a specific bead — I'll specify which one."
    - label: "Reassess"
      description: "Re-run the self-assessment gate on all beads."
    - label: "Back to plan"
      description: "Plan needs revision before beads can proceed."
```

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

### Good Gate Bead

```markdown
## Objective
Run `/review` on all backend code for the Roles feature slice.
Fix all Critical and High findings before proceeding.

## Depends On
- bd-017: Role Service Registration

## In Scope
- All files in Features/Roles/ changed by beads bd-001 through bd-017
- Correctness, security, and design conformance review

## Out of Scope
- Frontend code (separate gate after frontend beads)
- Architecture changes (escalate to /plan)

## Success Criteria
- `/review` produces 0 Critical and 0 High findings (or all are fixed)
- `dotnet build` succeeds after fixes
- `dotnet test --filter "Role"` passes after fixes

## Failure Criteria
- ❌ Do NOT skip findings rated Critical or High
- ❌ Do NOT defer fixes to a later bead
- ❌ Do NOT modify code outside Roles scope

## Context to Load
- **Review scope:** `Features/Roles/` — all files in this feature directory
- **Pattern docs:** {resolved from doc map — all pattern keys used by Roles beads}
- **Design docs:** {resolved `api-surface` from doc map}
- **Decisions:** {resolved from `decisions[]` — all Roles-scoped and project-scoped decisions}

## Verification
- **Command:** `dotnet build && dotnet test --filter "Role"`
- **Commit:** `review(roles): fix /review findings for backend`
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
> Task 3: Implement Role CRUD — Save, Get, Grid, Delete endpoints with full Capstone pattern alignment

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
  → /review(roles): backend
  → /simplify(roles): backend
  → test(roles): integration tests
bd-018: Roles Models + Enums
bd-019: Roles Feature Service
bd-020: Roles List Page
bd-021: Roles Capture Page
bd-022: Roles Routing
  → /review(roles): frontend
  → /simplify(roles): frontend
  → test(roles): UI tests
```

**17 backend + 5 frontend + 6 gates + 2 tests = 30 beads** for one feature. Each bead is a focused, single-pattern, single-commit unit of work.

---

## Bead Count Comparison

For a typical module with 3 entities, 3 UI features, and 2 use cases:

**Before (coarse task-level beads):**
- ~10 coarse task-level beads + ~3 review beads = ~13 total
- Each bead bundles 3-5 pattern artifacts
- Agent must hold multiple concerns in context
- One failing concern blocks the entire bead

**After (pattern-granular + stage gates):**
- ~45 pattern-aligned impl beads (15 backend × 3 entities + 5 frontend × 3 features + 6 tests)
- ~18 feature gates (6 per feature × 3 features)
- ~4 UC gates (2 per UC × 2 UCs)
- ~2 module gates
- **Total: ~69 beads**

**Why more beads is better:**
1. Each bead is faster to execute — smaller context, single concern, clear pattern reference
2. Each bead is independently verifiable — one commit, one test scope, one review target
3. Parallelism — independent beads (e.g., EntityMapper and DTOMapper) can execute concurrently
4. Defects caught early — gate beads at feature boundaries, not after the entire module
5. Frontend never builds on broken backend — test gates enforce verification before UI work
6. Git history is useful — each commit is one pattern artifact, easy to revert or cherry-pick
7. Eliminates the "fix everything at the end" anti-pattern — quality is continuous, not deferred
8. Gate beads are fast — `/review` and `/simplify` on a single feature take minutes, not hours

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

**Skipped Gates** — Not inserting stage gate beads or allowing frontend beads to depend directly on backend implementation beads. This lets unreviewed code propagate downstream and defers defect discovery to the end of the module.

---

## BRIEF Mode

For BRIEF scope (3-6 tasks from a BRIEF plan), create beads directly from the overview's inline task descriptions. No sub-plans to import — the overview IS the plan.

The bead format is identical. The only difference is that you extract objectives and criteria from the overview's inline task descriptions rather than from separate sub-plan files.

For BRIEF scope, stage gates are simplified:
- One `/review` + `/simplify` cycle after all backend beads
- One `/review` + `/simplify` cycle after all frontend beads (if applicable)
- Skip UC and module gates (there's typically only one use case in BRIEF scope)

---

## Output Structure

Beads live in the project's issue tracker (e.g., `br` database), not as files. The output of this skill is:
- An epic linking all beads
- Individual implementation beads with full descriptions and pattern references
- Stage gate beads at feature, UC, and module boundaries
- Test beads after each `/simplify` gate
- Dependencies set between all beads (implementation → gates → next phase)
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

*Skill Version: 5.0*
*v5.0: Plan integration — reads plan's FR/UC/Design Coverage tables and Implementation Status (gap analysis) BEFORE decomposition. Non-greenfield mode: >70% exists → gap-driven beads (Modify/New only, skip Exists). >90% exists → Verification Mode beads. Failure criteria propagated from plan's design decisions (not generic). UC gate beads verify scenario flows (not just code quality) with scenario steps from plan's UC Coverage table. Portability: decomposition tables are examples for .NET/Angular, adapt to your project's patterns. Auto-detect BRIEF gates for ≤5 beads / ≤3 tasks. First-bead module spec loading guidance. From adversarial review of beads + review-beads.*
*v4.0: Phase 0 doc discovery — scans project docs tree to build a doc map instead of assuming hardcoded paths. Handles variance in project structure: flat vs nested patterns, decisions in adr/ or designs/{feature}/decisions/, numbered design prefixes, subfeature nesting. Decomposition tables use pattern keys resolved from the doc map. Gate beads load discovered decisions, architecture docs, and learnings into context. Pattern-granular decomposition — one bead per pattern artifact with Backend/Frontend/Test decomposition tables. Stage gate beads — `/review` + `/simplify` cycles at feature slice, use case, and module boundaries. Frontend beads depend on backend test gates, never on raw backend impl beads. Trust hierarchy for gate findings. Bead description format includes Pattern and Commit fields. Bead size heuristic rewritten around pattern alignment with grouping exceptions and never-combine rules. Bead count comparison showing impact.*
*v3.5: Prerequisites expanded with design docs. Parallel Tracks cross-ref corrected (Step 1.5). Good Bead example references design doc instead of plan. PAUSE step labels scoped to avoid collision.*
*v3.4: AskUserQuestion stage gates — PAUSE 1 uses batch review (Pattern 3) for bead mapping with multi-select granularity adjustment. PAUSE 2 uses guided review workflow (Pattern 5) walking through beads created, self-assessment, and FR coverage before a decision gate. Fallback to prose-based patterns when AskUserQuestion is unavailable.*
*v3.2: Review beads — /simplify code review work packages inserted at logical boundaries (phase transitions, feature slices, after high-risk work). Review beads sit in the dependency chain between implementation groups, gating progression until code quality is verified. Placement rules by scope tier. Review bead template with focus guidance. Cross-bead assessment validates review bead coverage.*
*v3.1: Duration targets, scope growth check (kill criteria), prose-based artifact import (no hardcoded shell), merged PAUSE 2+3 into single approval, integrated self-review themes into self-assessment gate, issue tracker commands framed as examples (tool-agnostic), structured PAUSE response options, execution uncertainty reframed as quality signal, language-neutral examples, anti-patterns explain WHY*
