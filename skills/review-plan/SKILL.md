---
name: review-plan
description: >
  Use when a plan is complete (/plan finished), user says "review the plan",
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

## Shared References

Before starting any review, load these shared reference files:
- **CONVERGE loop & classification:** `../_shared/references/converge-mode.md`
- **Severity model & finding quality:** `../_shared/references/review-finding-taxonomy.md`

These define the CONVERGE mode behavior, MECHANICAL vs DECISION classification, authority hierarchy, PRE_EXISTING severity rules, and finding quality standards shared across all review skills. Skill-specific CONVERGE behavior (wave definitions, authority hierarchy overrides) is documented inline below.

---

## Mode Selection

| Mode | When | Depth | Output |
|------|------|-------|--------|
| **BRIEF** | Single overview file, simple feature | Structural + design fidelity + PRD coverage | Inline findings summary |
| **STANDARD** | Overview + sub-plans, typical feature | All 7 phases | Full review report |
| **COMPREHENSIVE** | Large feature with companion docs | All 7 phases + companion doc audit + cross-reference deep dive | Full review report + alignment findings |
| **CONVERGE** | Fix all issues until 0 Critical/Major | Selected depth + auto-fix loop | Converged plan + report |

### CONVERGE Mode

When the user says "converge", "fix all issues", "autoresearch", or selects CONVERGE mode, run the autoresearch convergence loop. CONVERGE can be combined with any review depth:

- `CONVERGE` alone → uses STANDARD depth
- `CONVERGE + COMPREHENSIVE` → uses COMPREHENSIVE depth (all phases + companion docs)
- `CONVERGE + BRIEF` → uses BRIEF depth (structural + design fidelity only)

**CONVERGE changes to the normal review flow:**
- **Skip all interactive stage gates.** CONVERGE implies "just go — fix what you can, escalate what you can't."
- **Replace Phase 7 interactive walkthrough** with a summary table of all findings, classified as MECHANICAL / JUSTIFIED_DEVIATION / DECISION.
- **READ-ONLY does not apply** in CONVERGE mode — the plan is modified directly.
- **MECHANICAL findings are auto-fixed regardless of severity.** Count errors, stale numbers, missing table rows, and arithmetic mismatches are the same class of issue whether they appear in a summary table (FAIL) or a companion doc (WARN). Auto-fix all MECHANICAL findings.
- **Trivial WARN auto-fix heuristic:** If the fix is additive-only (no deletions, no semantic changes) and under 10 lines, auto-fix it without escalation. Examples: adding a checklist item to a sub-plan, adding a verification task, fixing a count.
- **Non-trivial WARNs** (judgment calls, scope decisions, authority source conflicts) are escalated via AskUserQuestion after FAILs reach 0.

**The loop:**

1. **Review** — Run the review at the selected depth. Use progressive loading:
   - Wave 1: overview.md + design.md + PRD (catches structural + coverage gaps)
   - Wave 2: sub-plans + feature api-surfaces (catches design fidelity issues)
   - Wave 3: agents for broad ADR/pattern/architecture surveys
2. **Classify** findings:
   - **MECHANICAL** — stale count, missing table row, wrong FR ID, internal contradiction where one side is clearly correct per authority hierarchy. Auto-fix these.
   - **JUSTIFIED_DEVIATION** — plan deviates from convention with explicit, documented rationale. Verify rationale is sound; if yes, mark as PASS.
   - **DECISION** — plan contradicts design, design contradicts PRD, scope question requiring user judgment. Escalate via AskUserQuestion.
3. **Fix** mechanical findings using minimum changes. **Cascade check:** after cross-cutting fixes, grep the plan directory for related terms before declaring fix complete. **Cascade scope is the plan directory only** — cross-module cascades noted as observations.
4. **Re-review** — Run the review again on the fixed plan.
5. **Compare** — Did Critical+Major findings decrease? If increased, revert and stop.
6. **Repeat** until 0 FAILs or max 5 rounds.
7. **WARN triage** — After FAILs reach 0, present remaining WARNs to the user as a final batch via AskUserQuestion with "Fix / Accept as-is" options. Trivial WARNs (1-line fixes with zero ambiguity, like adding a missing prerequisite) may be auto-fixed alongside FAILs.

