---
name: technical-design
description: >
  Bridge from PRD or brainstorm to implementation plan. Produces C4-based
  architecture diagrams, ASCII sequence diagrams, data models, API specs
  with .NET/C# patterns, UI mockups with multiple states, and workflow
  diagrams. Uses diagram selection logic to include only what the feature
  needs. Alternatives Considered is the most important section. Use when
  user says "design the system", "create technical spec", "API design",
  "architecture", or after PRD approval.
argument-hint: "[feature name or PRD reference]"
---

# Technical Design: Requirements → Architecture & Specifications

**Philosophy:** A technical design bridges the "what" (PRD) to the "how" (implementation plan). The value is in the trade-offs and alternatives, not the solution description. If the solution is obvious enough that there are no trade-offs, you probably don't need a design doc. Design once, implement confidently.

## Core Principles

1. **Alternatives-first** — the Alternatives Considered section is the MOST IMPORTANT
2. **C4-based architecture** — progressive zoom: Context → Container → Component
3. **ASCII-native** — all diagrams use conventions from `_shared/references/ascii-conventions.md`
4. **Diagram selection** — include only the diagram types this feature needs
5. **Detail proportional to irreversibility** — deep for APIs and schemas, light for internals
6. **Pattern-consistent** — follow existing codebase patterns, don't invent new ones

---

## Trigger Conditions

Run this skill when:
- After PRD approval (business features)
- After brainstorm (technical improvements)
- User needs architecture, API specs, or data models
- User says "design the API", "what's the architecture", "create technical spec"
- Before /plan for any medium-to-large change

---

## Critical Sequence

### Phase 0: Prerequisites & Diagram Selection

**Step 0.1 — Resolve and Import:**

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
mkdir -p "${PROJECT_ROOT}/docs/designs/{feature}"

# Import upstream artifacts
cat "${PROJECT_ROOT}/docs/prd/{feature}/prd.md" 2>/dev/null
cat "${PROJECT_ROOT}/docs/discovery/{feature}/discovery-brief.md" 2>/dev/null
cat "${PROJECT_ROOT}/docs/brainstorm/{feature}/brainstorm.md" 2>/dev/null
ls "${PROJECT_ROOT}/docs/architecture/" 2>/dev/null
ls "${PROJECT_ROOT}/docs/learnings/" 2>/dev/null
```

**Step 0.2 — Load References:**

Read ASCII conventions: `_shared/references/ascii-conventions.md`
Read .NET patterns: `references/dotnet-patterns.md`
Read domain patterns: `_shared/references/{domain}.md` (from discovery domain classification)

**Step 0.3 — Diagram Selection:**

Evaluate feature characteristics and select which diagrams to generate:

```
ALWAYS GENERATE:
  [x] C4 Level 1 — System Context
  [x] C4 Level 2 — Container Diagram

CONDITIONAL — check each:
  [ ] C4 Level 3 (Component):
      IF feature modifies internal structure of an existing container
  [ ] Sequence Diagrams:
      IF multi-component interaction (2+ services involved)
      → Generate: one per command, one per critical query, one per error recovery
  [ ] Data Model / ER Diagram:
      IF feature adds or changes database entities
  [ ] Class Diagram:
      IF feature introduces new domain model with 5+ classes
  [ ] Data Flow Diagram:
      IF feature moves data across system boundaries
      IF security threat model is needed (STRIDE input)
  [ ] Workflow / Process Map:
      IF feature has business process with decisions or approvals
      IF cross-department or cross-system handoffs
  [ ] Activity Diagram:
      IF feature has parallel processing paths
      IF complex conditional logic with concurrency
  [ ] UI Mockups:
      IF feature has a user interface
      → Generate: populated, empty, error, loading states per screen
  [ ] Deployment Diagram:
      ONLY IF infrastructure changes are required

NEVER GENERATE:
  [ ] C4 Level 4 (Code) — use IDE for this
