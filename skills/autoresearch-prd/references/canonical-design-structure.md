# Canonical Technical Design Structure (STANDARD / COMPREHENSIVE)

This is the definitive structural specification for technical designs produced
by the /technical-design skill. Derived from: /technical-design SKILL.md v3.5,
/review-design SKILL.md v1.0, designs README.md, and structural audit of 15
ground truth designs in ~/nxgn.identity/main/docs/designs/.

---

## File Structure

Every design lives in `docs/designs/{module}/` and produces these files:

### Always Present (all modes)

| File | Purpose | Source Phase |
|------|---------|-------------|
| `design.md` | Master design: constraints, assumptions, decisions, domain model, security, ops, decomposition | Phases 1-3, 6-8 |
| `README.md` | Entry point with links to all artifacts (if 5+ files) | Phase 9 |

### STANDARD+ Additions

| File | Purpose | Source Phase |
|------|---------|-------------|
| `architecture.md` | C4 diagrams (Level 1 System Context, Level 2 Container, optionally Level 3 Component) | Phase 3 |
| `data-model.md` | ER diagram, entity definitions, migration strategy | Phase 3 |
| `glossary.md` | Domain term disambiguation (inherited from discovery or created) | Phase 0 |
| `diagrams/sequences.md` | Sequence diagrams for critical flows | Phase 5 |
| `decisions/{slug}.md` | Feature-scoped decision records | Phase 2 |

### Per-Feature Documents (STANDARD+, per feature area)

For 1-2 feature areas: flat files at module root.
For 3+ feature areas: `features/{sub-feature}/` subdirectories.

| File | Purpose | Source Phase |
|------|---------|-------------|
| `api-surface.md` | Endpoints, response codes, contracts, validation, backend flow, queries | Phase 4.2 |
| `ui-mockup.md` | ASCII mockups (populated/empty/error states), component hierarchy | Phase 4.3 |
| `test-plan.md` | 25-35 test cases per feature area, mapped to UC/FR | Phase 4.4 |
| `backend.md` | Separate backend doc (optional, when 5+ commands/queries) | Phase 4.2 |

---

## design.md — Master Design Document

### Mandatory H2 Sections (in order)

```
## Documentation Foundation
## Constraints
## Assumptions
## Key Decisions
## Domain Model
## Security & Privacy
## Operational Design
## Work Decomposition
## Self-Review Log
```

### Optional H2 Sections (add when relevant)

```
## Context                          — narrative framing (before Constraints)
## Prior Decisions & Established Patterns  — ADR/pattern constraints (before Key Decisions)
## System Protection Rules          — immutability, core entity guards (after Domain Model)
## API Surface Summary              — endpoint table in design.md (after Domain Model, when not decomposed)
## Scope Exclusions                 — explicitly out of scope items (after Work Decomposition)
## Cross-Cutting FR Coverage        — mapping to cross-cutting PRD requirements (after Work Decomposition)
## Open Questions                   — unresolved items (after Work Decomposition)
```

---

### Section Formats

#### Documentation Foundation

```markdown
## Documentation Foundation

### Upstream Artifacts

| Artifact | Location |
|----------|----------|
| PRD | [docs/prd/{module}/prd.md](../../prd/{module}/prd.md) |
| Use Cases | [docs/prd/{module}/use-cases/](../../prd/{module}/use-cases/) |
| Brainstorm | [docs/brainstorm/{module}/brainstorm.md](../../brainstorm/{module}/brainstorm.md) |

### Sibling Designs

| Design | Relationship to This Module |
|--------|----------------------------|
| [{sibling}](../{sibling}/README.md) | {how it relates} |

### Learnings Applied

| Learning | Source | How Applied |
|----------|-------|-------------|
| {pattern or decision from prior work} | {session/file ref} | {how it shaped this design} |
```

#### Constraints

```markdown
## Constraints

### Technical Constraints
- {TC-1:} {constraint from tech stack, NFRs, infrastructure}
- {TC-2:} {constraint}

### Organisational Constraints
- {OC-1:} {team, timeline, budget, compliance}
- {OC-2:} {constraint}
```

#### Assumptions

```markdown
## Assumptions

| # | Assumption | Impact if Wrong | How to Validate |
|---|-----------|----------------|-----------------|
| 1 | {assumption} | {consequence} | {validation approach} |
| 2 | {assumption} | {consequence} | {validation approach} |
```

Always a table with 4 columns: #, Assumption, Impact if Wrong, How to Validate.

#### Key Decisions

```markdown
## Key Decisions

### Decision 1: {What's being decided}

**Context:** {Why this decision matters. What constraints apply.}

| Approach | Description | Pros | Cons |
|----------|-------------|------|------|
| A: {Name} | {How it works} | {Benefits} | {Drawbacks} |
| B: {Name} | {How it works} | {Benefits} | {Drawbacks} |

**Recommendation:** Approach {X} because {reasoning tied to constraints}.
**Trade-off accepted:** {What we're giving up and why}.
```

