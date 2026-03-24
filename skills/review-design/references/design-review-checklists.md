# Design Review Checklists

Reference tables for `/review-design` phases. The SKILL.md workflow drives when and how to apply these checklists.

---

## Phase 1: Structural Completeness

Check the design against the `/technical-design` v3.7 Structural Conventions. File structure, table formats, and PRD traceability are non-negotiable. Heading names are preferred conventions — **FAIL if the concern is missing entirely, WARN if the content is present but under a non-canonical heading name.** Substance over form: a design that covers auth thoroughly in bullets under "Security Model" is better than one with perfect `### Authentication & Authorization` heading and shallow content.

**Note on policy/standards designs:** Designs for shared concerns (e.g., cross-cutting, error contracts) may omit `architecture.md` and `data-model.md` if they define rules rather than entities. All other structural conventions still apply.

### 1.1 File Structure

| Check | Criteria | Severity |
|-------|----------|----------|
| `design.md` exists | Master design document | Fail if missing |
| `README.md` exists | Entry point index (when 5+ files) | Fail if missing |
| `architecture.md` exists | C4 Level 1 + Level 2 diagrams | Fail if missing (unless policy design) |
| `data-model.md` exists | ER diagram, entity definitions, migration | Fail if missing (unless policy design) |
| `glossary.md` exists | Domain term disambiguation | Warn if missing |
| `decisions/` directory | Feature-scoped decision records | Warn if missing |
| `diagrams/` directory | Sequence, workflow, data flow diagrams | Warn if missing |
| Feature decomposition | 1-2 areas: flat files. 3+ areas: `features/{area}/` subdirs | Warn if wrong structure |
| Feature areas match PRD Epics | Each `features/{area}/` should correspond to a PRD `### Epic:`. Document deviation rationale. | Warn if areas don't match PRD Epics |

