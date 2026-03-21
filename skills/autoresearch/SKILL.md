---
name: autoresearch
description: >
  Autonomous document quality convergence loop. Applies the Karpathy
  autoresearch technique to project documentation: review → fix → re-review
  → re-fix until FAILs reach zero or convergence is detected. Works on PRDs
  (using /review-prd) and technical designs (using /review-design). The
  frozen metric is the FAIL count from the review skill. The "model" being
  optimized is the document itself. Escalates decision-required findings to
  the user instead of spinning. Use when documents need quality convergence,
  user says "autoresearch", "converge", "fix all issues", or after a review
  reveals multiple findings.
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
     error format, auth policy, status codes), grep the entire design directory
     for terms related to the fix before declaring it complete. Example: after
     moving audit from commands to endpoints, search for "audit", "LogAsync",
     "AuditEvent" across all design files to catch stale references.

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
Design api-surface.md (detailed specification)
  ↓
Design diagrams (visual aids — most likely to be stale)
  ↓
Test plans (derived from api-surface — update to match)
  ↓
Use cases (scenario descriptions — update to match design)
  ↓
READMEs (index/summary — most likely to have stale counts)
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

*Skill Version: 1.1*
*v1.1: Progressive loading strategy (3 waves to reduce upfront context cost). JUSTIFIED_DEVIATION classification for pattern/ADR deviations with documented rationale. Cascade check after cross-cutting fixes (grep for related terms). Compact report format for quick convergences. Severity alignment note (review skill wins on FAIL vs WARN). Agent vs direct read guidance. All improvements from first production run on Entitlements module.*

*v1.0: Initial autoresearch convergence loop. Adapted from Karpathy autoresearch + pi-autoresearch (domain-agnostic). Frozen metric = review FAIL count. Mechanical vs decision classification. Authority hierarchy for conflict resolution. Max 5 rounds with revert-on-regression guardrail. Multi-module parallel mode.*
