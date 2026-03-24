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
| **CONVERGE** | Fix all issues until 0 FAILs | STANDARD review + auto-fix loop | ~30-90 min |

**BRIEF** checks structural completeness and key PRD/ADR alignment. **STANDARD** adds cross-module consistency and full compliance. **COMPREHENSIVE** adds adversarial depth — internal coherence, feasibility, security completeness, and error handling coverage. **CONVERGE** runs a STANDARD review, then automatically fixes mechanical findings, re-reviews, and repeats until FAILs reach zero or convergence is detected.

### CONVERGE Mode

When the user says "converge", "fix all issues", "autoresearch", or selects CONVERGE mode, run the autoresearch convergence loop.

**Shared loop, classification, convergence criteria, and report formats:** [`../_shared/references/converge-mode.md`](../_shared/references/converge-mode.md)

**Severity model and finding quality standards:** [`../_shared/references/review-finding-taxonomy.md`](../_shared/references/review-finding-taxonomy.md)

**Design-review-specific CONVERGE behavior:**

- **Progressive loading waves:** Wave 1: design.md + PRD. Wave 2: feature docs referenced by Wave 1 findings. Wave 3: parallel agents for broad pattern/ADR/architecture surveys. Large authority sources may need chunked reading.
- **Decision records (decisions/*.md) are NOT in scope** for cascade fixes — historical context only. Only fix normative design files.
- **Cascade scope is the module's design directory only** — cross-module cascades noted as WARNs for manual follow-up.
- **Design-specific authority hierarchy:** `ADRs > Pattern docs > Architecture docs > PRD > api-surface.md > backend.md > ui-mockup.md > diagrams > test plans > use cases > READMEs`. Within a feature area: api-surface.md (contract) wins over backend.md (pseudocode) wins over ui-mockup.md (visual).
- **FR ID aliasing:** Check for documented alias mappings before flagging shortened FR IDs as mismatches.
- **Token budget:** COMPREHENSIVE reviews read 20-40 documents (15-25K lines). Models with <200K context may need two passes. 1M context: single-pass.

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

Verify design file structure, design.md mandatory sections, architecture.md, data-model.md, per-feature documentation, and cross-cutting diagrams against `/technical-design` v3.7 Structural Conventions. FAIL if a concern is missing entirely, WARN if content exists under a non-canonical heading. Substance over form.

**Full checklists (Steps 1.1-1.6):** [`references/design-review-checklists.md` — Phase 1](references/design-review-checklists.md#phase-1-structural-completeness)

Record all structural findings. Do not present passes to the user.

---

### Phase 2: PRD to Design Alignment

Cross-reference every PRD element against the design: FR coverage (independently verified, not trusting the design's own matrix), UC coverage, NFRs, personas/authorization, non-goals/constraints, success metrics/observability, and data-model-to-DTO consistency. This is the core compliance check.

**Full checklists (Steps 2.1-2.7):** [`references/design-review-checklists.md` — Phase 2](references/design-review-checklists.md#phase-2-prd-to-design-alignment)

Record all alignment findings with severity:
- **FAIL** — Must-Have FR missing, UC failure path with no error response, persona capability with no auth gate
- **WARN** — Should-Have FR partially designed, NFR without operational hook, terminology inconsistency
- **PASS** — Requirement fully covered in design

---

### Phase 3: ADR, Pattern & Architecture Compliance

Verify ADR completeness (all ADRs classified), pattern doc compliance (read `docs/patterns/`, not hardcoded), and architecture doc compliance (read `docs/architecture/`). Every deviation needs documented rationale.

**Full checklists (Steps 3.1-3.3):** [`references/design-review-checklists.md` — Phase 3](references/design-review-checklists.md#phase-3-adr-pattern--architecture-compliance)

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

This phase applies adversarial depth — looking for internal contradictions and completeness gaps: feasibility, internal consistency, security completeness, data model completeness, navigation completeness, and error handling completeness.

**Full checklists (Steps 5.1-5.6):** [`references/design-review-checklists.md` — Phase 5](references/design-review-checklists.md#phase-5-to-be-coherence-checklist-comprehensive)

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

*Skill Version: 2.5 — [Version History](VERSIONS.md)*
