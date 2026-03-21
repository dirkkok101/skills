---
name: review-design
description: >
  Adversarial technical design review against PRD, ADRs, patterns, and
  architecture docs. This is a DOCUMENT review (pre-implementation) — it
  validates the design blueprint before investing in planning and execution.
  Every finding cites a specific authority source (PRD requirement, ADR,
  pattern doc, or architecture constraint). Use before /plan, after
  /technical-design, when user says "review design", "check the design",
  or when design quality is uncertain.
argument-hint: "[module-name]"
---

# Review Design: Adversarial Technical Design Review

**Philosophy:** Designs are the blueprint. Review them before investing in planning and execution. A design flaw caught here costs 10 minutes to fix; the same flaw caught during implementation costs hours of rework. Every finding must cite a specific authority source — PRD requirement, ADR, pattern doc, or architecture constraint. Opinions without citations are noise. The design is a to-be specification — review it against what it SHOULD describe, not against current code.

**Duration targets:** BRIEF ~20 minutes (structural + key alignment), STANDARD ~45-90 minutes (full compliance), COMPREHENSIVE ~2-3 hours (+ adversarial depth and internal coherence).

## Why This Matters

Technical designs that skip review develop subtle misalignments — a missing FR, a contradicted ADR, an entity field that exists in the data model but not in the DTO, a UC failure path with no error response. These compound during implementation into rework, scope drift, and architectural debt. An adversarial review catches these before a single line of code is written.

---

## Trigger Conditions

Run this skill when:
- After `/technical-design` completes, before `/plan`
- User says "review design", "check the design", "validate the design"
- Design quality or completeness is uncertain
- Design has been revised and needs re-validation

Do NOT use for:
- Reviewing code (use `/review` — that is a code review skill)
- Reviewing PRD requirements (use `/review-prd` if available)
- Quick spot checks on a single design file (just read it directly)

## Stage Gates — AskUserQuestion

At every PAUSE point in this skill, **call the `AskUserQuestion` tool** to present structured options to the user. Do not present options as plain markdown text — use the tool. The YAML blocks at each PAUSE point show the exact parameters to pass.

For pattern details and examples: `../_shared/references/stage-gates.md`

> **Fallback:** Only if `AskUserQuestion` is not available as a tool (check your tool list), fall back to presenting options as markdown text and waiting for freeform response.

---

## Mode Selection

| Mode | When | Phases | Duration |
|------|------|--------|----------|
| **BRIEF** | Small design (1-2 feature areas, single design.md) | 0-1-2-3-6-7 | ~20 min |
| **STANDARD** | Typical design (3+ feature areas, decomposed docs) | 0-1-2-3-4-6-7 | ~45-90 min |
| **COMPREHENSIVE** | Large design (multi-module, 10+ UCs, critical system) | All phases 0-7 | ~2-3 hours |

**BRIEF** checks structural completeness and key PRD/ADR alignment. **STANDARD** adds cross-module consistency and full compliance. **COMPREHENSIVE** adds adversarial depth — internal coherence, feasibility, security completeness, and error handling coverage.

---

## Critical Sequence

### Phase 0: Load Context

**Step 0.1 — Load Design Documents:**

Read the module's design directory and all its contents:

- `docs/designs/{module}/design.md` — master design document
- `docs/designs/{module}/architecture.md` — C4 diagrams, system context
- `docs/designs/{module}/data-model.md` — ER diagram, entity definitions
- `docs/designs/{module}/features/` — all feature subdirectories (api-surface.md, ui-mockup.md, test-plan.md, backend.md)
- `docs/designs/{module}/decisions/` — feature-scoped decision records
- `docs/designs/{module}/diagrams/` — sequence, workflow, data flow diagrams
- `docs/designs/{module}/glossary.md` — term disambiguation (if exists)
- `docs/designs/{module}/README.md` — design index (if exists)

**Step 0.2 — Load Authority Sources:**

These are the documents the design will be reviewed against:

