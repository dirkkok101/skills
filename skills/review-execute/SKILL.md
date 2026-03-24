---
name: review-execute
description: >
  Adversarial post-execution review that verifies implemented code against bead
  acceptance criteria, failure criteria, design decisions, and upstream docs.
  Unlike /review (general code quality), this skill performs bead-by-bead
  traceability verification — did the executed code actually satisfy what each
  bead specified? Consumes the execution manifest from /execute. Use after
  /execute completes, user says "review execution", "verify beads", or before
  creating a PR for executed work.
argument-hint: "[feature-name] or path to execution manifest"
---

# Review-Execute: Adversarial Post-Execution Verification

**Philosophy:** Execution is where intent becomes code. The general `/review` skill checks code quality — bugs, patterns, security. This skill checks something different: **did the code actually implement what the beads specified?** Every bead carries acceptance criteria, failure criteria, FR references, and design decisions. This skill verifies each claim in the execution manifest against the actual codebase. A bead marked "Completed" means nothing if the acceptance criteria aren't satisfied in the code.

**Duration targets:** BRIEF ~15-20 minutes (≤6 beads, single module), STANDARD ~30-60 minutes (typical feature, 7-20 beads), COMPREHENSIVE ~60-120 minutes (multi-module, 20+ beads, full upstream traceability). Most time is Phase 3 (bead-by-bead verification) — this is where real issues are found.

## Why This Matters

The execution agent self-reviews each bead before committing (lightweight check). But self-review has blind spots: the implementing agent believes its own code is correct. An independent review with fresh context catches:
- Acceptance criteria claimed as met but not actually satisfied in code
- Failure criteria violations the implementing agent didn't notice
- Design decisions silently reversed during implementation
- FR coverage gaps where the bead was "completed" but the FR's Given/When/Then aren't testable
- Pattern deviations where the agent chose a different approach than the referenced pattern
- Scope creep where implementation went beyond the bead's objective

Real-world execution reviews have caught: endpoints with wrong HTTP verbs vs design, missing entity properties that the data model specified, tests that verify framework behavior instead of application logic, and beads marked complete where the success criteria were only partially met.

---

## Trigger Conditions

Run this skill when:
- Execution is complete (`/execute` finished, manifest written)
- User says "review execution", "verify beads", "check the implementation"
- Before creating a PR for executed work
- After significant post-execution fixes

Do NOT use for:
- General code quality review (use `/review` — bugs, security, patterns)
- Reviewing beads before execution (use `/review-beads`)
- Reviewing designs or plans (use `/review-design` or `/review-plan`)

## Stage Gates — AskUserQuestion

At every PAUSE point in this skill, **call the `AskUserQuestion` tool** to present structured options to the user. Do not present options as plain markdown text — use the tool. The YAML blocks at each PAUSE point show the exact parameters to pass.

For pattern details and examples: `../_shared/references/stage-gates.md`

> **Fallback:** Only if `AskUserQuestion` is not available as a tool (check your tool list), fall back to presenting options as markdown text and waiting for freeform response.

---

## Mode Selection

| Mode | When | Scope |
|------|------|-------|
| **BRIEF** | ≤6 beads, single module, low-risk | Manifest check + spot-check 3 beads |
| **STANDARD** | Typical feature, 7-20 beads | Full bead-by-bead verification + design traceability |
| **COMPREHENSIVE** | Multi-module, 20+ beads, or critical path | Full verification + FR acceptance criteria depth + upstream cross-reference |
| **CONVERGE** | **Default.** Fix all issues until 0 FAILs | Selected depth + auto-fix loop |

**CONVERGE is the default mode.** Unless the user explicitly says "no converge" or "review only", always run with CONVERGE enabled. The whole point of review-execute is to leave the code in a passing state — finding issues without fixing them is half the job.

**Verification-mode recommendation:** For verification-mode executions (>70% pre-existing, gap-closure/modification beads), recommend STANDARD unless the user explicitly requests COMPREHENSIVE. The extra UC/FR depth in COMPREHENSIVE rarely finds issues in modification-only bead sets — it loads 8+ design docs but typically produces the same verdict as STANDARD in twice the context.

