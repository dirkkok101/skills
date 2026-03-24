# Design Conventions Reference

Stable structural conventions for the technical-design skill. These define the non-negotiable file layouts, heading structures, table formats, and anti-patterns that apply to every design produced by this skill.

---

## Output Directory Structure

### Flat Design (1-2 feature areas)

```
${PROJECT_ROOT}/docs/designs/{feature}/
├── README.md            # Index (only if 5+ files)
├── design.md            # Constraints, decisions, security, operations, decomposition, self-review log
├── glossary.md          # Term disambiguation (if needed)
├── architecture.md      # C4 diagrams + data model (STANDARD+)
├── data-model.md        # ER diagram + entity definitions + migration (if applicable)
├── api-surface.md       # Endpoints, contracts, validation, backend flow
├── ui-mockup.md         # Mockups with multiple states (if applicable)
├── test-plan.md         # Numbered test cases
├── decisions/           # Feature-scoped decision records (as needed)
│   └── {decision}.md
├── research/            # Co-located research (if applicable)
│   └── {topic}.md
└── diagrams/            # Cross-cutting diagrams (STANDARD+)
    ├── sequences.md
    ├── workflows.md
    └── data-flows.md
```

### Decomposed Design (3+ feature areas)

```
${PROJECT_ROOT}/docs/designs/{feature}/
├── README.md            # Index — REQUIRED for decomposed designs
├── design.md            # Constraints, decisions, security, operations, sibling refs, decomposition, self-review log
├── glossary.md          # Term disambiguation (if needed)
├── architecture.md      # C4 diagrams (STANDARD+)
├── data-model.md        # ER diagram + entity definitions + migration
├── features/
│   ├── {feature-a}/
│   │   ├── api-surface.md   # Endpoints, contracts, validation, backend flow
│   │   ├── backend.md       # OPTIONAL: separate when 5+ commands/queries
│   │   ├── ui-mockup.md     # ASCII mockups (if feature has UI)
│   │   └── test-plan.md     # Numbered test cases
│   ├── {feature-b}/
│   │   ├── api-surface.md
│   │   ├── ui-mockup.md
│   │   └── test-plan.md
│   └── {feature-c}/
│       ├── api-surface.md
│       └── test-plan.md     # No UI for this feature
├── decisions/
│   └── {decision}.md
├── research/
│   └── {topic}.md
└── diagrams/
    ├── sequences.md
    └── workflows.md
```

### Feature Specifications (COMPREHENSIVE, 3+ feature areas, optional)

```
${PROJECT_ROOT}/docs/designs/{feature}/features/
├── overview.md              # Coverage matrix, test ID conventions, cross-references
├── 01-{feature-name}.md     # Consolidated spec: UCs, endpoints, UI, plan tasks
├── 02-{feature-name}.md
└── ...
```

---

## Structural Conventions (Non-Negotiable)

Only domain content varies between designs — structure, file organization, heading levels, and table formats are fixed.

### Mandatory Files (STANDARD+)

| File | Purpose |
|------|---------|
| `design.md` | Master design: constraints, assumptions, decisions, security, ops, decomposition |
| `README.md` | Entry point with links to all artifacts (when 5+ files) |
| `architecture.md` | C4 Level 1 (System Context) + C4 Level 2 (Container) diagrams |
| `data-model.md` | ER diagram, entity definitions, migration strategy |
| `glossary.md` | Domain term disambiguation |

Exception: policy/standards designs (e.g., cross-cutting concerns) may omit `architecture.md` and `data-model.md` if they define rules rather than entities.

### Mandatory H2 Sections in design.md (in order)

```
## Documentation Foundation
## Constraints
## Assumptions
## Key Decisions
## Security & Privacy
## Operational Design
## Work Decomposition
## Self-Review Log
```

Optional H2 sections (add when relevant):

```
## Context                              — before Constraints
## Prior Decisions & Established Patterns — before Key Decisions
## Domain Model                         — after Key Decisions (or reference data-model.md)
## System Protection Rules              — after Domain Model
## API Surface Summary                  — after Domain Model
## Scope Exclusions                     — after Work Decomposition
## Cross-Cutting FR Coverage            — after Work Decomposition
## Open Questions                       — after Work Decomposition
```

### Documentation Foundation Format

