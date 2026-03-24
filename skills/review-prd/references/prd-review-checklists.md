# PRD Review Checklists

Reference tables for `/review-prd` phases. The SKILL.md workflow drives when and how to apply these checklists.

---

## Phase 1: Structural Completeness

Check every section the /prd skill template requires for the PRD's scope level. The /prd v3.7 Structural Conventions section defines exact formats — these are non-negotiable. For each check, record Pass / Warning / Fail.

**Note on Policy & Standards PRDs:** PRDs that define shared policies or cross-cutting concerns (rather than a single bounded module) may legitimately have lighter Personas, Use Cases, NFRs, and Dependency Graphs. If the PRD explicitly identifies itself as a policy/standards document, apply the exceptions noted in /prd v3.7 "Policy & Standards PRDs" section. The structural conventions (heading formats, numbering, table columns) still apply without exception.

### 1.1 Metadata & Document History

| Check | Criteria | Severity |
|-------|----------|----------|
| H1 title format | `# PRD: {Name}` | Fail if wrong format |
| Metadata table present | `\| Field \| Value \|` format | Fail if missing |
| Required metadata fields | Version, Date, Author, Status, Scope | Fail per missing field |
| Recommended metadata fields | Brainstorm, Discovery, Depends On | Warning per missing field |
| Document History table | `\| Version \| Date \| Changes \|` with at least one entry | Fail if missing |
| Scope field valid | One of: BRIEF, STANDARD, COMPREHENSIVE | Fail if missing or invalid |
| TOC present (COMPREHENSIVE) | `## Table of Contents` section | Fail if missing for COMPREHENSIVE |

### 1.2 Problem & Business Context (all modes)

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Problem Statement` section | 2-3 sentences with specific evidence | Fail if missing |
| `Impact:` list | Bullet list starting with `Impact:` | Fail if missing |
| `Why now:` statement | Line starting with `Why now:` | Fail if missing |
| `## Goals` section | Present with `**G{n}:**` numbered items (3-5) | Fail if missing or unnumbered |
| `## Non-Goals` section | Present with `**NG{n}:**` numbered items, each with `Reason:` | Fail if missing or unnumbered |
| `## Success Metrics` table (STANDARD+) | Columns: Metric, Current, Target, By When, How Measured | Fail if missing for STANDARD+ |

### 1.3 Personas (STANDARD+)

| Check | Criteria | Severity |
|-------|----------|----------|
| `## User Personas` section | Present with `### P{n}: {Role Title}` headings | Fail if missing for STANDARD+ |
| Persona count | 2-4 personas defined | Warning if outside range |
| Mandatory sub-fields (per persona) | All 6 required: `**Goals:**`, `**Pain Points:**`, `**Current Workaround:**`, `**Success Criteria:**`, `**Tech Level:**`, `**Frequency:**` | Fail per missing sub-field |

### 1.4 Assumptions, Constraints & Risks

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Assumptions & Constraints` section | Present as H2 | Fail if missing |
| `### Assumptions` sub-heading | H3 under Assumptions & Constraints | Fail if missing |
| Assumption numbering | `**A{n}:**` format, at least 3 items | Fail if unnumbered, Warning if < 3 |
| `### Constraints` sub-heading (STANDARD+) | H3 under Assumptions & Constraints | Fail if missing for STANDARD+ |
| Constraint numbering | `**C{n}:**` format, at least 2 items | Fail if unnumbered, Warning if < 2 |
| `### Risks` sub-heading (STANDARD+) | H3 with table: Risk \| Likelihood \| Impact \| Mitigation | Fail if missing |
| `### Open Questions` sub-heading (STANDARD+) | H3 with table: # \| Question \| Context \| Status \| Decision \| Owner. If none, state "None — all resolved" | Fail if missing or wrong columns |

