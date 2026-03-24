---
name: review-plan
description: >
  Adversarial plan review against six authority sources: the /plan skill
  specification, technical design, gap analysis, PRD, architecture/patterns/ADRs,
  and the plan's own internal consistency. Catches design drift, phantom scope,
  structural non-compliance, and traceability gaps before /beads produces wrong
  code. Use when a plan is complete (/plan finished), user says "review the plan",
  "check the plan", or before running /beads on a new plan.
argument-hint: "[feature-name] or path to plan directory"
---

# Review-Plan: Adversarial Plan Review

**Philosophy:** A plan is the last line of defence before /beads generates executable work packages. Every claim in a plan — "FR-X is covered by T03", "this mirrors the design's feature decomposition", "dependencies form no cycles" — must be verified against the authority source, not taken at face value. The plan author (human or agent) has blind spots; this skill's job is to find them. Depth over breadth: two Critical design contradictions matter more than twenty Minor formatting issues.

**Duration targets:** BRIEF ~10-15 minutes (single overview file, fewer authority sources), STANDARD ~20-40 minutes (overview + sub-plans, full authority chain), COMPREHENSIVE ~40-90 minutes (full authority chain + companion docs + deep cross-reference). Most time should be spent on Phases 2 and 4 (design fidelity and PRD traceability) — these catch the errors that make /beads produce wrong code.

## Why This Matters

Plans that pass a cursory review but contradict the design produce beads that implement the wrong thing. A plan that claims FR coverage but maps FRs to tasks that don't actually address them creates false confidence. Phantom scope — tasks that appear in the plan but have no basis in any authority source — wastes execution time and pollutes the codebase. This skill exists because real-world plan reviews have caught: design decisions silently reversed, endpoints with wrong HTTP verbs, entity columns missing from data model tasks, Must-Have FRs mapped to tasks that only partially address them, and companion docs that contradict the design's test plan.

---

## Trigger Conditions

Run this skill when:
- Plan is complete (`/plan` finished, all sub-plans written)
- User says "review the plan", "check the plan", "audit the plan"
- Before running `/beads` on a plan
- After significant plan modifications

Do NOT use for:
- Reviewing code implementation (use `/review`)
- Reviewing the design itself (use `/review-design`)
- Reviewing the PRD (use `/review-prd`)

## Stage Gates — AskUserQuestion

At every PAUSE point in this skill, **call the `AskUserQuestion` tool** to present structured options to the user. Do not present options as plain markdown text — use the tool. The YAML blocks at each PAUSE point show the exact parameters to pass.

For pattern details and examples: `../_shared/references/stage-gates.md`

> **Fallback:** Only if `AskUserQuestion` is not available as a tool (check your tool list), fall back to presenting options as markdown text and waiting for freeform response.

---

## Mode Selection

| Mode | When | Depth | Output |
|------|------|-------|--------|
| **BRIEF** | Single overview file, simple feature | Structural + design fidelity + PRD coverage | Inline findings summary |
| **STANDARD** | Overview + sub-plans, typical feature | All 7 phases | Full review report |
| **COMPREHENSIVE** | Large feature with companion docs | All 7 phases + companion doc audit + cross-reference deep dive | Full review report + alignment findings |
| **CONVERGE** | Fix all issues until 0 Critical/Major | Selected depth + auto-fix loop | Converged plan + report |

### CONVERGE Mode

When the user says "converge", "fix all issues", "autoresearch", or selects CONVERGE mode, run the autoresearch convergence loop.

**Shared loop, classification, convergence criteria, same-session detection, and report formats:** [`../_shared/references/converge-mode.md`](../_shared/references/converge-mode.md)

**Severity model and finding quality standards:** [`../_shared/references/review-finding-taxonomy.md`](../_shared/references/review-finding-taxonomy.md)

**Plan-review-specific CONVERGE behavior:**