**Verification-mode Phase 3 scoping:** For verification-mode reviews, Phase 3 (Design Traceability) is abbreviated but NOT skippable. Use this concrete checklist:
- **API surface (mandatory):** For every endpoint touched by a bead, open the api-surface.md and compare response codes, verbs, and request/response shapes line-by-line. Do this systematically, not by following threads. This is how the Sessions review caught the missing token rotation — line-by-line comparison, not ad-hoc tracing.
- **Data model:** Verify properties for new/modified entities only
- **UC tracing:** Skip unless a bead's scope explicitly mentions UC scenario steps
- **FR AC depth:** Skip unless greenfield beads exist

**Report format by outcome:**
- **Round 1 = 0 FAILs:** Abbreviated 1-page report — verdict, WARN table, one-line per-bead status
- **CONVERGE fixed all FAILs:** Hybrid report — detailed findings table showing what was found AND fixed, plus final PASS verdict. Include the fix commits so the user can see what changed.
- **FAILs remain after CONVERGE:** Full report with unresolved findings for user action

**WARN actionability:** Every PRE_EXISTING WARN must include exact file:line references for BOTH the code AND the upstream doc that need alignment. Example: "W1: `UserDTO.cs:45` uses `LinkMethod` but `api-surface.md:112` specifies `LinkedMethod`." This makes the br issue actionable — the person fixing it doesn't need to re-discover the mismatch.

**Frontend test execution:** When running frontend tests for verification, prefer a machine-readable reporter (e.g., `--reporter=json` or equivalent for your test runner) over parsing human-readable output. Human-readable test output often includes serialized error objects that are extremely verbose and hard to parse for pass/fail counts.

### CONVERGE Mode

For the shared CONVERGE pattern (the loop, classification, authority hierarchy, progressive loading, convergence criteria, same-session detection): `../_shared/references/converge-mode.md`

**CONVERGE is the default mode.** Unless the user explicitly says "no converge" or "review only", always run with CONVERGE enabled.

**When to skip CONVERGE:** If a prior STANDARD review already found 0 FAILs, CONVERGE adds no value — the fix loop never activates. In this case, recommend running COMPREHENSIVE (for deeper traceability) without CONVERGE (the fix loop overhead). CONVERGE is most valuable when the prior review found FAILs that need automated fixing, or when no prior review exists.

**Progressive loading waves (review-execute specific):**
- Wave 1: Execution manifest + bead descriptions + changed files (catches most issues)
- Wave 2: Design docs (api-surface, data-model) for beads with findings
- Wave 3: PRD acceptance criteria + ADRs for deep traceability checks

**MECHANICAL examples for review-execute:** wrong HTTP verb, missing entity property, test verifying wrong thing, missing import. Even if a fix touches shared types (like adding a new result type), it's MECHANICAL if the design clearly specifies the expected behavior.

**Pattern pre-check:** Before writing any fix, verify the fix approach against the project's architectural constraints (ADRs, pattern docs, CLAUDE.md). A fix that violates the project's patterns (e.g., injecting DbContext into an endpoint when the project forbids it) creates a new finding. Check constraints BEFORE writing code.

**Cascade check:** After fixing a file, run the project's build and test commands. If tests fail, **diagnose first** — determine whether the failure is from your fix (revert) or from a pre-existing bug your fix exposed (fix the bug). Do NOT automatically revert and reclassify. Only revert if your fix genuinely caused the regression.

**Update manifest after fixes:** Update `docs/execution/{feature}/manifest.md` with new commit hashes, changed file lists, and any corrected FR/UC coverage claims. A stale manifest after CONVERGE undermines future reviews.

**Same-session fresh-eyes mitigation (review-execute specific):** Same-session reviews share the executing agent's context and biases. To compensate:
1. **Re-read design docs from scratch** — do NOT rely on conversation context. Re-read the api-surface.md and data-model.md line-by-line against the implementation.
2. **Load one doc the executing agent didn't read** — spot-check 2 claims against it (e.g., if the agent didn't read the PRD, verify 2 FR ACs against code).

**Non-greenfield execution review:** If the execution manifest or plan's Implementation Status shows >70% of design elements already existed before execution:
- **Verification beads** ("verify X matches design") — the AC is "confirm existing code matches spec." Review by reading the code and checking against the spec, not by looking for newly written code.
- **Modification beads** ("update X to add Y") — verify the specific modification was made. Don't flag pre-existing code that wasn't part of the bead's scope.
- **Gap-filling beads** ("implement missing X") — treat as greenfield for the specific gap.
- Do NOT flag missing tests for pre-existing code that the bead didn't modify — only verify test coverage for new/changed code within the bead's scope.
- Wave 1 only for loading: design api-surfaces + changed files. Only load PRD/UCs if Wave 1 reveals coverage gaps. This cuts document loading by ~60% for modification-only bead sets.