```markdown
## Documentation Foundation

### Upstream Artifacts
| Artifact | Location |
|----------|----------|
| PRD | [link] |
| Use Cases | [link] |

### Sibling Designs
| Design | Relationship to This Module |
|--------|----------------------------|
| [{name}]({link}) | {relationship} |

### Learnings Applied
| Learning | Source | How Applied |
|----------|-------|-------------|
| {learning} | {source} | {application} |
```

All three sub-headings are expected. Learnings Applied may be empty if no prior learnings exist — state "None applicable" rather than omitting the heading.

### Constraints Format

```markdown
## Constraints

### Technical Constraints
- {constraint}

### Organisational Constraints
- {constraint}
```

Both sub-headings required.

### Assumptions Format (Table, Not Bullets)

```markdown
## Assumptions

| # | Assumption | Impact if Wrong | How to Validate |
|---|-----------|----------------|-----------------|
| 1 | {text} | {consequence} | {validation} |
```

Always a 4-column table. Never bullet lists for assumptions.

### Key Decisions Format (Two-Layer Pattern)

**Layer 1 — design.md summary table:**

```markdown
## Key Decisions

### Design Decisions

| Decision | Chosen Approach | Rationale | Record |
|----------|----------------|-----------|--------|
| {what} | {chosen} | {why} | [details](decisions/{slug}.md) |
```

**Layer 2 — decisions/{slug}.md full exploration:**

```markdown
# Decision: {What's being decided}

## Context
{Why this matters.}

## Alternatives
| Approach | Description | Pros | Cons |
|----------|-------------|------|------|
| A: {Name} | {how} | {pros} | {cons} |
| B: {Name} | {how} | {pros} | {cons} |

## Decision
**Chosen:** {approach} because {reasoning}.
**Trade-off accepted:** {what we gave up}.

## Consequences
- {what this enables/constrains}
```

### Operational Design Format

```markdown
## Operational Design

### Deployment Strategy
- {approach, rollback plan}

### Failure Modes
| Component | Failure Mode | Impact | Mitigation |
|-----------|-------------|--------|------------|

### Observability
- **Metrics:** {key metrics}
- **Logging:** {fields, levels}
- **Alerting:** {conditions}
```

All three sub-headings required.

### Work Decomposition Format

```markdown
## Work Decomposition

### Component Breakdown
| Component | Scope | Complexity | Risk | Implements |
|-----------|-------|------------|------|-----------|

### Dependency Graph
  Component A ──> Component B ──> Component C

### Suggested Execution Order
1. {first — why}
2. {second — why}
```

All three sub-headings required. Dependency Graph uses ASCII `──>` arrows.

### Self-Review Log Format

```markdown
## Self-Review Log

| Round | Issues | Key Fixes |
|-------|--------|-----------|
| 1 | {count} | {description} |
| 2 | {count} | {description} |
```

Table format with numbered rounds. Minimum 2 rounds for STANDARD, 3 for COMPREHENSIVE.

### Per-Feature File Structure

| Feature Areas | Structure |
|---------------|-----------|
| 1-2 | Flat files at module root: `api-surface.md`, `test-plan.md`, `ui-mockup.md` |
| 3+ | Per-feature subdirs: `features/{area}/api-surface.md`, etc. |

### api-surface.md Required Sections

```
## Endpoints                    — | Verb | Route | Purpose | Maps To | Auth Policy |
## Response Codes               — | Operation | Success Code | Body |
## Error Responses              — | Error Scenario | Code | Detail | Source |
## Contracts                    — DTO definitions, writable vs read-only
## Validation Rules             — sync vs DB-lookup, BR-* references
## Backend                      — directory structure, command flow, mapper, queries
```

The Endpoints table MUST include `Maps To` (FR-ID) and `Auth Policy` columns. Every endpoint traces to at least one FR.

### test-plan.md Required Format

```
## API Tests
### {Operation Name}
| # | Test Case | Method | Expected | Source |
```

Target 25-35 test cases per feature area. Source column traces to UC/FR/BR.

### Strict Rules