- **PRD** — `docs/prd/{module}/prd.md` (FRs, NFRs, personas, constraints, non-goals, success metrics)
- **Use cases** — `docs/prd/{module}/use-cases/` and `docs/use-cases/` (scenario flows, failure paths, business rules)
- **ADRs** — `docs/adr/` (read all titles, read in full any that relate to this module's domain)
- **Pattern docs** — `docs/patterns/` (API patterns, frontend patterns, DTO conventions, endpoint patterns)
- **Architecture docs** — `docs/architecture/` (multi-tenancy, authorization, CQRS, service topology)
- **Cross-cutting PRD** — `docs/prd/cross-cutting/` or equivalent (shared requirements that apply to all modules)
- **Browser E2E plans** — `docs/browser-e2e-plans/{module}.md` (if exists)
- **Brainstorm** — `docs/brainstorm/{module}/brainstorm.md` (chosen approach, kill criteria)
- **Discovery** — `docs/discovery/{module}/discovery-brief.md` (domain analysis, risk assessment)

**Step 0.3 — Establish Review Scope:**

Determine mode if not specified by the user. Count feature areas, design files, and UC depth:
- 1-2 feature areas, single design.md → BRIEF
- 3+ feature areas, decomposed docs → STANDARD
- 10+ UCs, multi-module dependencies, critical system → COMPREHENSIVE

Present scope summary:

```markdown
## Design Review Scope

**Module:** {module name}
**Mode:** {BRIEF | STANDARD | COMPREHENSIVE}
**Design files:** {count}
**Feature areas:** {list}
**Authority sources loaded:**
- PRD: {found | not found}
- Use cases: {count found}
- ADRs: {count relevant}
- Pattern docs: {count relevant}
- Architecture docs: {count relevant}
- Cross-cutting PRD: {found | not found}
```

Then use a **Decision Gate** (Pattern 1) to confirm scope:

```
AskUserQuestion:
  question: "Is this review scope correct?"
  header: "Scope"
  multiSelect: false
  options:
    - label: "Proceed (Recommended)"
      description: "Scope and mode are correct. Begin review."
    - label: "Change mode"
      description: "I want a different review depth (BRIEF / STANDARD / COMPREHENSIVE)."
    - label: "Adjust scope"
      description: "Different module or additional authority sources to load."
```

---

### Phase 1: Design Structural Completeness

Check the design against the `/technical-design` v3.7 Structural Conventions. These are non-negotiable — exact heading names, table formats, file structure, and PRD traceability.

**Note on policy/standards designs:** Designs for shared concerns (e.g., cross-cutting, error contracts) may omit `architecture.md` and `data-model.md` if they define rules rather than entities. All other structural conventions still apply.

**Step 1.1 — File Structure:**

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

**Step 1.2 — design.md Mandatory H2 Sections (in order):**

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
| `### Authentication & Authorization` | Auth policies, claims, guards | Warn if missing for auth-touching features |
| `### Audit Logging` | Event types, retention | Warn if missing for state-changing features |
| `## Operational Design` | Present as H2 | Fail if missing |
| `### Deployment Strategy` | H3 under Operational Design | Fail if missing |
| `### Failure Modes` | H3 with table: Component \| Failure Mode \| Impact \| Mitigation | Fail if missing |
| `### Observability` | H3 with Metrics, Logging, Alerting | Fail if missing |
| `## Work Decomposition` | Present as H2 | Fail if missing |
| `### Component Breakdown` | H3 with table: Component \| Scope \| Complexity \| Risk \| Implements | Fail if missing |
| `### Dependency Graph` | ASCII diagram using `──>` arrows | Fail if missing |
| `### Suggested Execution Order` | Numbered list with rationale | Fail if missing |
| `### PRD Coverage Matrix` | Table: FR ID \| Title \| Priority \| Feature Area \| API Endpoint \| Test Cases \| Status. Every Must Have = Covered. | Fail if missing or Must Have gaps |
| `### ADR Compliance` | Table: ADR \| Title \| Applicable \| How Applied. ALL ADRs in docs/adr/ must be classified. | Fail if missing |
| `## Self-Review Log` | Table format: Round \| Issues \| Key Fixes. Minimum 2 rounds (STANDARD), 3 (COMPREHENSIVE) | Fail if missing or < 2 rounds |

**Step 1.3 — architecture.md:**

| Check | Criteria | Severity |
|-------|----------|----------|
| C4 Level 1 (System Context) | ASCII diagram, 3-7 elements, connections labelled with protocol | Fail if missing |
| C4 Level 2 (Container) | ASCII diagram, technology choices noted, ports/protocols | Fail if missing |
| C4 Level 3 (Component) | Present if feature modifies internal container structure | Warn if missing when applicable |

**Step 1.4 — data-model.md:**

| Check | Criteria | Severity |
|-------|----------|----------|
| ER diagram | ASCII entity-relationship diagram | Fail if missing |
| Entity definitions | All properties typed, relationships documented, indexes noted, RLS notes for tenant-scoped | Fail if incomplete |
| Migration strategy | New/changed tables, rollback approach | Warn if missing |

**Step 1.5 — Per-Feature Documentation (per feature area):**

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
| Mockup states | 3 per screen: populated, empty, error | Warn if fewer |

**Step 1.6 — Cross-Cutting Diagrams:**

| Check | Criteria | Severity |
|-------|----------|----------|
| `diagrams/sequences.md` | One per critical flow (write, read, error recovery) | Warn if missing |
| Sequence diagram quality | 3-5 participants, request AND response, ALT blocks for errors | Warn if incomplete |
| `diagrams/workflows.md` | Present for business processes with decisions | Warn if missing when applicable |

Record all structural findings. Do not present passes to the user.

---

### Phase 2: PRD to Design Alignment

Cross-reference every PRD element against the design. This is the core compliance check.

**Step 2.1 — Functional Requirements Coverage:**

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

**Step 2.2 — Use Case Coverage:**

For every UC in the PRD:
- Does the UC's main scenario have a corresponding sequence diagram or documented flow?
- Does every UC scenario step map to at least one test case?
- Does every UC failure path have a corresponding error response in the API surface?
- Do UC business rules (BR-*) map to validation rules?
- Do UC preconditions map to auth/tenant requirements?
- Do UC postconditions map to response body design?

**Step 2.3 — Non-Functional Requirements:**

For every NFR in the PRD:
- Does the operational design address it (SLO, monitoring, alerting)?
- Are performance targets reflected in design decisions?

**Step 2.4 — Personas & Authorization:**

For every persona in the PRD:
- Are the persona's capabilities mapped to authorization policies/gates in the design?
- Does the design's auth model support the persona's access level?

**Step 2.5 — Non-Goals & Constraints:**

- Are PRD non-goals absent from the design? (Flag scope creep if designed.)
- Are PRD constraints inherited without contradiction?
- Is terminology consistent with the PRD glossary?

**Step 2.6 — Success Metrics & Observability:**

- Do PRD success metrics have corresponding observability hooks in the operational design?

**Step 2.7 — Data Model to DTO Consistency:**

- Does every entity field that appears in a DTO also exist in the data model?
- Does every DTO field map to a data model entity field or a computed value?
- Are field types consistent (same type in entity, DTO, and contract)?

Record all alignment findings with severity:
- **FAIL** — Must-Have FR missing, UC failure path with no error response, persona capability with no auth gate
- **WARN** — Should-Have FR partially designed, NFR without operational hook, terminology inconsistency
- **PASS** — Requirement fully covered in design

---

### Phase 3: ADR, Pattern & Architecture Compliance

**Step 3.1 — ADR Completeness Check:**

The design's `### ADR Compliance` table should classify ALL ADRs from `docs/adr/`. Verify:

1. Count ADRs in `docs/adr/` directory
2. Count ADRs in the design's ADR Compliance table
3. If counts don't match → **FAIL** (incomplete ADR scan)
4. For each ADR marked "Applicable": verify the design actually follows it (not just lists it)
5. For each ADR marked "Not applicable": verify the rationale is sound
6. If the design diverges from an applicable ADR without proposing a superseding ADR → **FAIL**

**Step 3.2 — Pattern Doc Compliance:**

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

**Step 3.3 — Architecture Doc Compliance:**

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

Record all compliance findings with severity as above.

---

### Phase 4: Cross-Module Consistency (STANDARD+)

**Step 4.1 — Dependency Symmetry:**

If the design references other modules (e.g., "depends on Users module", "consumes Applications API"):
- Does the referenced module's design acknowledge the dependency?
- Are interfaces described consistently on both sides?

**Step 4.2 — Shared Entity Consistency:**

If the design references entities owned by other modules:
- Are field names, types, and constraints consistent?
- Are FK relationships correctly described from both sides?

**Step 4.3 — Cross-Cutting FR Alignment:**

If a cross-cutting PRD exists:
- Does the design address all cross-cutting FRs that apply to this module?
- Are shared patterns (pagination, error responses, audit logging) consistent?

**Step 4.4 — Route Conventions:**

- Do API routes follow the project's established conventions?
- Are route prefixes consistent with other modules?
- Do route parameter names match conventions?

Record all cross-module findings with severity:
- **FAIL** — Dependency not acknowledged, entity definition contradicts another module
- **WARN** — Route convention deviation, cross-cutting FR not explicitly addressed
- **PASS** — Consistent

---

### Phase 5: To-Be Coherence (COMPREHENSIVE)

This phase applies adversarial depth — looking for internal contradictions and completeness gaps that the design author may have missed.

**Step 5.1 — Feasibility Check:**

- Can every endpoint be implemented with the stated tech stack?
- Does the data model support every query the API surface implies?
- Are there implied joins or lookups that require indexes not documented?

**Step 5.2 — Internal Consistency:**

- Do diagrams match the text? (e.g., ER diagram entities match entity definitions, sequence diagram participants match C4 containers)
- Do contracts in api-surface.md match contracts in the data model?
- Do test cases reference endpoints that actually exist in the API surface?
- Do decision records match the decisions section in design.md?

**Step 5.3 — Security Completeness:**

- Does every write endpoint have an authorization policy?
- Does every tenant-scoped read go through RLS or equivalent filtering?
- Are there admin-only operations without admin auth gates?
- Does the design address OWASP Top 10 risks relevant to its domain?

**Step 5.4 — Data Model Completeness:**

- Does every UI field in the mockups exist in the data model (directly or computed)?
- Does every DTO field have a source (entity field, navigation property, computed)?
- Are audit fields (CreatedAt, UpdatedAt, CreatedBy, UpdatedBy) present on tracked entities?

**Step 5.5 — Navigation Completeness:**

- Is every UI mockup reachable via a documented route?
- Does the route hierarchy match the navigation structure?
- Are all navigation links in mockups accounted for in the route table?

**Step 5.6 — Error Handling Completeness:**

- Does every UC failure path have a corresponding error response in the API surface?
- Does every error response have a corresponding UI error state in the mockups?
- Are protection rules (blocked operations) covered by both API error responses and UI feedback?

Record all coherence findings with severity:
- **FAIL** — Internal contradiction, security gap on write endpoint, UI field with no data source
- **WARN** — Missing index documentation, error state not mocked, audit field absent
- **PASS** — Coherent

---

### Phase 6: Present Findings

Present findings interactively using the **Guided Review** (Pattern 5) pattern. Walk the user through findings one at a time, starting with FAILs, then WARNs. Skip PASSes.

**Step 6.1 — Summary Overview:**

Present a summary before walking through individual findings:

```markdown
## Design Review Findings

**Module:** {module name}
**Mode:** {BRIEF | STANDARD | COMPREHENSIVE}
**Phases Completed:** {list}

| Severity | Count |
|----------|-------|
| FAIL | {count} |
| WARN | {count} |
| PASS | {count} |

### FAIL Findings Preview
| # | Phase | Finding | Authority |
|---|-------|---------|-----------|
| 1 | {phase} | {short description} | {PRD FR-xxx / ADR-NNNN / pattern doc / architecture doc} |
| 2 | {phase} | {short description} | {authority source} |
```

**Step 6.2 — Walk Through FAIL Findings:**

For each FAIL finding, present full detail as formatted markdown, then ask for the user's decision:

```markdown
### FAIL {N}: {Short Title}

**Phase:** {which review phase found this}
**Authority:** {exact document and section that this finding is based on}

**The design says:** {quote or reference from the design}
**The authority says:** {quote or reference from the PRD/ADR/pattern/architecture doc}
**Gap:** {specific description of the misalignment}
**Recommendation:** {how to fix the design}
```

```
AskUserQuestion:
  question: "How should we handle this finding?"
  header: "FAIL {N}"
  multiSelect: false
  options:
    - label: "Accept finding"
      description: "Design needs to be updated to address this gap."
    - label: "Dispute"
      description: "Finding is incorrect or authority is misinterpreted. I'll explain."
    - label: "Defer"
      description: "Known gap, acceptable for now. Will be tracked as a follow-up."
    - label: "Out of scope"
      description: "This is outside the design's intended scope."
```

**Step 6.3 — Walk Through WARN Findings:**

Present WARN findings in batches of up to 4 using **Batch Review** (Pattern 3):

Present the batch as formatted markdown with full detail, then:

```
AskUserQuestion:
  question: "Which warnings need to be addressed? (Unselected items are accepted as-is)"
  header: "Warnings"
  multiSelect: true
  options:
    - label: "WARN {N}: {short title}"
      description: "{authority source} — {one-line gap description}"
    - label: "WARN {N}: {short title}"
      description: "{authority source} — {one-line gap description}"
    ...up to 4 per batch
```

Repeat for additional batches if more than 4 WARN findings exist.

---

### Phase 7: Summary & Decisions Log

**Step 7.1 — Summary Statistics:**

```markdown
## Design Review Summary

**Module:** {module name}
**Mode:** {BRIEF | STANDARD | COMPREHENSIVE}
**Date:** {date}

### Statistics
| Category | Count |
|----------|-------|
| Total findings | {count} |
| FAIL | {count} |
| WARN | {count} |
| PASS | {count} |

### Phase Coverage
| Phase | Findings | Status |
|-------|----------|--------|
| 1. Structural Completeness | {count} | {FAIL count / WARN count} |
| 2. PRD Alignment | {count} | {FAIL count / WARN count} |
| 3. ADR & Pattern Compliance | {count} | {FAIL count / WARN count} |
| 4. Cross-Module Consistency | {count or "skipped"} | {status} |
| 5. To-Be Coherence | {count or "skipped"} | {status} |
```

**Step 7.2 — Decisions Log:**

Record every finding disposition from Phase 6:

```markdown
### Decisions Log

| # | Finding | Severity | Disposition | Notes |
|---|---------|----------|-------------|-------|
| 1 | {finding} | FAIL | Accepted | {will update design} |
| 2 | {finding} | FAIL | Disputed | {user's rationale} |
| 3 | {finding} | WARN | Deferred | {tracking as follow-up} |
| 4 | {finding} | WARN | Accepted as-is | — |
```

**Step 7.3 — Deferred Items:**

List all findings with "Defer" disposition. If the project uses an issue tracker, offer to create tracked items:

"These deferred items need resolution before or during implementation. Want me to create tracked issues for them?"

**Step 7.4 — Exit Decision:**

```
AskUserQuestion:
  question: "Design review complete. What next?"
  header: "Next step"
  multiSelect: false
  options:
    - label: "Update design (Recommended)"
      description: "Fix accepted findings in the design docs, then proceed to /plan."
    - label: "Proceed to /plan as-is"
      description: "Accepted findings are minor enough to address during planning."
    - label: "Re-review after updates"
      description: "I'll update the design myself, then run /review-design again."
    - label: "Park"
      description: "Save findings for later. Design review can be resumed."
```

When the user selects "Update design": implement the accepted finding fixes in the design documents, then confirm: "Design updated. Run /plan to create implementation plan."

When the user selects "Proceed to /plan as-is": "Review complete. Run /plan to create implementation plan. Note: {N} accepted findings should be addressed during planning."

---

## Important Rules

1. **READ-ONLY by default** — Do not modify design documents during review. Only modify if the user explicitly approves finding fixes in Phase 7.
2. **Every finding cites an authority source** — No finding without a specific PRD requirement, ADR, pattern doc, or architecture doc reference. Opinions without citations are not findings.
3. **Pattern docs are to-be specifications** — They describe the ideal state, not necessarily current code. Review the design against the patterns as written.
4. **ADRs are constraints** — Prior ADRs constrain the design. Divergence requires an explicit superseding proposal. Superseded ADRs must not be referenced as active.
5. **Do not read source code** — This is a document review. The design should stand on its own against the PRD and project knowledge. Reading source code introduces implementation anchoring.
6. **Proportional depth** — BRIEF mode should not produce 50+ findings. Focus on structural gaps and critical alignment issues. Save exhaustive cross-referencing for STANDARD and COMPREHENSIVE.
7. **Design, not implementation** — Review what the design describes, not how it would be implemented. Implementation concerns belong in `/review` (code review).

---

## Anti-Patterns

**Rubber Stamp Review** — Skimming the design and reporting "looks good" without systematic cross-referencing. Every phase exists because real design flaws hide in specific places. A review that doesn't find at least a few WARNs on a non-trivial design probably wasn't thorough enough.

**Opinion-as-Finding** — Reporting "I would have designed it differently" without citing a specific authority source. Preferences are not findings. Every FAIL or WARN must point to a PRD requirement, ADR, pattern doc, or architecture constraint that the design contradicts or fails to address.

**Scope Creep into Code Review** — Evaluating implementation quality, code style, or naming conventions in the source code. This is a document review. The `/review` skill handles code. If the design references implementation details that seem wrong, the finding is about the design document, not the code.

**Design-as-Code Review** — Checking whether the design's pseudocode would compile, whether its TypeScript interfaces have correct syntax, or whether its SQL would execute. Design pseudocode expresses algorithmic intent, not compilable code. Review the logic and completeness, not the syntax.

**Exhaustive BRIEF** — Running a COMPREHENSIVE-depth review when BRIEF was selected. BRIEF mode exists for quick structural validation. If the user wants full compliance checking, they should select STANDARD or COMPREHENSIVE.

**Missing Authority Citation** — Reporting a finding as "the design should have X" without specifying which PRD requirement, ADR, or pattern doc mandates X. Without a citation, the finding is an opinion and should be dropped or downgraded to an observation.

**Reviewing Current Code Instead of Design** — Reading the codebase to check if the design matches implementation. The design is a to-be specification. Current code may be wrong, incomplete, or legacy. The design should be reviewed against what it should describe (per PRD, patterns, ADRs), not against what currently exists.

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "update design" | Fix accepted findings | Implement fixes, then proceed to /plan |
| "proceed to /plan" | Review complete, minor findings | /plan with noted caveats |
| "re-review" | User will update, then re-run | User updates, then /review-design again |
| "park" | Save for later | Archive findings for future session |

When approved: **"Design review complete. Run /plan to create implementation plan."**

---

*Skill Version: 2.2*
*v2.2: Feature area to PRD Epic alignment check added. Phase 2 FR coverage independently verified (don't trust the design's own matrix). Phase 3 rewritten — ADR, pattern, and architecture checks are now generic (read from docs/adr/, docs/patterns/, docs/architecture/) instead of hardcoded to a specific project's conventions. This makes the review skill portable across projects.*

*v2.1: Synced with /technical-design v3.7. PRD Coverage Matrix check added (every Must Have FR must map to endpoint + tests). ADR Compliance table check added (all ADRs classified). Endpoint table check updated to 5 columns (Verb, Route, Purpose, Maps To, Auth Policy).*

*v2.0: Phase 1 fully synced with /technical-design v3.6 Structural Conventions. Now checks exact file structure (mandatory files, feature decomposition), design.md H2 section order, Documentation Foundation sub-headings, assumption table format (4-column, never bullets), two-layer decision pattern (summary table + decision files), operational design sub-headings, work decomposition format (component breakdown table + dependency graph + execution order), self-review table format with round count enforcement, architecture.md C4 level requirements, data-model.md completeness, per-feature doc structure and test plan quality. Policy/standards design exception documented. All checks specify exact severity (Fail vs Warn).*