- **Progressive loading waves:** Wave 1: overview.md + design.md + PRD. Wave 2: sub-plans + feature api-surfaces. Wave 3: agents for broad ADR/pattern/architecture surveys.
- **MECHANICAL findings are auto-fixed regardless of severity** — count errors, stale numbers, missing table rows, and arithmetic mismatches are all MECHANICAL whether in overview (FAIL) or companion doc (WARN).
- **Trivial WARN auto-fix heuristic:** If additive-only, no semantic changes, and under 10 lines, auto-fix without escalation. Non-trivial WARNs escalated after FAILs reach 0.
- **Plan-specific authority hierarchy:** `Technical design (api-surface, data-model) > PRD (FRs, UCs, ACs) > ADRs > Pattern docs > Architecture docs > Plan overview > Sub-plans`
- **Cascade scope is the plan directory only** — cross-module cascades noted as observations.
- **Phase ordering for CONVERGE:** Consider running Phase 6 (internal consistency / arithmetic) immediately after Phase 0 — arithmetic errors are the cheapest fixes and most common MECHANICAL findings.
- **Verification Mode phase collapsing:** For plans where >90% exists and the gap analysis IS the plan, Phases 2 and 3 collapse into a single check: "does the gap analysis correctly identify what needs to change?"
- **Test counts single source of truth:** The test-scenario-matrix is authoritative. Overview and sub-plans should reference it instead of stating counts that drift.

**Agent usage guidelines:**

- **Non-greenfield agent prompts:** Include: "This is a non-greenfield plan", "verification coverage is not a gap", "authority source discrepancies are observations not findings", "framework concerns are inherently compliant", "verification tasks don't need to describe HOW — that's /beads territory."
- **Agent context:** Provide both plan files AND current gap analysis to prevent confusing old and new analyses.
- **Agent finding classification:** Instruct agents to classify each finding with reasoning. Reviewer validates — agents sometimes misclassify DECISION as MECHANICAL.
- **Agent sub-plan reading:** Agents must read full sub-plan body before flagging FR coverage as incomplete.
- **Agent false positive rate:** Expect 30-40%. For plans with ≤3 sub-plans, skip agents — direct reads are more efficient.
- **Agent finding triage table:** Include `## Agent Finding Triage` with disposition column (Accepted / False Positive / Reclassified).

**Same-session plan reviews:**

Same-session reviews have reduced independence (see shared converge-mode.md for confidence levels). Additional plan-specific mitigations:
- Phase 2 confidence is LOW — reviewer shares generating agent's blind spots. Use deliberately adversarial agent prompts.
- Phase 1 should use explicit Read calls per section (not mental checklist from memory).
- Increase spot-checks to 5 minimum. Target gap analysis claims: test infrastructure existence, file content verification, "Modify" element accuracy.
- **Codebase spot-check:** A 30-second Grep to verify key gap analysis claims significantly increases confidence (Phase 3).

**Companion doc depth:** Scale by plan complexity. For ≤3 sub-plans, structural check suffices. For >3, cross-reference against design test plans and security analysis.

**Token budget:** For 10+ sub-plans, expect 30-50 documents. Models with <200K context may need two-pass approach.

---

## Authority Sources

These are the six sources against which every plan claim is verified. Load them on-demand per phase, not all upfront — this prevents context bloat.

| # | Authority Source | What It Governs | Used In |
|---|-----------------|-----------------|---------|
| 1 | `/plan` skill specification | Plan structure, section requirements, anti-patterns, plan/beads boundary | Phase 1 |
| 2 | Technical design (`docs/designs/{feature}/`) | Feature decomposition, API surface, data model, design decisions, test plans | Phase 2 |
| 3 | Gap analysis (`docs/designs/{feature}/gap-analysis.md` or similar) | Gap classifications, scope decisions, migration ordering | Phase 3 |
| 4 | PRD (`docs/prd/{feature}/prd.md`) | Must-Have FRs, acceptance criteria, use cases, cross-cutting requirements | Phase 4 |
| 5 | Architecture, patterns, ADRs (`docs/architecture/`, `docs/patterns/`, `docs/adr/`) | Binding constraints, conventions, superseded decisions | Phase 5 |
| 6 | The plan itself | Internal consistency across overview, sub-plans, companion docs | Phase 6 |

---

## Critical Sequence

### Phase 0: Load Plan & Establish Baseline

**Step 0.1 — Read All Plan Files:**

Read the complete plan:
- Overview: `docs/plans/{feature}/overview.md`
- All sub-plan files: `docs/plans/{feature}/*.md` (excluding overview and companion docs)
- Companion docs (if present): `e2e-test-plan.md`, `security-hardening-checklist.md`, `test-scenario-matrix.md`

**Step 0.2 — Detect Plan Mode:**

Determine the plan mode from structure:
- **BRIEF:** Single `overview.md` with inline tasks, no sub-plan files
- **STANDARD:** `overview.md` + numbered sub-plan files
- **COMPREHENSIVE:** STANDARD + companion documents (e2e-test-plan, security-hardening, test-scenario-matrix)

