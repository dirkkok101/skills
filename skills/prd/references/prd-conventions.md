# PRD Conventions Reference

Stable structural conventions extracted from the PRD skill. These rules do not change between PRDs — only content varies.

---

## Structural Conventions (Non-Negotiable)

### Mandatory Sections (COMPREHENSIVE)

Every COMPREHENSIVE PRD must contain ALL of these H2 sections in this order:

1. `## Document History`
2. `## Table of Contents`
3. `## Problem Statement`
4. `## Goals`
5. `## Non-Goals`
6. `## Success Metrics`
7. `## User Personas`
8. `## Assumptions & Constraints`
9. `## Use Cases`
10. `## Functional Requirements`
11. `## Non-Functional Requirements`
12. `## Integration Points`
13. `## Prioritisation (MoSCoW)`
14. `## Domain Validation`
15. `## Document Approval`

Optional H2 sections (add when relevant, after Document Approval):
- `## Appendix: API Endpoint Summary (Indicative)`
- `## Appendix: Database Tables (Indicative)`

### Naming & Numbering Conventions

| Element | Format | Example |
|---------|--------|---------|
| Goals | `- **G{n}:** {text}` | `- **G1:** Reduce time-to-access` |
| Non-Goals | `- **NG{n}:** {text} — Reason: {why}` | `- **NG1:** Mobile — Reason: desktop-only` |
| Assumptions | `- **A{n}:** {text}` | `- **A1:** API handles load` |
| Constraints | `- **C{n}:** {text}` | `- **C1:** Must use existing schema` |
| FR IDs | `FR-{MODULE}-{DESCRIPTIVE-NAME}` | `FR-APP-REGISTER` |
| NFR IDs | `NFR-{MODULE}-{DESCRIPTIVE-NAME}` | `NFR-APP-RESPONSE-TIME` |
| UC IDs | `UC-{MODULE}-{NNN}` | `UC-APP-001` |
| Personas | `### P{n}: {Role Title}` | `### P1: Platform Administrator (Primary)` |
| Epics | `### Epic: {Name}` | `### Epic: User Lifecycle` |

### Heading Levels (Fixed)

| Element | Level | Example |
|---------|-------|---------|
| Sections | H2 | `## Problem Statement` |
| Epics | H3 | `### Epic: User Lifecycle` |
| Personas | H3 | `### P1: Platform Administrator` |
| NFRs | H3 | `### NFR-APP-LATENCY: API Response Time` |
| FRs | H4 | `#### FR-APP-SAVE: Save Application` |
| Sub-sections | H3 | `### Assumptions`, `### Constraints`, `### Risks`, `### Open Questions` |

### Persona Sub-Fields (All 6 Mandatory)

Every persona MUST have exactly these 6 bold sub-fields:

```
- **Goals:** {2-3 items}
- **Pain Points:** {2-3 items}
- **Current Workaround:** {how they cope today}
- **Success Criteria:** {how they know the feature works}
- **Tech Level:** {description}
- **Frequency:** {how often they use this}
```

### FR Body Structure (Fixed Format)

```
#### FR-{MODULE}-{NAME}: {Title}
Priority: Must / Should / Could / Won't
Complexity: S / M / L / XL
Related: UC-{MODULE}-{NNN}

As a {persona} (P{n}),
I want to {action},
So that {benefit}.

Acceptance Criteria:
  Given {precondition}
  When {action}
  Then {expected result}

Security Criteria:
  - {requirement}
```

Lines Priority, Complexity, Related appear one per line, no bold. Acceptance Criteria are indented 2 spaces. Security Criteria required on any FR that modifies data, touches auth, or handles PII. Compliance Criteria required on any FR touching regulated data.

### NFR Body Structure (Fixed Format)

```
### NFR-{MODULE}-{NAME}: {Title}
Category: Performance / Security / Scalability / Data / Accessibility
Target: {specific number — "P95 < 200ms", not "fast"}
Load Condition: {context}
Measurement: {how to verify}
Rationale: {traces to problem statement, success metrics, or persona needs}
```

### Table Formats (Fixed Columns)

| Table | Columns (in order) |
|-------|-------------------|
| Success Metrics | Metric \| Current \| Target \| By When \| How Measured |
| Risks | Risk \| Likelihood \| Impact \| Mitigation |
| Open Questions | # \| Question \| Context \| Status \| Decision \| Owner |
| Document Approval | Role \| Name \| Status \| Date |

### MoSCoW Headings (Fixed Text)

```
### Must Have (MVP)
### Should Have (v1)
### Could Have (Future)
### Won't Have (Yet)
```

### Integration Points Sub-Headings (Fixed Text)

```
### Consumed Services
### Exposed Services
### Integration NFRs
```

### Strict Rules