**Same-session detection:** If the plan's creation date matches today AND the conversation contains /plan invocations or plan-writing activity, flag as same-session. Note this in the report. For same-session reviews:
- Phase 2 confidence is LOW (not MODERATE) — the reviewer shares the generating agent's blind spots
- Phase 2 agents should use a deliberately adversarial prompt: "Assume the plan author has blind spots. Look for unstated assumptions, implicit design decisions, and coverage claims that rely on 'already implemented' without evidence."
- Phase 1 should use explicit Read calls per section (not mental checklist from memory)
- Verify at least 3 specific claims against the actual codebase using Grep/Read
- Recommend independent spot-check on Phase 2 if the plan is used for production /beads Same-session reviews catch internal consistency errors (Phase 6) and adversarial depth-check failures (Phase 4) but are blind to the generating agent's systematic biases. Recommend independent spot-check on Phase 2 (design fidelity) if time permits.

**Confidence level:** Include in the convergence report:
- **HIGH** — independent reviewer, fresh context, all authority sources loaded from disk
- **MODERATE** — same-session review, non-greenfield plan with mostly verification tasks
- **LOW** — same-session review, same agent, large plan with many judgment calls

**Authority hierarchy for mechanical fixes:**
```
Technical design (api-surface, data-model) > PRD (FRs, UCs, ACs) > ADRs > Pattern docs > Architecture docs > Plan overview > Sub-plans
```

**Non-greenfield agent prompts:** When launching agents to review non-greenfield plans, include ALL of these in the prompt:
- "This is a non-greenfield plan. All design elements already exist in code."
- "'Covered by T01 (verification)' means 'verified to match design,' not 'needs building.' Do NOT flag verification coverage as gaps."
- "If a discrepancy exists between two authority sources (PRD says X, design says Y) and the plan follows one consistently, this is NOT a plan finding — note it as an observation only."
- "Concerns handled by the framework or platform are inherently compliant unless the plan explicitly modifies them."
- "If the plan says 'T02 verifies encryption' and the gap analysis says 'code exists,' that IS sufficient coverage. Do NOT flag it as insufficient because the plan doesn't describe HOW to verify — that's /beads territory."

**Agent context:** Agents should receive both the plan files AND the current gap analysis (not just the authority source). This prevents agents from confusing old and new gap analyses.

**Agent finding classification:** Instruct agents to classify each finding AND provide reasoning. The reviewer validates or reclassifies — agents sometimes classify "missing from design because never designed" as MECHANICAL when it's actually a DECISION.

**Agent sub-plan reading:** Add to agent prompts: "Before flagging any FR coverage as incomplete, read the full sub-plan body for the covering task(s). The overview table is a summary — the sub-plan is the authority."

**Agent false positive rate:** Expect 30-40% false positive rate from review agents. Budget time for triage. For plans with ≤3 sub-plans, skip agents and do direct authority source reads + spot-checks instead — the reviewer's own reads are more efficient than filtering agent noise.

**Companion doc depth:** Scale by plan complexity. For plans with ≤3 sub-plans, structural check is sufficient. For plans with >3 sub-plans, cross-reference companion docs against design test plans and security analysis.

**Same-session spot-checks:** Increase from 3 to 5 minimum. Target gap analysis claims specifically: (a) does the test infrastructure exist where the plan says, (b) do existing files contain what the gap analysis claims, (c) do "Modify" elements actually have the claimed issues. Same-session generating agents consistently produce stale count/existence errors.

**Phase ordering for CONVERGE:** Consider running Phase 6 (internal consistency / arithmetic) immediately after Phase 0, not last. Arithmetic errors are the cheapest fixes and most common MECHANICAL findings. Fixing them first reduces cascading corrections.

**Test counts single source of truth:** The test-scenario-matrix should be the authoritative test count. Overview and sub-plans should reference it ("see test-scenario-matrix.md") instead of stating counts that drift.

**Agent finding triage table:** Include in the review report: `## Agent Finding Triage` with a disposition column (Accepted / False Positive / Reclassified). Makes the review auditable.

**Verification Mode phase collapsing:** For plans where >90% exists and the gap analysis IS the plan, Phases 2 (design fidelity) and 3 (gap analysis fidelity) collapse into a single check: "does the gap analysis correctly identify what needs to change?" Run them as one phase rather than separately. Phase 2's endpoint/contract verification is redundant when the plan's tasks are verification checklists, not construction blueprints. Without this, agents will produce false positives by assuming greenfield context.