Record the mode. Enforce project-level requirements — if the project CLAUDE.md or PRD specifies a required plan mode, flag a mismatch.

**Step 0.3 — Check Gap Analysis Existence:**

Look for a gap analysis document:
- `docs/designs/{feature}/gap-analysis.md`
- `docs/designs/{feature}/gap-analysis/`
- `docs/gap-analysis/{feature}/`

Record whether one exists. Phase 3 is skipped if no gap analysis is found.

**Step 0.4 — Read the /plan Skill Spec:**

Read the `/plan` skill specification (this skill's sibling: `../plan/SKILL.md`). This is the structural authority for Phase 1. Extract:
- Required sections for overview documents
- Required sections for sub-plan documents
- Companion document requirements per mode
- Anti-pattern definitions
- Plan/beads boundary rules

---

### Phase 1: Structural Compliance (vs /plan skill spec)

**Load:** `/plan` SKILL.md (already loaded in Phase 0.4).

Verify overview document structure (required sections per mode), sub-plan document structure (required/conditional/mandatory sections), companion document compliance (COMPREHENSIVE), anti-pattern detection, and plan/beads boundary violations.

**Full checklists (Steps 1.1-1.5):** [`references/plan-review-checklists.md`](references/plan-review-checklists.md)

---

### Phase 2: Design Fidelity (vs technical design) — HIGHEST PRIORITY

**Load:** Technical design documents from `docs/designs/{feature}/`. Read `design.md` and all feature subdirectories (`features/*/`). This phase is the most important — design contradictions in the plan produce wrong code.

**Step 2.1 — Feature Decomposition Alignment:**

Map the design's feature areas to plan sub-plans:

```markdown
| Design Feature Area | Plan Sub-Plan | Aligned? |
|--------------------|--------------|---------:|
| features/applications/ | 02-application-feature.md | Yes/No |
| features/role-templates/ | 04-role-template-feature.md | Yes/No |
```

Flag unmapped design features as **FAIL** (work that won't get done).
Flag plan sub-plans with no design counterpart as **FAIL** (phantom scope).

**Step 2.2 — API Surface & Contract Verification:**

For each endpoint in the design's API surface (typically `api-surface.md` or similar):
- Verify a plan task covers it
- Verify route, HTTP verb, request/response shapes in the plan match the design
- Flag mismatches (wrong verb, missing fields, different route) as **FAIL**
- Flag missing endpoint coverage as **FAIL**

**Step 2.3 — Data Model Verification:**

Compare the design's data model (entities, columns, constraints, FK behaviours, indexes) against plan tasks:
- Every entity in the design should have creation coverage in a plan task
- Column names, types, and constraints should match
- FK cascade/restrict behaviours should match
- Flag mismatches as **FAIL** (wrong schema = wrong code)

**Step 2.4 — Design Decision Preservation:**

For each design decision (chosen approach, rejected alternatives, trade-offs):
- Verify the plan doesn't contradict it
- Verify the plan doesn't introduce new architectural decisions not in the design
- Flag contradictions as **FAIL**
- Flag new decisions as **WARN** (should be pushed back to design)

**Step 2.5 — Test Plan Alignment:**

Compare the design's per-feature test plans against the plan's Testing Summary and sub-plan success criteria:
- Are test categories from the design reflected in plan tasks?
- Do sub-plan success criteria cover the design's test expectations?
- Flag gaps as **WARN**

**Step 2.6 — Companion Doc Fidelity (COMPREHENSIVE):**

If companion docs exist, verify them against the design:
- E2E test plan scenarios should align with the design's integration/E2E expectations
- Security hardening items should trace to the design's security analysis
- Test scenario matrix should reflect the design's per-feature test plans
- Flag contradictions as **WARN**

**Early Termination:** If Phase 2 produces 5 or more Critical findings, STOP. Present findings to the user immediately — there is no value in continuing deeper review when the plan fundamentally misrepresents the design. Use the PAUSE described in Phase 7.

---

### Phase 3: Gap Analysis Fidelity

**Skip this phase if no gap analysis document was found in Phase 0.3.** However, check whether the plan's overview embeds a gap analysis (e.g., an Implementation Status table with New/Modify/Exists classifications). If embedded, treat the Implementation Status table as the gap analysis authority source and run Steps 3.1-3.2 against it.

**Load:** Gap analysis document (standalone or embedded in overview).

**Step 3.1 — Gap Coverage:**

For every gap classified in the gap analysis:
- If classified as "include" / "address" / "in scope" → verify at least one plan task covers it
- If classified as "defer" / "out of scope" / "future" → verify NO plan task implements it
- Flag included gaps with no task coverage as **FAIL**
- Flag deferred gaps that appear in plan tasks as **WARN** (scope creep)

**Step 3.2 — Scope Decision Respect:**

Verify the plan respects all scope decisions from the gap analysis:
- Items explicitly excluded should not appear
- Items explicitly included should appear
- Migration ordering recommendations should be reflected in task sequencing

Flag violations as **WARN**.

---

### Phase 4: PRD Traceability — HIGHEST PRIORITY

**Load:** PRD from `docs/prd/{feature}/prd.md`. Also load use cases from `docs/prd/{feature}/use-cases/` and `docs/use-cases/` if they exist.

**Step 4.1 — Must-Have FR Coverage (Depth Check):**

For every Must-Have FR in the PRD:
1. Find the plan task(s) that claim to implement it (from FR Coverage table)
2. Read the actual sub-plan body for those tasks
3. Verify the task **actually addresses** the FR — not just mentions it

This is the adversarial step. A plan that maps FR-WIDGET-DELETE to a task titled "Widget CRUD" but whose sub-plan body only covers create and edit has a false coverage claim. The FR Coverage table says "covered" but the implementation won't deliver it.

Flag Must-Have FRs with no task coverage as **FAIL**.
Flag Must-Have FRs with false/shallow coverage as **FAIL**.

**Step 4.2 — Self-Review Claim Verification:**

If the plan contains its own FR coverage claims (most plans do, per the /plan skill spec), adversarially verify each claim:
- Read the FR Coverage table
- For each "Covered" claim, trace to the sub-plan and verify the task body addresses the FR
- For each "Gap" acknowledgment, verify it's genuinely a gap and not something covered elsewhere

Flag false "Covered" claims as **FAIL**.

**Step 4.3 — Use Case Coverage:**

Verify the plan includes a UC Coverage table (new in /plan v3.6). For each use case:
- Verify the plan's task sequence can execute the use case end-to-end
- For Tier 1 UCs: verify every scenario step has a covering task, every failure path has a covering task, every BR-* maps to a validation task
- Identify any use case steps that fall between tasks (gaps in the vertical slice)

Flag missing UC Coverage table as **WARN**.
Flag use cases with broken execution paths as **WARN**.
Flag Tier 1 UC failure paths with no covering task as **FAIL**.

**Step 4.4 — Design Coverage Matrix:**

Verify the plan includes a Design Coverage table (new in /plan v3.6). Cross-reference against the design's api-surface files:
- Every endpoint in the design has a covering task
- Every entity in the data model has a covering task
- Every command/query in the design has a covering task
- Every contract (DTO, Request, Response) has a covering task

Flag missing Design Coverage table as **WARN**.
Flag design elements with no covering task as **FAIL** (work that won't get done).

**Step 4.4 — Cross-Cutting PRD Compliance:**

Check whether the plan addresses PRD cross-cutting requirements:
- **Audit logging** — if the PRD requires audit trails, verify plan tasks include audit coverage
- **Data lifecycle** — if the PRD specifies retention, archival, or deletion requirements, verify task coverage
- **Error handling** — if the PRD specifies error UX or recovery requirements, verify task coverage
- **Pagination** — if the PRD specifies list/grid requirements, verify plan tasks include pagination

Flag missing cross-cutting coverage as **WARN**.

---

### Phase 5: Architecture & Pattern Compliance

**Load on-demand:** Only load the specific authority sources relevant to this plan. Do not read all ADRs and pattern docs upfront.

**Step 5.1 — ADR Compliance:**

Scope relevant ADRs:
1. Read `docs/adr/README.md` (or list `docs/adr/`) to identify ADR titles
2. Select ADRs relevant to the plan's domain (e.g., if the plan involves DTOs, check the DTO ADR; if it involves save patterns, check the save pattern ADR)
3. Read each selected ADR
4. Verify the plan doesn't contradict active ADRs
5. **Respect superseded ADRs** — if an ADR is marked superseded, the superseding decision takes precedence. Do not flag plan content that follows the superseding decision.

Flag ADR violations as **WARN**.

**Step 5.2 — Pattern Compliance:**

Check the plan against established patterns from `docs/patterns/`:
- Vertical slice pattern (endpoints, commands, queries in correct locations)
- Contract placement (DTOs in Contracts project)
- DTO conventions (naming, class vs record, inheritance)
- Save pattern (upsert, not separate create/update — unless design explicitly deviates)
- Delete pattern (ExecuteDeleteAsync, not load-and-delete)
- Other project-specific patterns from CLAUDE.md

Flag pattern violations as **WARN** (they'll cause rework during /execute).

**Step 5.3 — Architecture Compliance:**

Check the plan against architecture documents from `docs/architecture/`:
- Multi-tenancy model (RLS, tenant scoping)
- Authorization model (permission checks, role enforcement)
- CQRS boundaries (commands vs queries, no mixing)

Flag architecture violations as **FAIL**.

---

### Phase 6: Internal Consistency

**Load:** Only the plan files (already loaded from Phase 0).

**Step 6.1 — Overview to Sub-Plan Consistency:**

- Task Summary table entries match actual sub-plan files (count, titles, phases)
- FR Coverage table matches sub-plan Traceability sections
- Complexity ratings in overview match sub-plan scope
- Sub-Plans table file names match actual files on disk

Flag inconsistencies as **WARN**.

**Step 6.2 — Cross-Sub-Plan Consistency:**

- No two sub-plans claim to implement the same thing differently
- Shared entities/DTOs referenced consistently across sub-plans
- Naming is consistent (same entity isn't called "Widget" in one sub-plan and "Component" in another)

Flag inconsistencies as **Minor** (confusing but not blocking).

**Step 6.3 — Dependency Integrity:**

- No circular dependencies in the dependency graph
- All "Depends on" references point to valid task IDs
- All "Blocks" references are reciprocal
- Critical path is actually the longest chain
- Parallelisable tasks have no hidden dependencies

Flag circular dependencies as **FAIL**.
Flag invalid references as **WARN**.
Flag incorrect critical path in the overview (Task Summary / Dependency Graph) as **FAIL** — it directly affects /beads execution ordering. Flag incorrect critical path in prose descriptions as **WARN**.

**Phase 6 requires direct file reads.** Do NOT rely on agent summaries for internal consistency checks — dependency graphs, critical path text, and table cross-references need exact text. Read overview.md directly via the Read tool, not via agent summaries.

**Critical path verification algorithm:** For each task, trace the longest dependency chain ending at it. The critical path is the longest chain ending at the final task. Compare against the plan's stated critical path. This makes the check mechanical rather than relying on mental graph traversal.

**Step 6.4 — Naming Consistency:**

- Entity names consistent across overview, sub-plans, and companion docs
- FR IDs consistent between FR Coverage table and sub-plan Traceability sections
- Task IDs consistent across all documents

Flag naming inconsistencies as **Minor**.

---

### Phase 7: Synthesize Findings

**Step 7.1 — Classify Findings:**

Apply the shared severity model (FAIL / WARN). Minor and observational issues are reported inline as notes, not formal findings.

**Severity model and finding quality standards:** [`../_shared/references/review-finding-taxonomy.md`](../_shared/references/review-finding-taxonomy.md)

**Step 7.2 — Determine Verdict:**

| Verdict | Criteria |
|---------|----------|
| **PASS (CLEAN)** | 0 FAILs on first review — plan needed no fixes |
| **PASS (CONVERGED)** | 0 FAILs after CONVERGE rounds — plan was fixed to compliance |
| **PASS WITH CONDITIONS** | 0 FAILs, WARNs noted as conditions for /beads |
| **FAIL** | Any FAIL findings remaining after max rounds |

**Step 7.3 — Write Review Report:**

Save to: `${PROJECT_ROOT}/docs/reviews/review-plan-{feature}-{date}.md`

Report structure: Executive Summary (verdict, finding counts, 2-3 sentence health summary), Authority Source Compliance table (6 authority sources with FAIL/WARN/Minor counts), Critical Findings (each with Phase, Authority, Plan Location, Issue, Impact, Resolution), Major Findings (same format), Minor Findings (one-line each), Observations (one-line each).

Each finding must cite the specific authority source, plan location, and concrete resolution per the finding quality standards in the shared taxonomy.

**PAUSE:** Present the review summary and verdict, then use a Decision Gate:

```
AskUserQuestion:
  question: "How should we proceed with the plan review findings?"
  header: "Verdict"
  multiSelect: false
  options:
    - label: "Fix and re-review"
      description: "Address Critical/Major findings, then run /review-plan again."
    - label: "Fix Critical only"
      description: "Address only Critical findings. Accept Major findings as conditions for /beads."
    - label: "Accepted as-is"
      description: "Proceed to /beads without changes. Findings noted but not blocking."
    - label: "Escalate to design"
      description: "Findings indicate design-level issues. Return to /technical-design."
```

---

## Execution Priority

Phases 2 and 4 run first (design fidelity and PRD traceability). These catch the errors that produce wrong code during /beads.

**Recommended execution order:**
1. Phase 0 (load baseline — required for all others)
2. Phase 2 (design fidelity — HIGHEST PRIORITY)
3. Phase 4 (PRD traceability — HIGHEST PRIORITY)
4. Phase 1 (structural compliance)
5. Phase 3 (gap analysis fidelity — skip if no gap analysis)
6. Phase 5 (architecture & pattern compliance)
7. Phase 6 (internal consistency)
8. Phase 7 (synthesize — always last)

**Early termination:** If Phase 2 produces 5+ Critical findings, stop after Phase 2. Present findings immediately — continuing deeper review when the plan fundamentally misrepresents the design wastes time and produces noise that obscures the real problems.

---

## Interaction Model

**AskUserQuestion for ambiguous findings:** When a Critical or Major finding has multiple valid resolutions, use AskUserQuestion to let the user choose. Example: "The plan covers FR-WIDGET-DELETE in T03 but the sub-plan body only mentions soft-delete, while the design specifies hard-delete. Should we: (a) update the plan to hard-delete per design, (b) flag as a design change request, (c) accept soft-delete as an intentional deviation?"

**Record directly for unambiguous findings:** When the authority source clearly contradicts the plan and there's only one valid resolution, record the finding without asking. Example: "The plan's FR Coverage table claims FR-WIDGET-LIST is covered by T02, but T02's sub-plan body only covers widget creation. This is a false coverage claim."

**Batch related decisions:** When multiple findings have the same resolution pattern (e.g., several sub-plans are missing Failure Criteria sections), present them as a batch rather than asking individually.

---

## Anti-Patterns

**Structural Rigidity** — Flagging missing exact headings when the content is present under a different name. FAIL if the concern is missing entirely, WARN if addressed under a non-canonical heading. Substance over form — a sub-plan that covers failure criteria in prose is better than one with a perfect "Failure Criteria" heading and no content.

**Rubber Stamp** — Declaring PASS without reading authority sources. Every verdict must be earned by tracing claims to documents. If you haven't read the design's API surface, you cannot declare API coverage is correct. The skill exists because plans look plausible on the surface — verification requires reading the authority sources.

**Template-Only Review** — Checking that sections exist without reading their content. A plan can have every required section but contain nonsense in each one. Structural compliance (Phase 1) is necessary but not sufficient — content verification (Phases 2-6) is where real issues are found.

**Surface-Level Coverage** — Claiming an FR is covered because the FR Coverage table says so, without reading the sub-plan body to verify the task actually addresses the FR. The adversarial stance means verifying the claim, not trusting it. This is the single most common review failure — it's easier to check a table than to read sub-plan bodies.

**Inventing Requirements** — Flagging the plan for not addressing requirements that don't exist in any authority source. If the PRD doesn't mention audit logging, don't flag the plan for missing audit coverage. Review against what the authority sources say, not what you think they should say. The exception is architecture-level constraints (RLS, authorization) that apply to all features regardless of PRD mention.

**Reviewing Unchanged Context** — Flagging issues in authority source documents themselves (design flaws, PRD gaps) rather than issues in the plan. This skill reviews the plan. If the design has a flaw, the plan should faithfully reflect the design's flaw — the design flaw is a separate issue for `/review-design`. The one exception is Phase 2 early termination, where fundamental plan-design misalignment may indicate the plan was written against an outdated design.

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "fix and re-review" | Address findings, run again | Fix plan, then `/review-plan` |
| "fix critical only" | Accept Major as conditions | Fix Critical findings, proceed to `/beads` with conditions |
| "accepted as-is" | Proceed despite findings | `/beads` (findings noted in report) |
| "escalate to design" | Design-level issues found | Return to `/technical-design` |

When approved: **"Plan review complete. Run /beads to create executable work packages."**

---

*Skill Version: 2.6 — [Version History](VERSIONS.md)*