---

## Finding Classification

For the shared severity model (FAIL/WARN definitions), MECHANICAL vs DECISION heuristic, pre-existing drift handling, and finding quality standards, see `../_shared/references/review-finding-taxonomy.md`.

Every finding has a **class** (what's wrong) and a **severity** (FAIL or WARN):

| Class | Meaning | Default Severity |
|-------|---------|-----------------|
| `AC_NOT_MET` | Acceptance criterion claimed but not satisfied in code | **FAIL** |
| `FC_VIOLATED` | Failure criterion is violated by implementation | **FAIL** |
| `DESIGN_DRIFT` | Implementation contradicts design doc (api-surface, data-model) | **FAIL** |
| `PATTERN_DEVIATION` | Implementation doesn't follow referenced pattern doc | **FAIL** |
| `SCOPE_CREEP` | Implementation includes work beyond bead objective | **WARN** |
| `TEST_GAP` | Success criterion has no corresponding test | **FAIL** |
| `TEST_QUALITY` | Test exists but doesn't verify the right thing | **WARN** |
| `MISSING_IMPL` | Bead marked complete but core functionality absent | **FAIL** |
| `FR_GAP` | FR acceptance criteria not satisfied despite bead claiming coverage | **FAIL** |
| `UC_GAP` | Use case scenario step not traceable through implemented code | **FAIL** |
| `ARCH_VIOLATION` | Implementation violates architecture constraint (multi-tenancy, auth, CQRS) | **FAIL** |
| `CROSS_MODULE_GAP` | Cross-module dependency not wired or shared contract not imported | **FAIL** |
| `MANIFEST_STALE` | Manifest claims don't match actual git state | **WARN** |
| `ADR_VIOLATION` | Implementation violates an architectural decision record | **FAIL** |
| `UPSTREAM_DOC` | Issue is in the upstream doc, not the implementation | **WARN** (note separately; create `br` issue) |

**Severity model and pre-existing drift rules:** See `../_shared/references/review-finding-taxonomy.md` for FAIL/WARN definitions, calibration examples, and the PRE_EXISTING tagging rules for non-greenfield reviews.

---

## Critical Sequence

### Phase 0: Load Execution Context

**Step 0.1 — Load Execution Manifest:**

Read `docs/execution/{feature}/manifest.md`.

**If manifest exists:** Parse:
- List of completed beads with IDs
- Files changed per bead
- FRs addressed per bead
- ACs claimed per bead
- Design elements implemented per bead
- Commit hashes per bead

**If manifest is missing or is a stub (fallback):** Reconstruct it as Step 0 rather than flagging and deferring:
1. Note `MANIFEST_STALE` as a WARN finding: "/execute did not write the required manifest"
2. Reconstruct and WRITE the manifest to `docs/execution/{feature}/manifest.md`:
   - Identify the epic: `br search "{feature}"` or `br list --status closed`
   - Get the bead list: `br dep tree {epic-id}`
   - Map commits to beads: `git log --oneline` — match commit messages to bead titles
   - For each bead, derive files changed: `git diff {commit}^..{commit} --stat`
3. Commit the reconstructed manifest so future reviews have it

Creating the manifest upfront (even reconstructed) is more efficient than working without it throughout the review. For mature modules where execution happened across many sessions, this reconstruction is the norm, not the exception.

**Step 0.2 — Load Bead Descriptions:**

Read bead descriptions from one of these sources (in preference order):
1. `docs/beads/{feature}/beads.md` — if the beads skill wrote a beads file
2. `br show bd-{id}` for each bead ID in the manifest — most mature modules won't have a separate beads.md, only tracker entries
3. Manifest bead summaries — last resort if br is unavailable; less detailed

Parse:
- Objective
- Success Criteria (each criterion individually)
- Failure Criteria (each criterion individually)
- Context to Load
- Pattern references
- FR references
- Design references

**Step 0.3 — Identify Changed Files:**

```bash
git log --oneline {first-commit}..{last-commit}  # commits from execution
git diff {pre-execution-commit}..HEAD --stat       # all files changed
```

Cross-reference against manifest file lists. Flag discrepancies.

**Step 0.4 — Check for Prior Reviews:**

Check `docs/reviews/` for existing `review-execute-{feature}-*.md` files. If a prior review exists:
1. Read its verdict and finding count
2. Ask the user: "A prior {STANDARD/COMPREHENSIVE} review exists ({date}, {verdict}). Run a fresh review, or upgrade depth?"
3. If upgrading from STANDARD to COMPREHENSIVE, focus on the additional depth (FR AC, UC tracing, architecture) rather than re-verifying beads that already passed

This prevents wasted work re-reviewing modules and gives COMPREHENSIVE reviews a targeted scope.

**Step 0.5 — Determine Mode:**

If user hasn't specified:
- ≤6 beads, single module → BRIEF
- 7-20 beads, typical feature → STANDARD
- 20+ beads or multi-module → COMPREHENSIVE

---

### Phase 1: Manifest Integrity Check

**Step 1.1 — Verify Manifest Completeness:**

| Check | Method | Severity |
|-------|--------|----------|
| All beads in issue tracker are in manifest | `br list --status closed` vs manifest bead list | FAIL if missing |
| All manifest commits exist in git | `git log --oneline` vs manifest commit hashes | FAIL if missing |
| File lists match actual git changes | `git diff --stat` per commit vs manifest file lists | WARN if mismatch |
| FR coverage table is complete | Every FR from bead descriptions appears in table | WARN if missing |

**Step 1.2 — Verify Build & Tests Pass:**

**Test runner smoke check:** Before running the full suite, confirm you can get clean pass/fail output from the test runners. Run a single small test file to verify output is parseable. **Skip this step** if the project has a proven test runner from prior reviews in this session — the smoke check is for the first review only, not every module.

Run the project's build and test commands. If they fail, **triage quickly:** stash your changes, re-run failing tests, pop the stash — this classifies failures as pre-existing vs introduced by the execution. Only introduced failures are FAIL findings. This takes 30 seconds and prevents 5-10 minutes of manual investigation.

Record test count and pass rate.

**Pre-existing code filter:** For verification-mode reviews, run `git diff {first-execution-commit}^..{last-execution-commit} --name-only` early and focus Phase 2 bead verification on files in that diff. Reading unmodified files provides context but isn't necessary for bead verification — if the code predates the execution commits, skip it unless a specific AC references it.

---

### Phase 2: Bead-by-Bead Verification

**This is the core phase.** For each bead in the manifest, verify the implementation against the bead's specification.

**BRIEF mode:** Spot-check 3 beads (pick: first bead, a middle bead, last bead). For each, run the full checklist below.

**STANDARD/COMPREHENSIVE mode:** Verify every bead.

#### Per-Bead Verification Checklist

For each bead:

**Step 2.1 — Read Implementation:**

Read all files listed in the manifest for this bead. Understand what was actually implemented.

**Step 2.2 — Acceptance Criteria Verification:**

For each success criterion in the bead:
1. Find the code that satisfies it
2. Find the test that verifies it
3. If no code → `MISSING_IMPL`
4. If code but no test → `TEST_GAP`
5. If test exists but tests the wrong thing → `TEST_QUALITY`

Record per-criterion status:
```markdown
| Bead | AC | Code Location | Test Location | Status |
|------|----|--------------|---------------|--------|
| bd-{id} | AC1: returns 404 when not found | src/Endpoints/Get.cs:45 | tests/GetTests.cs:78 | PASS |
| bd-{id} | AC2: includes audit trail entry | — | — | FAIL (AC_NOT_MET) |
```

**Step 2.3 — Failure Criteria Verification:**

For each failure criterion in the bead:
1. Grep the changed files for the prohibited pattern
2. If found → `FC_VIOLATED`

Example: Failure criterion "Do NOT use SaveRequest pattern" → grep for `SaveRequest` in changed files.

**Step 2.4 — Pattern Compliance:**

If the bead references a pattern doc:
1. Read the pattern doc
2. Compare implementation structure against the pattern
3. Key checks: file naming, class structure, DI registration, method signatures
4. If implementation uses a different pattern → `PATTERN_DEVIATION`

**Step 2.5 — Scope Check:**

Compare the bead's objective + in/out of scope against the actual changes:
1. Are there files changed that aren't related to the bead's objective? → `SCOPE_CREEP`
2. Is there functionality added beyond what the bead specified? → `SCOPE_CREEP`

**Step 2.6 — Authorization Test Coverage (for endpoint beads):**

For every endpoint with org-scoped or dual-policy authorization (e.g., PlatformAdmin + OrgAdmin own-org), verify these tests exist:
- [ ] **Cross-org 403:** OrgAdmin on org-A accessing org-B's resource → 403
- [ ] **Own-org success:** OrgAdmin on org-A accessing org-A's resource → success
- [ ] **PlatformAdmin bypass:** PlatformAdmin accessing any org → success

This is a recurring pattern, not a one-off. Every module with org-scoped endpoints needs these tests. Flag missing cross-org tests as `TEST_GAP`.

**Step 2.7 — Test URL Audit (for endpoint beads):**

For each endpoint bead, grep test files for the endpoint's route pattern and verify URLs match. A test calling `/members/remove` when the endpoint is `/members/delete` silently passes (404 → wrong assertion). This is a systematic check, not ad-hoc reading — grep catches what visual scanning misses.

---

### Phase 3: Design Traceability (STANDARD+)

**Load:** Design documents from `docs/designs/{feature}/`. Use the doc map from beads.md or discover paths from the project's doc structure.

**Step 3.1 — API Surface Verification:**

For each bead that implements an endpoint:
1. Read `api-surface.md` for the endpoint spec
2. Compare: HTTP verb, route, request shape, response shape, error responses, auth policy
3. **Before classifying as DESIGN_DRIFT**, check the project-wide pattern. Grep for the status code or verb across all endpoints to see what the codebase actually uses. If the implementation follows a project-wide convention that differs from the design doc, classify as `UPSTREAM_DOC` (doc is stale), not `DESIGN_DRIFT` (code is wrong). Example: if 20+ endpoints return 422 for business validation but the design doc says 400, the doc is stale — the implementation is correct.
4. Flag genuine mismatches as `DESIGN_DRIFT`

```markdown
| Endpoint | Design Spec | Implementation | Match? |
|----------|------------|----------------|--------|
| GET /api/v1/entitlements | api-surface.md:34 | EntitlementsEndpoint.cs:12 | Yes/No |
```

**Step 3.2 — Data Model Verification:**

For each bead that implements an entity:
1. Read `data-model.md` for the entity spec
2. Compare: properties, types, constraints, relationships, indexes
3. Flag missing properties or wrong types as `DESIGN_DRIFT`

**Step 3.3 — ADR Compliance (STANDARD+):**

Read ADRs explicitly referenced by bead failure criteria (STANDARD) or all project ADRs (COMPREHENSIVE). Verify implementation follows each decision. Flag violations as `ADR_VIOLATION`.

**Step 3.4 — Architecture Compliance (STANDARD+):**

Verify implementation follows architecture constraints from `docs/architecture/`. Check: multi-tenancy (tenant interface, query filtering, isolation tests), authorization (server-side enforcement matching design), CQRS separation (if applicable), and any project-specific constraints. Flag violations as `ARCH_VIOLATION`.

**Step 3.5 — UC Scenario Verification (STANDARD+):**

For each use case referenced by beads or in the execution manifest's UC Coverage table:
1. Read the UC document
2. Trace each **main scenario step** through the implemented code — find the endpoint, component, or handler that implements it
3. Trace each **extension flow** — find the error handler, validation, or fallback
4. Trace each **alternative flow** — confirm it's handled or explicitly deferred
5. Flag untraceable steps as `UC_GAP`

```markdown
## UC Scenario Verification

| UC ID | Step | Description | Implementation | Status |
|-------|------|-------------|----------------|--------|
| UC-001 | Main.1 | Admin navigates to list | ListPage component + route | PASS |
| UC-001 | Main.5 | System saves entity | SaveEndpoint → SaveCommand | PASS |
| UC-001 | Ext.3a | Duplicate name error | Validator + 409 response | PASS |
| UC-001 | Ext.5a | Server error during save | — | FAIL (UC_GAP) |
```

This is the pipeline's end-to-end traceability check.

**Step 3.6 — FR Acceptance Criteria Depth (COMPREHENSIVE only):**

For each Must-Have FR referenced by any bead, read the PRD's Given/When/Then acceptance criteria. For each criterion, find implementing code AND verifying test. Flag partial coverage as `FR_GAP`.

---

### Phase 4: Cross-Bead Consistency

**Skip for verification-mode** when beads are predominantly verify/docs type with independent scopes. Phase 4 checks dependency chains and integration points — these are relevant for greenfield beads that build on each other, not for independent verification passes.

**Step 4.1 — Dependency Verification:**

Beads with dependencies should build on each other. Verify:
- Does bead B (depends on A) use the artifacts created by bead A?
- Are there implicit dependencies not captured in the bead graph?

**Step 4.2 — Integration Points:**

For beads that create separate components (backend endpoint + frontend page):
- Do they use matching contracts (same DTOs, same routes)?
- Does the frontend call the endpoint with the right verb and path?

**Step 4.3 — Cross-Module Dependencies:**

For beads that reference cross-module services or contracts:
- Is the cross-module service imported and registered in DI?
- Are shared contracts imported from the correct module?
- Does the dependency actually exist in the other module's implementation?
Flag gaps as `CROSS_MODULE_GAP`.

**Step 4.4 — Test Gate Verification:**

For each test gate bead in the manifest:
- Were the verification commands actually run?
- Do the tests referenced in the gate actually exist and pass?

**Step 4.5 — Deferred Bead Accounting:**

Check whether any beads were closed as "deferred" (not "completed") — e.g., E2E beads requiring a different execution context. List them in the report so the user knows what's still outstanding. Do NOT flag deferred beads as FAILs — they were intentionally skipped per execute skill guidance.

---

### Phase 5: Present Findings

**Step 5.1 — Build Finding Summary:**

Aggregate all findings from Phases 1-4:

```markdown
## Review-Execute Summary: {Feature Name}

> **Date:** {date}
> **Reviewer:** /review-execute skill ({mode})
> **Beads reviewed:** {N}
> **Upstream docs loaded:** {N}

### Verdict: {PASS | PASS WITH FINDINGS | FAIL}

| Severity | Count |
|----------|-------|
| FAIL | {N} |
| WARN | {N} |

### AC Verification Matrix

| Bead | ACs | Verified | Gaps |
|------|-----|----------|------|
| bd-{id}: {title} | {N} | {N} | {list or "none"} |

### Findings

#### FAIL ({N})

| # | Bead | Class | Description | File:Line |
|---|------|-------|-------------|-----------|
| F1 | bd-{id} | AC_NOT_MET | {description} | {file:line} |

#### WARN ({N})

| # | Bead | Class | Description | File:Line |
|---|------|-------|-------------|-----------|
| W1 | bd-{id} | SCOPE_CREEP | {description} | {file:line} |

### Design Traceability

| Design Element | Source | Bead | Implementation | Match? |
|---------------|--------|------|----------------|--------|
| {endpoint} | api-surface.md:34 | bd-{id} | EndpointFile.cs:12 | Yes/No |

### UC Scenario Verification (STANDARD+)

| UC ID | Steps Traced | Gaps | Status |
|-------|-------------|------|--------|
| UC-001 | 16/16 main + 4/5 ext | Ext.5a: no server error handler | Partial — FAIL |
| UC-002 | 12/12 main + 3/3 ext | — | Full |

### Architecture Compliance

| Constraint | Source | Status |
|-----------|--------|--------|
| Multi-tenancy | docs/architecture/multi-tenancy.md | ✅ / ❌ |
| Authorization | api-surface.md auth policies | ✅ / ❌ |
| CQRS | docs/architecture/cqrs.md | ✅ / ❌ |
```

**Step 5.2 — Write Review Report:**

Write the full review to `docs/reviews/review-execute-{feature}-{date}.md`.

**Step 5.2a — Track UPSTREAM_DOC Issues:**

If any `UPSTREAM_DOC` findings were identified, create an issue for each in the issue tracker so they don't get re-discovered on every review:
```bash
br create "doc: fix {design-doc} — {description of mismatch}" --type task -p 3
```
These are low-priority (p3) doc fixes, not implementation work. Group related mismatches into a single issue (e.g., "doc: align api-surface status codes with implementation" for multiple status code mismatches in the same design file).

**Step 5.3 — Present to User (if CONVERGE disabled):**

Since CONVERGE is the default, this step only applies when the user explicitly requested "review only" or "no converge".

Present the executive summary and finding counts. Use AskUserQuestion:

```
AskUserQuestion:
  question: "Review-execute found {N} FAILs and {M} WARNs. How should we proceed?"
  header: "Findings"
  multiSelect: false
  options:
    - label: "Fix all (Recommended)"
      description: "Return to /execute re-entry to fix all findings."
    - label: "Fix FAILs only"
      description: "Fix FAIL findings, accept WARNs as-is."
    - label: "Approved as-is"
      description: "Accept implementation without fixes."
    - label: "Another round"
      description: "Re-run review for a fresh perspective."
```

---

## Finding Quality Standards

See `../_shared/references/review-finding-taxonomy.md` for the full non-negotiable standards (re-read before flagging, quote defects, cite sources, verify current state) and the cross-skill "What NOT to Flag" list.

**Skill-specific exclusions** (in addition to the shared list):
- **Code style issues** — that is `/review`'s job, not this skill's
- **Missing tests for code not covered by any bead** — only verify bead-scoped work
- **Design decisions made outside the bead scope** — if the bead did not reference it, do not flag it

---

## Trust Hierarchy

When verifying implementation, check against sources in this order (highest trust first):

1. **ADRs & Pattern docs** — architectural decisions, non-negotiable
2. **Design docs** (api-surface, data-model) — the technical contract
3. **PRD** — business requirements, acceptance criteria
4. **Bead specifications** — what the executing agent was told to build
5. **Plan** — implementation decomposition (lower trust — may have drifted)
6. **Execution manifest** — claims about what was built (lowest trust — verify everything)

If implementation contradicts a higher-trust source, the implementation is wrong — even if the manifest claims it's correct.

---

## Anti-Patterns

**Reviewing Code Quality** — This skill reviews bead satisfaction, not code quality. Don't flag variable naming, error handling patterns, or DRY violations — that's `/review`. If you catch yourself writing "this could be refactored to..." you're in the wrong review mode.

**Manifest-Only Review** — Reading the manifest and checking boxes without reading actual code. The manifest is the executing agent's claim — the code is the truth. Always `Read` the implementation files.

**Flagging Upstream Issues as Implementation Bugs** — If the design api-surface says "returns 200" but should say "returns 201", that's an `UPSTREAM_DOC` finding, not an implementation bug. The implementation correctly followed a wrong spec.

**Pattern Perfectionism** — Flagging every minor deviation from a pattern doc as `PATTERN_DEVIATION`. Patterns are guidance, not byte-for-byte templates. If the intent is followed and the code works, minor structural variations are acceptable.

**Testing the Framework** — Flagging missing tests for framework plumbing (DI registration, middleware pipeline, route matching, ORM configuration). Tests should verify application logic, not that the framework works correctly.

**Scope-Blind Review** — Reviewing files changed by the execution that aren't part of any bead's scope. Focus on bead-scoped work only. If adjacent code was modified, that should have been flagged as scope creep, not reviewed as bead work.

---

## Relationship to /review

| Concern | `/review` | `/review-execute` |
|---------|-----------|-------------------|
| **Focus** | Code quality, bugs, security | Bead satisfaction, design traceability |
| **Scope** | Git diff (all changed files) | Per-bead (files claimed by each bead) |
| **Authority** | Code patterns, security best practices | Bead ACs, design docs, PRD FRs |
| **Agents** | 6-9 specialized parallel agents | Single reviewer (no agent delegation) |
| **Output** | `docs/reviews/review-{timestamp}.md` | `docs/reviews/review-execute-{feature}-{date}.md` |
| **When** | After /execute OR after /review-execute fixes | After /execute, before /review |
| **CONVERGE** | No (read-only review) | Yes (fixes implementation) |

**Recommended pipeline:** `/execute` → `/review-execute` (bead satisfaction) → `/review` (code quality) → `/compound` (learnings).

**Agent boundary: agents READ, you GENERATE.** Agents load files and produce summaries. YOU generate findings from what they read. Do NOT ask agents to identify issues — they lack pattern context and produce 10-20% false positives.

**Skip agents** when <5 files to read, or for verification-mode with ≤3 modification beads (direct reads are faster). When agents ARE used, instruct them to produce **concise summaries** (key facts per file, not full contents) and include: bead In Scope section, failure criteria, correct patterns to NOT flag, and key architectural constraints from CLAUDE.md.

---

## Exit Signals

| Condition | Action |
|-----------|--------|
| 0 FAILs | Report PASS, suggest `/review` for code quality |
| FAILs found | Present findings, offer fix options |
| CONVERGE complete | Report convergence, suggest `/review` |
| User says "stop" | Write partial report, note unreviewed beads |

When 0 FAILs: **"All beads verified. Run `/review` for code quality review, or `/compound` to capture learnings."**

---

*Skill Version: 2.1 — [Version History](VERSIONS.md)*