**Codebase spot-check:** For non-greenfield plans, the gap analysis claims about implementation state are the foundation of the decomposition. A 30-second Grep to verify key claims (e.g., confirm the named class exists, confirm the endpoint route is registered) significantly increases confidence. This is particularly valuable for Phase 3 (Gap Analysis Fidelity).

**Token budget:** COMPREHENSIVE reviews read the full plan + design + PRD + relevant ADRs/patterns. For plans with 10+ sub-plans, expect 30-50 documents. Models with <200K context may need two-pass approach.

**Convergence report:** For quick convergences (≤3 rounds, ≤10 findings), use compact format:
`{N} findings → {N} fixed in {N} rounds. {N} decisions escalated. Minor: {N} (not fixed).`

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

**Step 1.1 — Overview Document Structure:**

Verify the overview contains all required sections from the `/plan` skill spec:

| Required Section | BRIEF | STANDARD | COMPREHENSIVE |
|-----------------|-------|----------|---------------|
| References | Yes | Yes | Yes |
| Decomposition Strategy | Yes | Yes | Yes |
| Cross-Cutting Concerns | Yes | Yes | Yes |
| Task Summary table | Yes | Yes | Yes |
| FR Coverage table | Yes | Yes | Yes |
| UC Coverage table | No | Yes | Yes |
| Design Coverage table | No | Yes | Yes |
| Design Decision Coverage table | No | Yes | Yes |
| Implementation Status (non-greenfield) | No | If applicable | If applicable |
| Dependency Graph | No | Yes | Yes |
| Critical Path | No | Yes | Yes |
| Risk Register | No | No | Yes |
| Testing Summary | No | Yes | Yes |
| Sub-Plans table | No | Yes | Yes |

Flag missing required sections as **WARN** findings.

**Step 1.2 — Sub-Plan Document Structure (STANDARD+):**

For each sub-plan, verify required sections:
- Traceability (Implements, Design Reference, Validates Against)
- Prerequisites
- Objective
- Context
- Tasks (each with: Objective, Approach, Success Criteria)
- Component Success Criteria
- References

Verify conditional sections are present when applicable:
- Pseudocode (when design produced algorithmic detail)
- Contract Shapes (when task defines or modifies contracts)
- Pattern Reference (when established patterns exist)

Verify mandatory sections:
- Failure Criteria — REQUIRED for **implementation tasks**. Must include explicit "do NOT" guidance derived from design decisions and rejected alternatives. Flag missing Failure Criteria on implementation tasks as **WARN**. **Exception:** verification/audit tasks (tasks whose primary objective is confirming existing code matches a specification) may omit Failure Criteria — the success criteria checklist serves as the constraint.

Flag missing required sections as **WARN**. Flag missing conditional sections (when clearly applicable) as **Minor**.

**Step 1.3 — Companion Document Compliance (COMPREHENSIVE):**

If plan mode is COMPREHENSIVE, verify companion documents exist and contain required structure:
- `e2e-test-plan.md`: Scope, Environment, Smoke Checks, Critical Path Scenarios
- `security-hardening-checklist.md`: Priority tiers (0/1/2), Exit Criteria (skip if design says "no security implications")
- `test-scenario-matrix.md`: Summary metrics, UC-to-test mapping

Flag missing COMPREHENSIVE companion docs as **WARN**.

**Step 1.4 — Anti-Pattern Detection:**

Check for each anti-pattern defined in the `/plan` skill spec:

| Anti-Pattern | Detection Signal | Severity |
|-------------|-----------------|----------|
| **Horizontal-Only Decomposition** | All tasks scoped to a single layer (all DB, then all API, then all UI) with no end-to-end slice | FAIL |
| **Deferred Risk** | High-risk or integration tasks appear only in late phases | WARN |
| **Testing as Phase N** | A dedicated "write tests" phase/task with no per-task test expectations. **Exception:** for non-greenfield plans where existing code has zero tests, a dedicated test task for pre-existing code is legitimate. | WARN |
| **200-Task Plan** | Excessive task count relative to feature scope; trivial tasks that should be merged | WARN |
| **Plan-as-Design** | Sub-plans make architectural decisions not present in the design (new patterns, new entities, new API shapes) | FAIL |
| **Copy-Paste Sub-Plans** | Large blocks of text duplicated verbatim from design docs instead of referenced | Minor |
| **Hollow Sub-Plans** | Sub-plans with only prose descriptions — no pseudocode, no contract shapes, no pattern references despite design having produced this detail | WARN |
| **Misaligned Decomposition** | Sub-plan grouping doesn't mirror the design's feature decomposition structure | WARN |