1. FR IDs are DESCRIPTIVE, never sequential numbers (`FR-APP-REGISTER` not `FR-APP-001`)
2. NFR targets contain specific numbers, never adjectives
3. No ambiguity words in acceptance criteria: "appropriate", "reasonable", "quickly", "user-friendly", "intuitive", "properly", "sufficient", "as needed", "etc.", "and/or"
4. At least one error/edge case acceptance criterion per Must Have FR
5. Must Have list <= 10 items
6. Won't Have items always have a "Reason:" rationale
7. Dependency Graph section uses ASCII `-->` arrows showing FR-to-FR build order

---

## Use Case Template & Conventions

### Depth Tiers

- **Tier 1** -- Full Cockburn format: preconditions, success/failure guarantees, step-by-step scenario, extensions, failure paths. For core flows that define the feature.
- **Tier 2** -- Standard format: scenario flow with steps, postconditions, failure paths. For important but less complex flows.
- **Tier 3** -- Index entry with links to relevant guide sections and endpoint lists. For flows that are heavily dependent on external configuration or environment.

### File Structure

**File location depends on scope:**
- **Feature-scoped use cases** (most common) -> `docs/prd/{feature}/use-cases/` -- colocated with the PRD they belong to
- **Cross-module use cases** (span multiple features/aggregates) -> `docs/use-cases/` -- shared common folder

**Filename:** `UC-{MODULE}-{NNN}-{slug}.md`

### Use Case Template

```markdown
# UC-{MODULE}-{NNN}: {Goal as Active Verb Phrase}

> {One-sentence summary of what this use case establishes.}

## Metadata

| Field | Value |
|-------|-------|
| **Actor** | {Persona from Phase 3} |
| **Trigger** | {Event that starts this use case} |
| **Preconditions** | {State that must be true BEFORE the use case starts} |
| **Depth Tier** | Tier {1/2/3} |
| **Status** | Draft |
| **Related Docs** | {Links to PRD sections, guide sections, other UCs} |

## Scenario Flow

### Phase 1: {Phase Name}

| Step | Action | Details |
|------|--------|---------|
| 1.1 | {Actor or System} {action at user-intention level} | {Specifics} |
| 1.2 | ... | ... |

## Postconditions

- {Observable state of the world when goal is achieved}

## Failure Paths

| Failure | Behavior |
|---------|----------|
| {What goes wrong} | {How the system responds} |

## Known Deferred Edges

- {Edge case intentionally excluded from v1 with rationale}
```

### Tier 1 Additional Sections

```markdown
## Minimal Guarantee (on failure)

{What the system guarantees even if the use case fails}

## Business Rules

| Rule ID | Rule | Parameters |
|---------|------|-----------|
| BR-{MODULE}-{NNN} | {Specific rule} | {Thresholds, limits, constraints} |
```

### Scenario Table Format

| Column | Content |
|--------|---------|
| Step | Phase.sequence (e.g. 1.1, 1.2, 2.1) |
| Action | {Actor or System} {action at user-intention level} |
| Details | Specifics -- validation rules, API routes, business logic |

Guidelines:
- 3-9 steps per phase -- write at user-intention level, not UI-action level
- Every step that can fail gets a failure path entry
- Use the table format for scenario steps (not numbered prose)
- Reference other UCs for flows that continue across use cases

### Use Case Index Table (in PRD)

```markdown
## Use Cases

| UC ID | Title | Depth | Actor | Scope | Status |
|-------|-------|-------|-------|-------|--------|
| [UC-{MODULE}-001](use-cases/UC-{MODULE}-001-{slug}.md) | {title} | Tier 1 | {actor} | Feature | Draft |
```

### Traceability Index (COMPREHENSIVE, 5+ use cases)

Save to: `docs/prd/{feature}/use-cases/traceability-index.md`

```markdown
# Traceability Index

| Scenario ID | Scenario Name | Depth Tier | Status | Primary Doc | Test Evidence | Open Gaps |
|-------------|--------------|------------|--------|-------------|---------------|-----------|
| UC-{MODULE}-001 | {title} | Tier 1 | {status} | [link] | {test files} | {gaps} |
```

---

## FR Quality Checklist

### Systematic Edge Case Elicitation

After drafting initial requirements, probe for edge cases -- **focus on Must Have FRs and complex interactions first.** For prioritized FRs, ask:

- **Duplicates:** What if the user does this twice? What if the same data already exists?
- **Boundaries:** What if the input is empty? Maximum length? Zero? Negative?
- **Concurrency:** What if two users do this simultaneously?
- **Permissions:** What if the user doesn't have access? What about partial access?
- **State:** What if a dependency is unavailable? What about stale data?
- **Lifecycle:** What about deletion? Archival? Migration of existing data?

Each discovered edge case becomes either a new acceptance criterion on an existing FR, or a new FR if significant enough.

### Ambiguity Words (Flag and Replace)