Minimum 2-3 genuine alternatives per major decision. No straw-man options.

#### Domain Model

```markdown
## Domain Model

{Brief narrative — aggregate boundary, entity relationships, key design principles.}

Full data model: [data-model.md](data-model.md)
Architecture diagrams: [architecture.md](architecture.md)
```

#### Security & Privacy

```markdown
## Security & Privacy

### Authentication & Authorization
- {policies, claims, guards per endpoint}

### Data Classification
- {PII fields, sensitive fields}

### Audit Logging
- {which events, event type convention, retention}

### Input Validation
- {injection prevention, parameterised queries}
```

#### Operational Design

```markdown
## Operational Design

### Deployment Strategy
- {deployment approach, migration sequence, rollback plan}

### Failure Modes
| Component | Failure Mode | Impact | Mitigation |
|-----------|-------------|--------|------------|
| {component} | {what can go wrong} | {blast radius} | {mitigation} |

### Observability
- **Metrics:** {key metrics}
- **Logging:** {structured logging fields, log levels}
- **Alerting:** {alert conditions}
- **Dashboards:** {what's visible at a glance}
```

#### Work Decomposition

```markdown
## Work Decomposition

### Component Breakdown
| Component | Scope | Complexity | Risk | Implements |
|-----------|-------|------------|------|-----------|
| {component} | {what it covers} | S/M/L/XL | Low/Med/High | FR-{IDs} |

### Dependency Graph
  Component A ──> Component B ──> Component C
       |                            |
       +──> Component D         Component E

### Suggested Execution Order
1. {First — why first}
2. {Second — depends on first}
3. {Third — reason}
```

Component Breakdown table must include: Component, Scope, Complexity, Risk, Implements (FR mapping).
Dependency Graph uses ASCII `──>` arrows.
Execution Order is numbered with rationale.

#### Self-Review Log

```markdown
## Self-Review Log

### Round 1
- {issue found and fixed}
- {issue found and fixed}

### Round 2
- {issue found and fixed}
```

Minimum 2 self-review rounds for STANDARD, 3 for COMPREHENSIVE.

---

## architecture.md

### Required Sections

```
## C4 Level 1: System Context
## C4 Level 2: Container Diagram
## C4 Level 3: Component Diagram    (if feature modifies internal structure)
```

C4 Level 1: 3-7 elements max, labelled connections with protocol.
C4 Level 2: technology choices noted, ports/protocols on connections.
All diagrams use ASCII conventions.

---

## data-model.md

### Required Sections

```
## Entity-Relationship Diagram      (ASCII ER diagram)
## Entity Definitions               (per entity: properties, types, constraints, relationships)
## Migration Strategy               (new tables, added columns, seed data, rollback)
```

Entity definitions include: all properties with types, relationships, ORM notes (indexes, unique constraints), RLS notes for tenant-scoped entities, soft delete strategy.

---

## Per-Feature: api-surface.md

### Required Sections

```
## Endpoints                        (verb, route, purpose table)
## Response Codes                   (per operation: success code, body)
## Error Responses                  (scenario, code, detail, UC source)
## Contracts                        (DTO definitions, writable vs read-only)
## Validation Rules                 (sync vs DB-lookup, BR-* references)
## Backend                          (directory structure, command flow, mapper logic, queries)
```

Optional:
```
## Protection Rules                 (action/condition matrix)
```

Endpoints table: `| Verb | Route | Purpose |` with Maps to: and Use cases: lines.
Error Responses table: `| Error Scenario | Code | Detail | Source |`
Queries table: `| Query | Returns | Notes |`

---

## Per-Feature: test-plan.md

### Required Format

```
## API Tests

### {Operation Name}

| # | Test Case | Method | Expected | Source |
|---|-----------|--------|----------|--------|
| 1 | {scenario} | {HTTP method + route} | {status, body} | UC-{MODULE}-{NNN} |
```

25-35 test cases per feature area.
Source column traces to UC step, FR, or BR.
Covers: happy path, validation failure, auth failure, business rule violation, edge cases.

---

## Per-Feature: ui-mockup.md

### Required Format

Per screen: 3 mockup states (populated, empty, error).
Each mockup includes: component hierarchy, field-to-API mappings, validation rules, action buttons mapped to API calls.

---

## Strict Rules

1. design.md is the master document — all other files are referenced from it
2. Decisions use alternatives table format (not prose)
3. Assumptions use impact table format (not bullets)
4. Work Decomposition includes Component Breakdown table + Dependency Graph + Execution Order
5. Self-Review Log with numbered rounds is mandatory
6. Every feature area with a UI produces 3 mockup states (populated, empty, error)
7. Test plans target 25-35 cases per feature area with Source column tracing to UC/FR/BR
8. ASCII diagrams use `──>` arrows for dependencies
9. Per-feature docs use `features/{sub-feature}/` structure when 3+ feature areas
10. README.md is generated when design directory has 5+ files