### 1.2 design.md Mandatory H2 Sections (in order)

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Documentation Foundation` | Present as H2 | Fail if missing |
| `### Upstream Artifacts` | H3 under Documentation Foundation, with artifact table | Fail if missing |
| `### Sibling Designs` | H3 with relationship table | Warn if missing |
| `### Learnings Applied` | H3 with learning table (or "None applicable") | Warn if missing |
| `## Constraints` | Present as H2 | Fail if missing |
| `### Technical Constraints` | H3 under Constraints | Fail if missing |
| `### Organisational Constraints` | H3 under Constraints | Fail if missing |
| `## Assumptions` | Present as H2, **4-column table format** (# \| Assumption \| Impact if Wrong \| How to Validate) — never bullet lists | Fail if missing or wrong format |
| `## Key Decisions` | Present as H2 | Fail if missing |
| Decision summary table | `Decision \| Chosen Approach \| Rationale` table in design.md (Layer 1 of two-layer pattern) | Fail if missing |
| Decision record files | Full exploration in `decisions/{slug}.md` files (Layer 2) | Warn if no files |
| `## Security & Privacy` | Present as H2 | Fail if missing |
| `### Authentication & Authorization` | Auth policies, claims, guards — content must be present; exact heading name is preferred but not required | Warn if concern not addressed (regardless of heading name) |
| `### Audit Logging` | Event types, retention — content must be present; exact heading name is preferred but not required | Warn if concern not addressed (regardless of heading name) |
| `## Operational Design` | Present as H2 | Fail if missing |
| `### Deployment Strategy` | H3 under Operational Design | Fail if missing |
| `### Failure Modes` | H3 with table: Component \| Failure Mode \| Impact \| Mitigation | Fail if missing |
| `### Observability` | H3 with Metrics, Logging, Alerting | Fail if missing |
| `## Work Decomposition` | Present as H2 | Fail if missing |
| `### Component Breakdown` | H3 with table: Component \| Scope \| Complexity \| Risk \| Implements | Fail if missing |
| `### Dependency Graph` | ASCII diagram present | Fail if missing |
| Dependency graph arrows | Must use `──>` ASCII arrows (not prose like "depends on") | Warn if wrong format |
| `### Suggested Execution Order` | Numbered list with rationale | Fail if missing |
| `### PRD Coverage Matrix` | Table: FR ID \| Title \| Priority \| Feature Area \| API Endpoint \| Test Cases \| Status. Every Must Have = Covered. | Fail if missing or Must Have gaps |
| `### ADR Compliance` | Table: ADR \| Title \| Applicable \| How Applied. ALL ADRs in docs/adr/ must be classified. | Fail if missing |
| `## Self-Review Log` | Table format: Round \| Issues \| Key Fixes. Minimum 2 rounds (STANDARD), 3 (COMPREHENSIVE) | Fail if missing or < 2 rounds |

### 1.3 architecture.md

| Check | Criteria | Severity |
|-------|----------|----------|
| C4 Level 1 (System Context) | ASCII diagram, 3-7 elements, connections labelled with protocol | Fail if missing |
| C4 Level 2 (Container) | ASCII diagram, technology choices noted, ports/protocols | Fail if missing |
| C4 Level 3 (Component) | Present if feature modifies internal container structure | Warn if missing when applicable |

### 1.4 data-model.md

| Check | Criteria | Severity |
|-------|----------|----------|
| ER diagram | ASCII entity-relationship diagram | Fail if missing |
| Entity definitions | All properties typed, relationships documented, indexes noted, RLS notes for tenant-scoped | Fail if incomplete |
| Migration strategy | New/changed tables, rollback approach | Warn if missing |

### 1.5 Per-Feature Documentation (per feature area)

| Check | Criteria | Severity |
|-------|----------|----------|
| `api-surface.md` exists | Per feature area | Fail if missing |
| Endpoints table | `Verb \| Route \| Purpose \| Maps To \| Auth Policy` format — every endpoint traces to an FR | Fail if missing |
| Response Codes section | Success codes per operation | Warn if missing |
| Error Responses | Error scenario table with Source column | Warn if missing |
| Contracts | DTO definitions, writable vs read-only distinguished | Warn if missing |
| Validation Rules | Present, sync vs DB-lookup noted, BR-* references | Warn if missing |
| Backend section | Directory structure, command flow pseudocode, mapper logic, queries | Warn if missing |
| `test-plan.md` exists | Per feature area | Fail if missing |
| Test case count | 25-35 per feature area | Warn if below 20 |
| Source column | Each test traces to UC, FR, or BR | Warn if missing |
| `ui-mockup.md` exists | Per feature area with UI | Warn if missing |
| Mockup states | At least populated + one other state (empty or error) per primary screen | Warn if only populated state |

### 1.6 Cross-Cutting Diagrams

| Check | Criteria | Severity |
|-------|----------|----------|
| `diagrams/sequences.md` | One per critical flow (write, read, error recovery) | Warn if missing |
| Sequence diagram quality | 3-5 participants, request AND response, ALT blocks for errors | Warn if incomplete |
| `diagrams/workflows.md` | Present for business processes with decisions | Warn if missing when applicable |

Record all structural findings. Do not present passes to the user.

---

## Phase 2: PRD to Design Alignment

Cross-reference every PRD element against the design. This is the core compliance check.

### 2.1 Functional Requirements Coverage

**Do NOT rely on the design's own PRD Coverage Matrix.** Independently verify by reading the PRD and cross-checking:

For every FR in the PRD:
1. Read the FR ID, title, and priority from the PRD
2. Search the design's endpoint tables for a `Maps To` reference to this FR
3. Search the design's test plans for a `Source` reference to this FR
4. Classify:

| Priority | Required Coverage | Severity if Missing |
|----------|-------------------|---------------------|
| Must Have | Endpoint + contracts + validation + backend flow + test cases | **FAIL** |
| Should Have | Endpoint sketch + data model accommodation (Phase 2 arch) | **WARN** |
| Could Have / Won't Have | Should NOT appear in design (scope creep) | **WARN** if designed |

Then compare your independent findings against the design's PRD Coverage Matrix. Flag discrepancies:
- Matrix says "Covered" but you found no endpoint → **FAIL** (false coverage claim)
- Matrix is missing FRs that exist in the PRD → **FAIL** (incomplete matrix)

Record: `FR-{ID}: {COVERED | PARTIAL | MISSING | SCOPE CREEP} — {endpoint or "no mapping found"}`

### 2.2 Use Case Coverage

For every UC in the PRD:
- Does the UC's main scenario have a corresponding sequence diagram or documented flow?
- Does every UC scenario step map to at least one test case?
- Does every UC failure path have a corresponding error response in the API surface?
- Do UC business rules (BR-*) map to validation rules?
- Do UC preconditions map to auth/tenant requirements?
- Do UC postconditions map to response body design?

### 2.3 Non-Functional Requirements

For every NFR in the PRD:
- Does the operational design address it (SLO, monitoring, alerting)?
- Are performance targets reflected in design decisions?

### 2.4 Personas & Authorization

For every persona in the PRD:
- Are the persona's capabilities mapped to authorization policies/gates in the design?
- Does the design's auth model support the persona's access level?

### 2.5 Non-Goals & Constraints

- Are PRD non-goals absent from the design? (Flag scope creep if designed.)
- Are PRD constraints inherited without contradiction?
- Is terminology consistent with the PRD glossary?

### 2.6 Success Metrics & Observability

- Do PRD success metrics have corresponding observability hooks in the operational design?

### 2.7 Data Model to DTO Consistency

- Does every entity field that appears in a DTO also exist in the data model?
- Does every DTO field map to a data model entity field or a computed value?
- Are field types consistent (same type in entity, DTO, and contract)?

Record all alignment findings with severity:
- **FAIL** — Must-Have FR missing, UC failure path with no error response, persona capability with no auth gate
- **WARN** — Should-Have FR partially designed, NFR without operational hook, terminology inconsistency
- **PASS** — Requirement fully covered in design

---

## Phase 3: ADR, Pattern & Architecture Compliance

### 3.1 ADR Completeness Check

The design's `### ADR Compliance` table should classify ALL ADRs from `docs/adr/`. Verify:

1. Count ADRs in `docs/adr/` directory
2. Count ADRs in the design's ADR Compliance table
3. If counts don't match → **FAIL** (incomplete ADR scan)
4. For each ADR marked "Applicable": verify the design actually follows it (not just lists it)
5. For each ADR marked "Not applicable": verify the rationale is sound
6. If the design diverges from an applicable ADR without proposing a superseding ADR → **FAIL**

### 3.2 Pattern Doc Compliance

Read ALL pattern documents in `docs/patterns/` (if the directory exists). For each pattern file:

1. Determine if the pattern applies to this design's domain
2. If applicable, verify the design follows the pattern
3. If the design deviates, check for documented rationale

Do NOT use a hardcoded list of patterns — different projects have different patterns. Read what exists in `docs/patterns/` and review against those.

Common pattern areas to look for (project-dependent):
- API/endpoint conventions
- Data access patterns (save/upsert, delete, query)
- DTO/contract conventions
- Frontend component patterns
- Testing patterns

Record: `Pattern: {name} — {FOLLOWED | DEVIATED (with rationale) | VIOLATED (no rationale)}`

- **FAIL** — Pattern violated without rationale
- **WARN** — Pattern partially followed or deviation rationale is weak
- **PASS** — Pattern followed

### 3.3 Architecture Doc Compliance

Read ALL architecture documents in `docs/architecture/`. For each:

1. Determine if the architecture constraint applies to this design
2. If applicable, verify the design respects it

Do NOT use a hardcoded list of architecture checks — different projects have different architecture docs. Read what exists and review against those.

Common architecture areas to look for (project-dependent):
- System topology and service boundaries
- Multi-tenancy model (data isolation, tenant context)
- Authorization model (policies, roles, claims)
- Data architecture (CQRS, event sourcing, shared databases)
- Security and compliance requirements

Record: `Architecture: {doc name} — {ALIGNED | MISALIGNED — {specific gap}}`

- **FAIL** — Design contradicts architecture constraint
- **WARN** — Architecture area not explicitly addressed in design
- **PASS** — Aligned

---

## Phase 5: To-Be Coherence Checklist (COMPREHENSIVE)

This phase applies adversarial depth — looking for internal contradictions and completeness gaps.

### 5.1 Feasibility Check

- Can every endpoint be implemented with the stated tech stack?
- Does the data model support every query the API surface implies?
- Are there implied joins or lookups that require indexes not documented?

### 5.2 Internal Consistency

- Do diagrams match the text? (e.g., ER diagram entities match entity definitions, sequence diagram participants match C4 containers)
- Do contracts in api-surface.md match contracts in the data model?
- Do test cases reference endpoints that actually exist in the API surface?
- Do decision records match the decisions section in design.md?

### 5.3 Security Completeness

- Does every write endpoint have an authorization policy?
- Does every tenant-scoped read go through RLS or equivalent filtering?
- Are there admin-only operations without admin auth gates?
- Does the design address OWASP Top 10 risks relevant to its domain?

### 5.4 Data Model Completeness

- Does every UI field in the mockups exist in the data model (directly or computed)?
- Does every DTO field have a source (entity field, navigation property, computed)?
- Are audit fields (CreatedAt, UpdatedAt, CreatedBy, UpdatedBy) present on tracked entities?

### 5.5 Navigation Completeness

- Is every UI mockup reachable via a documented route?
- Does the route hierarchy match the navigation structure?
- Are all navigation links in mockups accounted for in the route table?

### 5.6 Error Handling Completeness

- Does every UC failure path have a corresponding error response in the API surface?
- Does every error response have a corresponding UI error state in the mockups?
- Are protection rules (blocked operations) covered by both API error responses and UI feedback?

Record all coherence findings with severity:
- **FAIL** — Internal contradiction, security gap on write endpoint, UI field with no data source
- **WARN** — Missing index documentation, error state not mocked, audit field absent
- **PASS** — Coherent
