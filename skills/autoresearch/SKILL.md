---
name: autoresearch-prd
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

## When to Use

- After `/review-prd` or `/review-design` reveals 3+ findings
- User says "autoresearch", "converge", "fix all issues", "get to zero"
- When manual fix→re-review cycles are taking too long
- When cross-document consistency issues keep cascading

## When NOT to Use

- For a single finding (just fix it directly)
- When findings require architectural decisions (escalate to user first)
- On documents that don't have a corresponding review skill

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

## The Loop

```
SETUP:
  Read the review skill SKILL.md (FROZEN — do not modify)
  Locate the document(s) to optimize
  Load authority sources (PRD, ADRs, patterns, architecture)

ROUND 1:
  1. REVIEW — Run the review skill against the document
     Output: structured findings (FAIL/WARN/PASS counts + details)

  2. CLASSIFY — Split findings into:
     MECHANICAL: wrong heading, stale count, missing section, format error,
                 test case expecting wrong status code, internal contradiction
                 where one side is clearly correct
     DECISION:   PRD vs design conflict where both could be right,
                 ADR contradiction requiring superseding proposal,
                 architectural choice requiring user judgment

  3. FIX — Apply MECHANICAL fixes only
     For each mechanical FAIL:
       - Read the specific file and location
       - Apply the minimum change to resolve the finding
       - Do NOT change surrounding content
       - Do NOT introduce new patterns or restructure
     Record every change made (file, line, what changed, why)

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

### DECISION (escalate to user)

| Finding Type | Example | Why It Needs a Decision |
|-------------|---------|----------------------|
| PRD vs design conflict | PRD says RESTRICT, design says CASCADE | Both documents are authoritative |
| ADR contradiction | Design deviates from ADR without superseding | May need new ADR |
| Architectural choice | OrgMember vs OrgAdmin auth policy | Security implications |
| Cross-module ownership | Which module owns approve/reject routes | Affects multiple designs |
| Missing feature design | Must Have FR has zero design coverage | Scope decision |

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

*Skill Version: 1.0*
*v1.0: Initial autoresearch convergence loop. Adapted from Karpathy autoresearch + pi-autoresearch (domain-agnostic). Frozen metric = review FAIL count. Mechanical vs decision classification. Authority hierarchy for conflict resolution. Max 5 rounds with revert-on-regression guardrail. Multi-module parallel mode.*