### 1.5 Use Cases (COMPREHENSIVE only)

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Use Cases` section | Index table linking to standalone UC files | Fail if missing for COMPREHENSIVE |
| UC files exist | Referenced files actually exist on disk | Fail per missing file |
| UC format (Tier 1) | Metadata, Scenario Flow, Postconditions, Failure Paths, Minimal Guarantee, Business Rules | Warning per missing section |
| UC format (Tier 2) | Metadata, Scenario Flow, Postconditions, Failure Paths | Warning per missing section |

### 1.6 Functional Requirements (all modes)

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Functional Requirements` section | Present as H2 | Fail if missing |
| Epic organisation | FRs grouped under `### Epic: {Name}` headings (H3) | Fail if no epics |
| FR heading format | `#### FR-{MODULE}-{DESCRIPTIVE-NAME}: {Title}` (H4, descriptive ID) | Fail per wrong format |
| FR IDs not sequential | No `FR-{MODULE}-001` patterns | Fail per violation |
| FR body: Priority line | `Priority: Must / Should / Could / Won't` (one per line, no bold) | Fail per missing |
| FR body: Complexity line | `Complexity: S / M / L / XL` | Warning per missing |
| FR body: User story | `As a {persona} (P{n}), I want ..., So that ...` | Fail per missing story |
| FR body: Acceptance Criteria | `Acceptance Criteria:` header followed by indented (2 spaces) `Given / When / Then` | Fail per missing criteria |
| FR body: Security Criteria | `Security Criteria:` present on FRs that modify data, touch auth, or handle PII | Fail per missing (COMPREHENSIVE), Warning (STANDARD) |
| FR body: Compliance Criteria | `Compliance Criteria:` present on FRs touching regulated data | Warning per missing |
| FR count minimum | At least 3 (BRIEF), 8 (STANDARD), 10 (COMPREHENSIVE) | Warning if below minimum |

### 1.7 Non-Functional Requirements (all modes)

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Non-Functional Requirements` section | Present as H2 | Fail if missing |
| NFR heading format | `### NFR-{MODULE}-{DESCRIPTIVE-NAME}: {Title}` (H3, descriptive ID) | Fail per wrong format |
| NFR IDs not sequential | No `NFR-{MODULE}-001` patterns | Fail per violation |
| NFR body: Category | `Category:` line present | Fail per missing |
| NFR body: Target | `Target:` line with a specific number (not adjectives) | Fail per missing or unmeasurable |
| NFR body: Measurement | `Measurement:` line present | Fail per missing |
| NFR body: Rationale | `Rationale:` line tracing to problem/metrics/persona | Fail per missing |
| NFR count minimum | At least 2 (BRIEF), 4 (STANDARD), 6 (COMPREHENSIVE) | Fail if below minimum |
| Mandatory audit NFR | `NFR-{MODULE}-AUDIT` or equivalent present for modules with state-changing operations. When fixing, use this template: `### NFR-{MODULE}-AUDIT: Lifecycle Audit Coverage` / `Category: Compliance` / `Target: 100% of create, update, delete, and status-change operations produce audit entries with actor ID, timestamp, entity ID, operation type, and event name ({entity_type}.{action})` / `Measurement: Integration tests verifying audit log entries for each mutation endpoint` / `Rationale: {trace to cross-cutting PRD audit requirements and SOC 2 compliance}` | Fail if missing |

### 1.8 Integration Points (COMPREHENSIVE only)

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Integration Points` section | Present as H2 | Fail if missing for COMPREHENSIVE |
| `### Consumed Services` sub-heading | H3 with service table | Fail if missing |
| `### Exposed Services` sub-heading | H3 with service table | Fail if missing |
| `### Integration NFRs` sub-heading | H3 with integration constraints | Warning if missing |

### 1.9 Prioritisation (STANDARD+)

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Prioritisation (MoSCoW)` section | Present as H2 | Fail if missing for STANDARD+ |
| `### Must Have (MVP)` heading | Exact H3 text | Fail if missing |
| `### Should Have (v1)` heading | Exact H3 text | Fail if missing |
| `### Could Have (Future)` heading | Exact H3 text | Fail if missing |
| `### Won't Have (Yet)` heading | Exact H3 text, each item has `Reason:` | Fail if missing |
| Must Have list bounded | 10 or fewer items | Warning if exceeded |
| `## Dependency Graph` section | ASCII diagram using `──>` arrows showing FR-to-FR build order | Fail if missing |