**Step 1.5 — Plan/Beads Boundary Violations:**

Verify no sub-plan contains content that belongs in /beads:
- Compilable source code (not pseudocode)
- Commit messages or git workflow instructions
- File modification checklists (specific files to create/edit)
- Test commands or CI pipeline steps

Flag violations as **Minor** (they don't block /beads but indicate confusion about the boundary).

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

Every finding gets a severity:

| Severity | Definition | Examples | Autoresearch Mapping |
|----------|-----------|---------|---------------------|
| **FAIL** | Blocks /beads — will produce wrong code or miss requirements | Design contradiction, missing Must-Have FR, phantom scope, circular dependencies | Auto-fixed (MECHANICAL) or escalated (DECISION) |
| **WARN** | Degrades quality — causes rework or confusion during /execute | Missing plan sections, hollow sub-plans, ADR violations, false FR coverage | Logged, not auto-fixed |

Minor and observational issues are reported inline as notes, not as formal findings. This aligns with review-prd and review-design severity models and ensures CONVERGE mode works consistently across all review skills.

**Step 7.2 — Determine Verdict:**

| Verdict | Criteria |
|---------|----------|
| **PASS (CLEAN)** | 0 FAILs on first review — plan needed no fixes |
| **PASS (CONVERGED)** | 0 FAILs after CONVERGE rounds — plan was fixed to compliance |
| **PASS WITH CONDITIONS** | 0 FAILs, WARNs noted as conditions for /beads |
| **FAIL** | Any FAIL findings remaining after max rounds |

**Step 7.3 — Write Review Report:**

Save to: `${PROJECT_ROOT}/docs/reviews/review-plan-{feature}-{date}.md`

```markdown
# Plan Review: {Feature Name}

> **Date:** {date}
> **Plan:** `docs/plans/{feature}/overview.md`
> **Mode:** {BRIEF | STANDARD | COMPREHENSIVE}
> **Verdict:** {PASS | PASS WITH CONDITIONS | FAIL}

## Executive Summary

**Findings:** {total} ({N} Critical, {N} Major, {N} Minor, {N} Observation)

{2-3 sentence summary of the plan's overall health and the most important findings.}

### Authority Source Compliance

| Authority Source | Status | FAIL | WARN | Minor |
|-----------------|--------|----------|-------|-------|
| /plan skill spec (structural) | Pass/Fail | {N} | {N} | {N} |
| Technical design (fidelity) | Pass/Fail | {N} | {N} | {N} |
| Gap analysis (scope) | Pass/Fail/N/A | {N} | {N} | {N} |
| PRD (traceability) | Pass/Fail | {N} | {N} | {N} |
| Architecture/patterns/ADRs | Pass/Fail | {N} | {N} | {N} |
| Internal consistency | Pass/Fail | {N} | {N} | {N} |

## Critical Findings

### C1. {Title}
- **Phase:** {which review phase found this}
- **Authority:** {specific document, section, requirement}
- **Plan Location:** {file and section in the plan}
- **Issue:** {description — what the plan says vs what the authority says}
- **Impact:** {what goes wrong if not fixed — why this blocks /beads}
- **Resolution:** {concrete fix}

### C2. ...

## Major Findings

### M1. {Title}
- **Phase:** {which review phase}
- **Authority:** {specific reference}
- **Plan Location:** {file and section}
- **Issue:** {description}
- **Resolution:** {concrete fix}

### M2. ...

## Minor Findings

- **m1.** {one-line description} — {plan location} — {fix}
- **m2.** ...

## Observations

- **o1.** {note for awareness}
- **o2.** ...

---
*Review performed against: /plan skill spec v3.5, design doc, PRD, {N} ADRs, {N} pattern docs*
```

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
