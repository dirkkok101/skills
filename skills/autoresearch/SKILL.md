---
name: autoresearch
description: >
  Use when documents need quality convergence, user says "autoresearch",
  "converge", "fix all issues", or after a review reveals multiple findings.
argument-hint: "[prd|design] [module-name]"
---

# Autoresearch: Document Quality Convergence Loop

**Philosophy:** Adapted from [Karpathy's autoresearch](https://github.com/karpathy/autoresearch) and [pi-autoresearch](https://github.com/davebcn87/pi-autoresearch). The technique works on any domain with a frozen metric — ML loss, bundle size, or in our case, **review FAIL count**. The document is the model. The review skill is the evaluation function. The fix agent is the optimizer. The loop runs until FAILs hit zero or convergence is detected.

**Key principle:** The review skill (evaluation function) is FROZEN. Never modify the review skill during the loop. If the review skill is wrong, fix it **between** runs, not during.

---

## When to Use This Skill vs CONVERGE Mode

Both `/review-prd` and `/review-design` have a built-in **CONVERGE mode** that runs the autoresearch loop on a single document. Use that for single-module convergence.

**Use this standalone `/autoresearch` skill when:**
- Running convergence across **multiple modules** in parallel
- Running convergence on a document type that **doesn't have its own review skill** (custom checklists, plans, any doc with a structured evaluation)
- You want to run the loop with a **custom evaluation function** (not the standard review skills)
- User says "autoresearch all designs", "converge everything", "fix all modules"

**Use CONVERGE mode on the review skill when:**
- Converging a **single PRD** → `/review-prd {module}` then select CONVERGE
- Converging a **single design** → `/review-design {module}` then select CONVERGE
- The review skill already has all the context and checklist needed

**Do NOT use either when:**
- For a single finding (just fix it directly)
- When ALL findings require architectural decisions (nothing to auto-fix)
- On documents without a structured evaluation function (subjective reviews can't converge)

---

## Inputs

```
Mode: prd | design
Module: {module-name}
Project Root: ${PROJECT_ROOT} (from git rev-parse --show-toplevel)
Review Skill: /review-prd (for PRDs) or /review-design (for designs)
Max Rounds: 5 (default) — hard stop to prevent infinite loops
Duration: ~10-30 min per module (STANDARD), ~20-60 min (COMPREHENSIVE). Multi-module runs execute in parallel.
```

---

## Progressive Loading Strategy

Do NOT load everything upfront. Most findings come from a small subset of files. Load in waves:

**Wave 1 (always):** design.md + PRD (the two primary documents). Scan for structural issues. This catches 60%+ of findings with ~20% of the reading cost.

**Wave 2 (if Wave 1 finds issues):** Load only the files referenced by Wave 1 findings — specific api-surface.md, test-plan.md, or decision files. Load ADR titles (not full content) to check the compliance table.

**Wave 3 (if cross-cutting or pattern findings):** Use Explore agents for broad surveys (all patterns, all ADRs, architecture docs). Use direct reads for the design files under review.

**Rule of thumb:** Use agents for broad surveys (scanning all patterns, all ADRs for relevance). Use direct reads for the specific design files you're fixing.

For quick convergences (design already at 0-2 FAILs), Wave 1 alone may be sufficient.

---

## The Loop

```
SETUP:
  Read the review skill SKILL.md (FROZEN — do not modify)
  Locate the document(s) to optimize
  Load authority sources using progressive loading (Wave 1 first)

ROUND 1:
  1. REVIEW — Run the review skill against the document
     Output: structured findings (FAIL/WARN/PASS counts + details)

  2. CLASSIFY — Split findings into three categories:
     MECHANICAL:          wrong heading, stale count, missing section, format error,
                          test case expecting wrong status code, internal contradiction
                          where one side is clearly correct
     JUSTIFIED_DEVIATION: design deviates from pattern/ADR but has an explicit,
                          documented rationale (e.g., "SOC 2 requires audit in commands
                          despite pattern doc saying otherwise"). The deviation is
                          intentional and reasoned — not a mistake.
     DECISION:            PRD vs design conflict where both could be right,
                          ADR contradiction requiring superseding proposal,
                          architectural choice requiring user judgment,
                          deviation from pattern WITHOUT documented rationale

     JUSTIFIED_DEVIATION handling: verify the rationale is sound and documented.
     If it is, mark as PASS (not a finding). If the rationale is weak or missing,
     reclassify as DECISION and escalate.

  3. FIX — Apply MECHANICAL fixes only
     For each mechanical FAIL:
       - Read the specific file and location
       - Apply the minimum change to resolve the finding
       - Do NOT change surrounding content
       - Do NOT introduce new patterns or restructure
     Record every change made (file, line, what changed, why)

     CASCADE CHECK: After applying fixes for cross-cutting concerns (audit,
     error format, auth policy, status codes), grep the entire document directory
     for terms related to the fix before declaring it complete. Example: after
     fixing a route parameter name, search for the old name across all files.

     DECISION RECORDS are out of scope for cascade fixes — they document
     historical choices and should not be modified during the convergence loop.
     Only fix normative documents (the document under review and its supporting files).

  3b. SKIP all interactive stage gates during the loop. CONVERGE implies "just go."
      Replace any interactive per-finding walkthrough with a summary table.
      WARNs are listed but NOT fixed and NOT presented interactively.

  4. ESCALATE — Present DECISION findings to user via AskUserQuestion
     Do not attempt to fix these. Present context, options, recommendation.
     Record user's decisions.

  5. APPLY DECISIONS — Fix the decision-required items per user input

  6. SCORE — Count remaining FAILs

ROUND 2..N:
  7. RE-REVIEW — Run the review skill again
  8. COMPARE — Did FAILs decrease?
     - Decreased → continue to next round
     - Same → check if findings are the SAME findings (stuck) or NEW findings
       - Same findings: fix approach failed, try different approach
       - New findings: previous fixes exposed deeper issues, continue
     - Increased → REVERT last round's changes, stop, escalate

  9. CONVERGENCE CHECK:
     - FAILs = 0 → STOP (success)
     - 3 consecutive rounds with no improvement → STOP (converged)
     - Max rounds reached → STOP (budget exhausted)
     - All remaining FAILs are DECISION type → STOP (needs human)

  10. If continuing → go to step 3 (CLASSIFY + FIX next round's findings)

REPORT:
  Present convergence summary:
  - Starting FAILs → ending FAILs
  - Rounds executed
  - Changes made (file, change, round)
  - Remaining findings (if any) with classification
  - Decision items resolved by user
```

---

## Classification Rules

### MECHANICAL (auto-fixable)

| Finding Type | Example | Fix Approach |
|-------------|---------|-------------|
| Wrong status code | Test expects 200, api-surface says 201 | Update test to match api-surface |
| Stale count | Header says "10 FRs", PRD has 9 | Update header count |
| Missing heading | No `### Audit Logging` under Security | Add heading with content from elsewhere in doc |
| Format error | Error example not RFC 7807 | Reformat to RFC 7807 structure |
| Internal contradiction | Sequence diagram shows 200, api-surface says 204 | Align to the more authoritative source (api-surface > diagram) |
| Stale cross-reference | UC references moved endpoint | Update UC to reference correct endpoint |
| Wrong column count | Endpoint table has 4 columns, needs 5 | Add missing column |
| Stale UC/PRD text | UC says old behavior, design correctly follows ADR | Update UC to match ADR |

### JUSTIFIED_DEVIATION (verify rationale, then PASS)

| Finding Type | Example | Action |
|-------------|---------|--------|
| Pattern deviation with rationale | Design audits in commands despite pattern saying not to, with documented SOC 2 justification | Verify rationale is sound. If yes → PASS. If weak → reclassify as DECISION. |
| ADR deviation with documented trade-off | Design uses different approach than ADR, with explicit trade-off analysis in decisions/ | Verify trade-off is reasonable. If yes → PASS. If not → reclassify as DECISION. |
| Convention deviation with scope justification | Design uses different column count with documented reason (e.g., "audit entities are read-only, full DTO pattern unnecessary") | Verify justification holds. If yes → PASS. |

**Key distinction:** JUSTIFIED_DEVIATION has an explicit rationale in the design documents. DECISION has no rationale — the agent deviated silently or the documents genuinely conflict.

### DECISION (escalate to user)

| Finding Type | Example | Why It Needs a Decision |
|-------------|---------|----------------------|
| PRD vs design conflict | PRD says RESTRICT, design says CASCADE | Both documents are authoritative |
| ADR contradiction without rationale | Design deviates from ADR without superseding or documenting why | May need new ADR |
| Architectural choice | OrgMember vs OrgAdmin auth policy | Security implications |
| Cross-module ownership | Which module owns approve/reject routes | Affects multiple designs |
| Missing feature design | Must Have FR has zero design coverage | Scope decision |

### Severity Alignment

The autoresearch loop operates on **FAIL findings only** from the review skill. WARNs are logged but not fixed in the loop — they represent quality improvements, not compliance gaps. If the review skill and the autoresearch classification disagree on severity, **the review skill wins** (it's the frozen evaluation function). Do not reclassify a review WARN as an autoresearch MECHANICAL fix.

### Authority Hierarchy (for mechanical fixes)

When two documents disagree and it's clearly a stale-reference issue (not a genuine design decision), use this hierarchy to determine which is correct:

```
ADRs (highest — project-wide decisions)
  ↓
Pattern docs (established conventions)
  ↓
Architecture docs (system constraints)
  ↓
PRD (requirements — but FRs/ACs can have errors)
  ↓
Design api-surface.md (contract — most authoritative design file)
  ↓
Design backend.md (pseudocode — subordinate to api-surface)
  ↓
Design ui-mockup.md (visual — subordinate to api-surface)
  ↓
Design diagrams (visual aids — most likely to be stale)
  ↓
Test plans (derived from api-surface — update to match)
  ↓
Use cases (scenario descriptions — update to match design)
  ↓
READMEs (index/summary — most likely to have stale counts)

Decision records (decisions/*.md) are OUTSIDE this hierarchy.
They document historical choices and are not updated during the loop.

**FR ID aliasing:** Documents may use shortened FR IDs (e.g., FR-APP-SAVE
for FR-APP-AGGREGATE-SAVE). Check for documented alias mappings before
flagging mismatches.

**Cascade scope:** Module directory only. Cross-module cascades are out
of scope — note them as WARNs for manual follow-up.
```

---

## Guardrails

1. **Frozen evaluation.** NEVER modify the review skill during the loop. If the review skill is finding false positives, stop the loop, fix the skill, then restart.

2. **Minimum change principle.** Each fix should be the smallest change that resolves the finding. Do not refactor, restructure, or "improve" surrounding content.

3. **Revert on regression.** If FAILs increase after a round, revert that round's changes immediately. The fix made things worse.

4. **Decision escalation is mandatory.** Never guess on a decision-required finding. Present it to the user with context and options. A wrong automated decision is worse than an unfixed finding.

5. **Max rounds = 5.** Hard stop. If 5 rounds of review→fix haven't converged, the remaining issues likely need architectural changes, not document fixes.

6. **Log everything.** Every change, every round, every decision. The convergence log is the audit trail.

---

## Convergence Report Format

**Use compact format** for quick convergences (≤3 rounds, ≤10 findings):

```markdown
## Autoresearch: {Module} — {N} findings → {N} fixed in {N} rounds. {N} decisions escalated.
Changes: {file1} (fix1), {file2} (fix2). Decision: {finding} → {user choice}.
```

**Use full format** for complex convergences (4+ rounds, 10+ findings, or regressions):

```markdown
## Autoresearch Convergence Report

**Module:** {module}
**Document type:** {PRD | Design}
**Rounds:** {N}
**Result:** {Converged at 0 FAILs | Converged at N FAILs | Budget exhausted | Needs decisions}

### Score Trajectory

| Round | FAILs | WARNs | Mechanical Fixes | Decisions |
|-------|-------|-------|-----------------|-----------|
| 0 (baseline) | {n} | {n} | — | — |
| 1 | {n} | {n} | {n} fixes | {n} escalated |
| 2 | {n} | {n} | {n} fixes | — |
| ... | ... | ... | ... | ... |

### Changes Made

| Round | File | Change | Rationale |
|-------|------|--------|-----------|
| 1 | {file} | {what changed} | {FAIL-N: description} |

### Remaining Findings (if any)

| # | Type | Finding | Why Not Fixed |
|---|------|---------|---------------|
| 1 | DECISION | {finding} | Needs user input |
| 2 | STUCK | {finding} | 3 rounds, no improvement |

### Decision Log

| # | Finding | Decision | Applied |
|---|---------|----------|---------|
| 1 | {finding} | {user's choice} | Round {N} |
```

---

## Multi-Module Mode

When running across multiple modules (e.g., "autoresearch all designs"):

```
For each module in parallel:
  Run the loop independently
  Stop on first DECISION finding (don't block other modules)

After all modules complete:
  Aggregate DECISION findings
  Present to user in one batch (grouped by theme)
  Apply decisions across all affected modules
  Re-run affected modules one more round
```

This is how we ran 15 parallel reviews — the same pattern, automated.

---

## Example Invocations

**Single module, default depth:**
```
/autoresearch design entitlements
```
Runs CONVERGE with STANDARD depth on the Entitlements design.

**Single module, comprehensive:**
```
/autoresearch prd authentication --comprehensive
```
Runs CONVERGE with COMPREHENSIVE depth on the Authentication PRD.

**All modules in parallel:**
```
/autoresearch design all
```
Runs CONVERGE independently on every design directory found in `docs/designs/`.

**Custom evaluation:**
```
/autoresearch --review-skill ~/skills/skills/review-plan/SKILL.md --doc docs/plans/entitlements/plan.md
```
Runs CONVERGE using a custom review skill on a plan document.

---

## Anti-Patterns

**Spinning Without Escalating** — Running 3+ rounds without escalating DECISION findings to the user. If the same finding persists across 2 rounds, it's almost certainly a DECISION, not a MECHANICAL fix that failed. Escalate after 2 rounds of no progress on a specific finding.

**Fixing WARNs in the Loop** — CONVERGE fixes FAILs only. WARNs are quality improvements, not compliance gaps. Fixing WARNs during the loop wastes rounds and can introduce regressions. Triage WARNs after convergence.

**Modifying the Review Skill** — The evaluation function is FROZEN during the loop. If the review skill produces false positives, stop the loop, fix the skill between runs, then restart. Modifying the skill mid-loop invalidates all prior rounds.

**Fixing Decision Records** — Decision files (`decisions/*.md`) are historical context. They document why a choice was made at a specific point in time. Changing them during cascade fixes rewrites history. Only fix normative files (api-surface, design.md, test plans).

**Guessing on Decisions** — The MECHANICAL vs DECISION classification exists for a reason. When two authoritative documents genuinely conflict (PRD says one thing, ADR says another), the agent cannot determine which is correct — the user must decide. Guessing creates a fix that resolves one conflict while creating another.

**Single-Pass Assumptions** — Expecting convergence in 1 round. Fixes often expose adjacent issues (cascade effect). Budget 2-3 rounds as normal. If round 1 finds 5 FAILs and round 2 finds 3 new FAILs, that's the loop working correctly, not a sign of failure.

---

## Adapting to Other Document Types

The loop works for any document with a review skill:

| Document Type | Review Skill | Frozen Metric |
|--------------|-------------|---------------|
| PRD | /review-prd | FAIL count from Phase 1-4 |
| Technical Design | /review-design | FAIL count from Phase 1-5 |
| Plan | /review-plan (if exists) | FAIL count |
| Any doc with a checklist | Custom review | Checklist pass rate |

The key requirement: the review skill must produce **structured, deterministic findings** with FAIL/WARN/PASS classification. If the review is subjective (no citations, no severity), the loop can't converge.

---

*Skill Version: 1.4 — [Version History](VERSIONS.md)*