### 1.10 Domain Validation (COMPREHENSIVE only)

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Domain Validation` section | Present as H2 | Fail if missing |
| `### Coverage Matrix` | Table mapping requirements to FRs, UCs, and status | Fail if missing |
| Validation checklist | All items checked or annotated | Warning if incomplete |

### 1.11 Document Approval (COMPREHENSIVE only)

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Document Approval` section | Present as H2 | Fail if missing |
| Approval table format | Columns: Role \| Name \| Status \| Date (in that order) | Fail if wrong columns |
| Approval footer | "Approval means: ..." statement present | Warning if missing |

Record all results. Do not present passes to the user.

---

## Phase 2: Content Quality Rules (STANDARD+)

Beyond structural presence, examine content substance. Each check produces a finding only when it fails.

**Acceptance Criteria Testability:**

For each FR's acceptance criteria:
- Is the Given/When/Then specific enough to write a test? ("Given valid data" is not specific — what data?)
- Does at least one criterion cover an error/edge case? (Happy path only = Warning)
- Are there ambiguity words? Flag: "appropriate", "reasonable", "quickly", "user-friendly", "intuitive", "properly", "sufficient", "as needed", "etc.", "and/or"

Citation: /prd Phase 6 — Requirement Quality Check, Ambiguity words list.

**NFR Measurability:**

For each NFR:
- Does the Target contain a specific number? ("should be fast" = Fail, "P95 < 200ms" = Pass)
- Is the Measurement method defined? (How would you verify this in production?)
- Does the Rationale trace to problem statement, success metrics, or persona needs?

Citation: /prd Phase 7 — "Every NFR has a number, not an adjective."

**Success Metrics Completeness:**

For each success metric:
- Are all columns populated: Current baseline, Target, By When, How Measured?
- Is the target actually different from current? (Same = Warning)
- Is "How Measured" actionable? ("We'll know" = Fail, "Datadog P95 dashboard" = Pass)

Citation: /prd Phase 2 Step 2.4.

**Use Case Completeness (COMPREHENSIVE):**

For each Tier 1 use case:
- Are preconditions specific? (Can you set up this state in a test?)
- Is the success guarantee observable? (Can you verify it happened?)
- Are failure paths enumerated for every step that can fail?
- Is the Minimal Guarantee defined?

Citation: /prd Phase 5 — Tier 1 use case format.

**Persona References:**

- Do FR user stories reference personas defined in the Personas section (or project persona doc)?
- Are all personas used by at least one FR? (Orphan persona = Warning)
- Are all Must Have FRs linked to a primary persona?

Citation: /prd Traceability Rules — "Every FR maps to at least one persona."

**Stable ID Convention:**

- Are FR IDs descriptive (`FR-APP-REGISTER`) not sequential (`FR-APP-001`)?
- Are NFR IDs descriptive (`NFR-APP-RESPONSE-TIME`) not sequential?

Citation: /prd Phase 6 — Stable ID convention.

**Naming Convention Consistency:**

- Do all goals use `**G{n}:**` format? Check every bullet in the Goals section.
- Do all non-goals use `**NG{n}:**` format with `— Reason:` suffix?
- Do all assumptions use `**A{n}:**` format?
- Do all constraints use `**C{n}:**` format?
- Are numbering sequences contiguous (no gaps like A1, A2, A5)?

Citation: /prd v3.7 Structural Conventions — Naming & Numbering Conventions.

**Heading Level Compliance:**

- Are all main sections H2? (## Problem Statement, ## Goals, etc.)
- Are epics H3? (### Epic: {Name})
- Are FRs H4? (#### FR-{MODULE}-{NAME}: {Title})
- Are NFRs H3? (### NFR-{MODULE}-{NAME}: {Title})
- Are personas H3? (### P{n}: {Role Title})

Citation: /prd v3.7 Structural Conventions — Heading Levels.

**Audit Coverage:**

- Does the PRD include an audit NFR (NFR-{MODULE}-AUDIT or equivalent)?
- Does the audit NFR specify: mutation coverage %, actor ID + timestamp + entity ID, and event type naming convention?
- For modules with state-changing operations, is audit logging addressed in Security Criteria on individual FRs?

Citation: /prd v3.7 Phase 7 — Mandatory NFR: Audit coverage.

---

## Phase 3: Cross-Cutting Compliance Framework (STANDARD+)

Check the PRD against the cross-cutting PRD and project-wide standards. Each finding cites the specific cross-cutting requirement.

**Audit Logging:**

- Do state-changing FRs (create, update, delete, status transitions) include audit logging in their acceptance criteria or reference a cross-cutting audit requirement?
- Citation: Cross-cutting PRD audit logging requirements.

**Data Lifecycle:**

- Do FRs involving data creation address deletion/archival? (Soft delete, hard delete, retention?)
- Is there an FR or NFR covering data lifecycle for the module?
- Citation: Cross-cutting PRD data lifecycle requirements.

**Error Handling:**

- Do FRs specify error behavior, not just happy path?
- Do error criteria follow project error handling patterns?
- Citation: Cross-cutting PRD error handling patterns.

**Pagination & Filtering:**

- Do list/search FRs specify pagination behavior?
- Are default page sizes and maximum limits defined?
- Citation: Cross-cutting PRD pagination/filtering requirements.

**ADR Compliance:**

- Do FRs contradict any existing ADRs? (e.g., using string constants where ADR-0004 requires enums)
- Do NFRs align with architecture decisions?
- Citation: Specific ADR number and title.

---

## Phase 4: Adversarial Depth Checks (COMPREHENSIVE only)

Go beyond compliance into adversarial analysis. Ask: "Could this PRD lead to a wrong implementation that still technically satisfies the requirements?"

### Severity Guide

| Finding Type | Severity | Example |
|-------------|----------|---------|
| AC cannot distinguish correct from incorrect implementation | **FAIL** | "Data is saved" — doesn't say where, in what format, with what constraints |
| Missing boundary values on Must Have FR | **WARN** | No max length on name field, no max items on list |
| Assumption with no documented impact if wrong | **WARN** | "API can handle load" — what breaks if it can't? |
| Non-goal too vague to enforce | **WARN** | "Won't over-engineer" vs "Won't support mobile" |
| Security criteria missing on data-modifying Must Have FR | **FAIL** | FR modifies PII with no auth/validation criteria |
| Failure path missing for critical UC step | **WARN** | No handling for concurrent modification |

### Acceptance Criteria Discrimination

For each Must Have FR:
- Can the acceptance criteria distinguish a correct implementation from an incorrect one?
- Could a malicious-compliance implementation pass all criteria while missing the intent?
- Are boundary values specified? (What's the maximum? Minimum? Empty case?)

Finding format: "FR-{ID}: Criteria accept both correct and incorrect implementations because {gap}."

### Failure Path Exhaustiveness

For each Tier 1 use case:
- Are ALL failure paths enumerated, not just the obvious ones?
- What about: network failure mid-operation, concurrent modification, partial state, timeout, authentication expiry during flow?

Finding format: "UC-{ID} Step {N}: Missing failure path for {scenario}."

### Assumption Impact Analysis

For each documented assumption:
- Is "impact if wrong" documented or inferable?
- If this assumption proves false, which FRs become invalid?
- Are high-impact assumptions flagged as risks?

Finding format: "Assumption '{text}': No documented impact if wrong. Affects FR-{IDs}."

### Non-Goal Effectiveness

For each non-goal:
- Does it actually prevent scope creep, or is it too vague to enforce?
- "We won't do mobile" is enforceable. "We won't over-engineer" is not.

Finding format: "Non-goal '{text}': Too vague to enforce. Suggestion: {specific rewording}."

### Security Coverage

- Do all FRs that modify data have security criteria?
- Are authorization checks specified? (Who can do this? What happens if they can't?)
- Are input validation rules specified for user-facing FRs?

Finding format: "FR-{ID}: Modifies data but has no security criteria. Needs: {specific criteria}."