```

Present checklist to user: "Based on this feature, I plan to generate: {list}. Any additions or removals?"

Initialise `progress.md` with selected diagram types as phases.

---

### Phase 1: System Architecture

**Step 1.1 — C4 Level 1: System Context (ALWAYS)**

ASCII diagram showing the system under design (double border) with external actors and systems.

Use conventions from `ascii-conventions.md`:
- `[Actor Name]` for external actors
- `+====== Name ======+` for system under design (double border)
- `+------ Name ------+` for external systems
- Label every connection with protocol and data description

Rules: 3-7 elements max. One diagram, one story.

**Step 1.2 — C4 Level 2: Container Diagram (ALWAYS for new features)**

ASCII diagram showing major technology pieces within the system.

Each container includes: name, technology choice, port/protocol.
Every connection labelled with: protocol, data format, direction.

**Step 1.3 — C4 Level 3: Component Diagram (IF selected)**

ASCII diagram showing internal components of ONE container.
Only for the container being modified by this feature.

**Step 1.4 — Technology Decisions:**

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|

Output: `architecture.md`

---

### Phase 2: Data Model (IF selected)

**Step 2.1 — Entity-Relationship Diagram:**

ASCII ER diagram using class diagram conventions from `ascii-conventions.md`.
Show ALL new/changed entities with properties, types, constraints, relationships.

```
+------------------+        +------------------+
|  Application     |        |  ApplicationScope|
+------------------+        +------------------+
| + Id: Guid PK    |        | + AppId: Guid FK |
| + TenantId: Guid |  1---* | + ScopeId: Guid FK|
| + Name: string   |--------| + GrantedAt: DT  |
| + ClientId: str  |        +------------------+
| + Type: AppType  |
| + IsActive: bool |
| + CreatedAt: DT  |
+------------------+
| + Suspend()      |
| + Activate()     |
+------------------+
```

**Step 2.2 — Entity Definitions:**

For each entity:
- All properties with types and constraints
- Relationships (navigation properties, foreign keys)
- EF Core notes (indexes, unique constraints, query filters)
- Soft delete strategy if applicable

**Step 2.3 — Migration Strategy:**

- New tables needed
- Columns added to existing tables
- Data migration requirements
- Seed data needs
- **Rollback approach** — how to undo the migration safely

Output: `data-model.md`

---

### Phase 3: API Specification (IF feature has API surface)

Load: `references/dotnet-patterns.md` AND `_shared/references/{domain}.md`

**For each endpoint:**

```
### POST /api/v1/{resource}
Maps to: FR-{MODULE}-001, UC-{MODULE}-001
Auth: [Authorize(Policy = "{PolicyName}")]

Command: Create{Resource}Command
Handler: Create{Resource}CommandHandler

Request:
  { name: string, description: string?, parentId: Guid? }

Validation:
  name: required, max 200 chars, unique within tenant
  description: max 2000 chars

Response (201):
  { id: Guid, name: string, createdAt: DateTime }

Errors:
  400 — validation failure (field-level errors in problem details)
  401 — not authenticated
  403 — missing required policy/permission
  409 — name already exists within tenant
  422 — business rule violation
```

Organise by: Commands (POST, PUT, DELETE) → Queries (GET) → Shared DTOs.

Output: `api-spec.md`

---

### Phase 4: Sequence Diagrams (IF selected)

Generate one ASCII sequence diagram per critical flow. Use conventions from `ascii-conventions.md`.

**Generate for:**
- Each command flow (create, update, delete)
- Primary query flow (list with filtering)
- Primary error recovery flow
- Authentication flow (if auth feature)

Rules:
- 3-5 participants maximum per diagram
- Label messages with actual endpoint/method names
- Show request AND response
- Use ALT blocks for error paths
- Width under 100 characters

Output: `sequences.md`

---

### Phase 5: Workflow / Process Diagrams (IF selected)

ASCII workflow diagrams for business processes with decision points.
Use conventions from `ascii-conventions.md`.

Generate for:
- Business approval workflows
- Cross-system processes (e.g., user provisioning across products)
- Complex multi-step operations

Include swimlanes when multiple actors/systems are involved.

Output: `workflows.md`

---

### Phase 6: Data Flow Diagrams (IF selected)

ASCII DFDs using conventions from `ascii-conventions.md`.

Generate:
- Context diagram (system boundary with external entities)
- Level 0 DFD (major processes within system)

Useful for: security threat modelling (STRIDE input), data lineage, integration documentation.

Output: `data-flows.md`

---

### Phase 7: UI Mockups (IF feature has UI)

ASCII mockups using conventions from `ascii-conventions.md`.

**For each screen** (import screen inventory from discovery `ux-flows.md`):

Generate SEPARATE mockups for:
1. **Populated** — normal operation with realistic data
2. **Empty** — no data yet, include call-to-action
3. **Error** — validation errors, server errors
4. **Loading** — if async operations (optional)

Per mockup:
- Component hierarchy (which components contain which)
- Form fields mapped to API endpoint and DTO
- Validation rules (which are client-side vs. server-side)
- Action buttons mapped to API calls

Output: `ui-mockups.md`

---

### Phase 8: Alternatives Considered

**THIS IS THE MOST IMPORTANT SECTION IN THE DESIGN DOC.**

For every significant design decision (API structure, data model shape, auth approach, caching strategy, framework choice):

```markdown
## Alternatives Considered

### Decision 1: {What's being decided}

**Context:** {Why this decision matters}

| Approach | Description | Pros | Cons |
|----------|-------------|------|------|
| A: {Name} ← CHOSEN | {How it works} | {Benefits} | {Drawbacks} |
| B: {Name} | {How it works} | {Benefits} | {Drawbacks} |
| C: {Name} | {How it works} | {Benefits} | {Drawbacks} |

**Decision:** Approach A because {specific technical reasoning}.
**Trade-off accepted:** {What we're giving up and why it's acceptable}.