1. **Feature areas come from PRD Epics** — do not invent feature decomposition. Document any deviation with rationale.
2. **PRD Coverage Matrix is mandatory** — every Must Have FR must map to an endpoint and test cases. No gaps allowed before self-review.
3. **ADR Compliance table is mandatory** — scan ALL ADRs, classify each as applicable or not.
4. Assumptions use **table format** (4 columns), never bullet lists.
5. Decisions use **two-layer pattern**: summary table in design.md, full exploration in decision files.
6. Self-Review uses **table format** with numbered rounds.
7. Work Decomposition includes **Component Breakdown table + Dependency Graph + Execution Order**.
8. Dependency Graph uses ASCII `──>` arrows.
9. Per-feature docs use `features/{area}/` when 3+ feature areas.
10. `README.md` generated when design directory has 5+ files.
11. All three Documentation Foundation sub-headings present (Upstream Artifacts, Sibling Designs, Learnings Applied).
12. architecture.md includes C4 Level 1 + Level 2 diagrams.
13. Test plans target 25-35 cases with Source column tracing to UC/FR/BR.
14. Endpoint table uses 5 columns: `Verb | Route | Purpose | Maps To | Auth Policy`.
15. Phase 2 / Should Have FRs designed at architectural level (data model + routes) even if implementation deferred.

---

## Anti-Patterns

**The Solution Monologue** — Agent generates entire design without pausing. The collaborative model exists because the user's domain knowledge catches problems early that cost 10x more to fix in detailed design. Every PAUSE point is a chance to course-correct before investing further effort.

**Straw-Man Alternatives** — Listing obviously bad options to make the chosen approach look good. Reviewers see through this immediately. Every alternative should be genuinely viable — if you can't make a case for an option without hedging, it's a straw man. Remove it and find a real alternative.

**The Monolith API Spec** — Putting all endpoints into one massive `api-spec.md` when the feature has 3+ distinct areas. Each feature area should have its own `api-surface.md` so a developer working on "application clients" reads only the application clients doc, not the entire feature's endpoint list. The trigger for decomposition is 3+ feature areas identified from the PRD's FR groupings.

**Pseudocode as Line-By-Line Code** — Design docs should include **command flow pseudocode** showing algorithmic intent (create-or-update logic, protection checks, cascade operations). This is the right level of abstraction. What they should NOT include is line-by-line implementation code with exact syntax, imports, and error handling — that belongs in the codebase. The test is: does this pseudocode tell the developer WHAT the algorithm does, or does it tell them HOW to type it? The former is design; the latter is implementation.

**Scope Confusion** — Re-arguing product requirements in the technical design. The TDD accepts the PRD's requirements as given. If a requirement seems wrong, feed that back to the PRD, don't silently change scope. The right action is to escalate, not to quietly design around it.

**Missing Operations** — No deployment strategy, no failure modes, no monitoring. These aren't afterthoughts — they're first-class design concerns that affect architecture decisions. If you design the system without thinking about how it fails, the first production incident will reveal the gaps.

**Premature Future-Proofing** — Designing for 100x scale when current load is trivial. Design for what you know, document assumptions about growth, and note where the design would need to change at scale. The design doc captures these assumptions so future engineers know when to revisit.

**Orphaned Research and Decisions** — Storing research in `docs/research/` and decisions in `docs/adr/` where nobody finds them when reading the design. Feature-scoped research and decisions should be co-located with the design directory so they're discoverable in context. Only project-wide ADRs belong in the central `docs/adr/` directory.

**Testing as Afterthought** — Treating the testing strategy as a paragraph in design.md. Test plans are first-class design documents with numbered test cases per feature area. If you can't write specific test cases, the API surface and validation rules aren't detailed enough — fix the design, then the test plan follows naturally.

**Implementation Anchoring** — Reading existing source code to "understand" how to design the feature, then producing a design that mirrors the current implementation. This defeats the purpose of design — especially on re-runs where the existing code may be wrong or poorly structured. Design from the PRD, upstream artifacts, and project knowledge (patterns, architecture, ADRs). The only codebase files you should read are those explicitly referenced in `docs/patterns/` or `docs/architecture/` as canonical examples of an established pattern.

**Ignoring Prior ADRs** — Making decisions that contradict existing ADRs in `docs/adr/` without acknowledging the conflict. Prior ADRs are constraints. If this design needs to diverge, it must propose superseding the ADR with a new one — not silently make the opposite choice.