Flag any requirement containing: "appropriate", "reasonable", "quickly", "user-friendly", "intuitive", "properly", "sufficient", "as needed", "etc.", "and/or". These words mask undecided requirements. Replace each with a specific, testable statement.

### Testability Rules

- Every acceptance criterion must be verifiable by a test
- "The system should handle errors gracefully" is NOT testable
- "Given a network timeout, when the user submits, then a retry dialog appears within 2 seconds" IS testable

### Independence

Each FR should be deliverable and valuable on its own. If FR-X only makes sense with FR-Y, consider merging them or making the dependency explicit.

### Stable ID Convention

Use descriptive IDs based on feature area, not sequential numbers. `FR-APP-REGISTER` is more stable than `FR-APP-001` -- it survives when requirements are added or removed. Downstream artifacts (design, plan, beads, tests) reference these IDs, so stability prevents cascade updates.

---

## NFR Categories & Minimums

### Categories to Consider

1. **Performance** -- API response time, page load, batch throughput
2. **Security** -- Authentication, encryption, audit logging, rate limiting
3. **Scalability** -- Concurrent users, data volume, geographic distribution
4. **Data** -- Retention, backup, deletion, migration
5. **Accessibility** -- WCAG 2.1 AA, keyboard navigation, screen readers

Every NFR has a number, not an adjective. "Fast" is not a requirement. "< 200ms P95" is. Every NFR target should trace to either the problem statement, a success metric, or a persona need -- arbitrary targets are waste.

### Mandatory NFR: Audit Coverage

Any module with state-changing operations (create, update, delete, status transitions) MUST include an audit NFR (e.g., `NFR-{MODULE}-AUDIT`) specifying: 100% mutation coverage, actor ID + timestamp + entity ID in every log entry, and the audit event type naming convention (`{entity_type}.{action}`).

### Minimum Counts by Mode (Strict)

| Mode | Minimum NFRs |
|------|-------------|
| BRIEF | 2-3 |
| STANDARD | 4-6 |
| COMPREHENSIVE | 6-10 (not 5, not "around 6" -- count them) |

If you have fewer than the minimum, add NFRs for categories you have not covered.

---

## Anti-Patterns

**The Monologue** -- Agent generates entire PRD, dumps it for approval. Instead, pause and validate at each phase. The user knows things the agent does not.

**Solution-First** -- Writing features before establishing the problem. If Phase 2 does not hurt to read, you have not described a real problem.

**Vague Criteria** -- "System should be fast" or "handle errors appropriately". Every requirement needs a number or a specific behavior. Flag ambiguity words.

**Happy Path Only** -- Acceptance criteria that only cover success. Every Must Have FR needs at least one error/edge case criterion. Use the edge case elicitation checklist.

**The Kitchen Sink** -- v1 through v10 in one doc. Strict MoSCoW with Won't Have. If the Must Have list has more than 10 items, some of them are not Must Haves.

**Silent Assumptions** -- Taking things for granted without documenting them. If an assumption proves false and there is no record, nobody knows which requirements to revisit.

**Orphan Stories** -- Stories not linked to personas or use cases. If you cannot name the persona, the requirement may not solve a real problem.

**Arbitrary NFR Targets** -- Setting performance or scalability targets without rationale. "P95 < 200ms" means nothing without knowing the current baseline and why that number matters. Every target traces to a real need.

**Monolith PRD** -- Embedding use cases, detailed scenarios, and gap analysis inline in the PRD. A 134KB PRD is unreadable and unmaintainable. Use cases are standalone files. The PRD references them by link and index table. Each artifact should be reviewable on its own.

**Undocumented Evolution** -- Making significant changes to the PRD without recording what changed and why. The Document History table exists for this -- update it after each adversarial review round, scope change, or user feedback incorporation.

---

## BRIEF Mode Template

For BRIEF scope, skip Phases 3, 5, 8, 8b, 9, 10b. Produce this streamlined one-page format:

```markdown
# PRD: {Feature Name} (Brief)

**Date:** {today} | **Scope:** BRIEF | **Status:** Draft

## Problem
{2-3 sentences -- what's broken and for whom}

## Goals
- {Measurable outcome 1}
- {Measurable outcome 2}

## Non-Goals
- {What we're explicitly NOT doing}

## Assumptions
- {Key assumptions that could change scope if wrong}

## Requirements

### FR-{MODULE}-{NAME}: {Title} [Must]
As a {role}, I want {action}, so that {benefit}.
- Given {X}, When {Y}, Then {Z}
- Given {error}, When {invalid}, Then {handled}

### FR-{MODULE}-{NAME}: {Title} [Must]
...

{3-5 stories total}

## NFRs
- NFR-{MODULE}-{NAME}: {target with number and rationale}

## Open Questions
- {Anything unresolved}
```