### Decision 2: {Next decision}
...
```

**Minimum:** 2-3 alternatives per major decision. If you can't think of alternatives, the decision may not need a design doc.

**Quality check:** This section should be one of the LONGEST sections. If it's shorter than the architecture section, you're not documenting enough trade-offs.

---

### Phase 9: Security & Privacy (IF applicable)

From discovery security analysis, specify technical mitigations:

- Authentication/authorization changes (policies, claims, guards)
- Data classification (which fields are PII, which are sensitive)
- Encryption (at rest: which fields/tables; in transit: TLS configuration)
- Audit logging (which events, retention, tamper protection)
- Rate limiting (which endpoints, per-tenant or global)
- Input validation (injection prevention, parameterised queries)
- CORS and CSP configuration

---

### Phase 10: Testing Strategy

```markdown
## Testing Strategy

### Unit Tests
- {Key business logic to unit test}
- {Complex validation rules}
- {Domain service methods}

### Integration Tests
- API contract tests for each endpoint (request/response shapes, status codes)
- Database integration tests for complex queries
- Auth policy tests (verify correct roles/permissions enforced)

### E2E Tests
- Critical user paths: {list from use cases}
- Cross-system flows: {list from workflows}

### Performance Tests
- Load target: {from NFRs}
- Tool: {k6 / NBomber / etc.}
- Key scenarios: {which endpoints under load}
```

---

### Phase 11: Rollout Plan

```markdown
## Rollout
- Feature flags: {which flags, default state, rollout %]
- Migration: {data migration approach, zero-downtime strategy}
- Rollback: {how to undo — feature flag off, migration down, etc.}
- Monitoring: {key metrics, alerts, dashboards}
```

---

### Phase 12: Work Decomposition Preview

**This section feeds directly into /plan.**

```markdown
## Work Decomposition

### Component Breakdown
| Component | Scope | Complexity | Risk | Implements |
|-----------|-------|------------|------|-----------|
| Data Model | Entities, migrations, EF config | M | Low | FR-001, FR-002 |
| Commands | Create/Update/Delete handlers | L | Medium | FR-001-FR-005 |
| Queries | List/Get handlers | S | Low | FR-006, FR-007 |
| API | Endpoints, auth policies | M | Low | All FRs |
| Validation | FluentValidation rules | S | Low | FR-001-FR-005 |
| UI | Forms, lists, detail views | L | Medium | All FRs |
| Integration | Downstream provisioning | M | High | FR-010 |

### Dependency Graph
  Data Model ──> Commands ──> API ──> UI
      |              |
      +──> Queries ──+
      |
      +──> Integration

### Suggested Execution Order
1. Data Model — everything depends on this
2. Commands + Validation — write path
3. Queries — read path
4. API — expose to clients
5. UI — consume the API
6. Integration — external systems
```

---

### Phase 13: Self-Review & Approval

**2 rounds minimum. Exit on 2 consecutive clean rounds.**

**8 Review Themes:**

1. **Architecture Soundness** — Follows layer structure? Consistent with existing patterns?
2. **API Completeness** — Every FR has an endpoint? DTOs defined? Error codes specific?
3. **Data Model Integrity** — ER matches API needs? Relationships correct? Migrations safe?
4. **Diagram Accuracy** — Sequences match endpoints? Flows match use cases?
5. **Pattern Consistency** — CQRS respected? Validation in right layer? Naming conventions?
6. **Testability** — Every handler unit-testable? Dependencies injectable?
7. **Traceability** — Every endpoint maps to FR? Every FR maps to UC?
8. **ASCII Quality** — Diagrams under 100 chars? Conventions followed? Aligned properly?

---

### Present to User

```markdown
## Technical Design Complete

**Feature:** {name}
**Architecture docs:** {count} files in docs/designs/{feature}/
**Diagrams generated:** {list of diagram types}
**Endpoints defined:** {count}
**Entities defined:** {count}
**Alternatives documented:** {count} decisions with {count} alternatives

Ready for review:
1. "design approved" → Proceed to /plan
2. "refine" → Continue iterating
3. "park" / "abandon"
```

---

## Output Structure

```
${PROJECT_ROOT}/docs/designs/{feature}/
├── design.md            # Overview + alternatives + security + rollout
├── architecture.md      # C4 diagrams
├── data-model.md        # ER diagram + entity definitions + migration
├── api-spec.md          # Endpoints, DTOs, validation, errors
├── sequences.md         # Sequence diagrams (if selected)
├── workflows.md         # Workflow diagrams (if selected)
├── data-flows.md        # DFDs (if selected)
├── ui-mockups.md        # Mockups with multiple states (if selected)
├── findings.md          # Working notes
└── progress.md          # Phase tracking
```

---

## Exit Signals

| Signal | Meaning |
|--------|--------|
| "design approved" | Proceed to /plan |
| "refine" | Continue iterating |
| "park" | Save for later |
| "abandon" | Don't build this |

**On approval:** "Design approved. Run /plan to create implementation plan."

---

## Reference Files

For detailed .NET/C# patterns: `references/dotnet-patterns.md`
For domain-specific patterns: `_shared/references/{domain}.md`
For ASCII diagram conventions: `_shared/references/ascii-conventions.md`

---

*Skill Version: 2.0*
*Added in v2: C4-based architecture, ASCII-native diagrams, diagram selection logic, alternatives emphasis*
