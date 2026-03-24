# CONVERGE Mode — Shared Reference

CONVERGE is the autoresearch convergence loop used by all review skills. It transforms a read-only review into a fix-and-verify cycle that drives findings to zero. Each review skill specifies its OWN progressive loading waves and skill-specific behavior; this document covers the shared pattern.

---

## The Loop

1. **Review** — Run the review at the selected depth. Use progressive loading (Waves 1-3; see skill-specific wave definitions).
2. **Classify** findings into three categories (see Classification below).
3. **Fix** MECHANICAL findings using minimum changes.
   - **Cascade check:** After each fix, search the relevant scope for related terms. Fix cascading references in the same round.
4. **Re-review** — Run the review again on the fixed artifacts.
5. **Compare** — Did FAILs decrease? If FAILs increased, revert the round's changes and stop.
6. **Repeat** until convergence criteria are met (see below).

---

## Classification

Every finding is classified into one of three categories:

| Category | Definition | Action |
|----------|-----------|--------|
| **MECHANICAL** | Unambiguous fix derivable from authority sources — wrong reference, stale count, missing table row, format error, internal contradiction where one side is clearly correct per the authority hierarchy. | Auto-fix. |
| **JUSTIFIED_DEVIATION** | Artifact deviates from convention or authority source but has an explicit, documented rationale. | Verify the rationale is sound. If yes, mark as PASS (not a finding). |
| **DECISION** | Genuine contradiction between authority sources, scope question, architectural choice, or ambiguous design guidance requiring user judgment. | Escalate via AskUserQuestion. |

**MECHANICAL vs DECISION heuristic:** A finding is MECHANICAL when the authority source is unambiguous AND the project has a confirming pattern (e.g., another artifact already uses the correct value). DECISION is reserved for genuine contradictions, missing guidance, or choices where the authority is ambiguous.

---

## Authority Hierarchy

When a mechanical fix requires choosing which source to trust, use this order (highest trust first):

```
ADRs > Pattern docs > Architecture docs > Design (api-surface, data-model) > PRD (FRs, UCs, ACs) > Plan (overview, sub-plans) > Beads > Implementation
```

When a lower-trust source contradicts a higher-trust source, the lower-trust source is wrong.

Each skill may define a more specific hierarchy for its domain. The principle is the same: normative sources outrank derived sources.

---

## Progressive Loading (Waves)

Progressive loading avoids reading all authority sources upfront. Instead, load documents in waves, where each wave targets a narrower set of issues:

| Wave | Purpose | Typical Content |
|------|---------|-----------------|
| **Wave 1** | Catch the majority of findings (~60%+) | Primary artifact + highest-priority authority source |
| **Wave 2** | Targeted loading for beads/areas with findings | Design docs, feature specs, pattern docs referenced by Wave 1 findings |
| **Wave 3** | Broad survey for remaining compliance gaps | Parallel agents for ADR/architecture/pattern sweeps, or deep PRD traceability |

Each review skill defines its own Wave 1/2/3 content. The pattern is universal:
- Wave 1 is cheap and catches most issues.
- Wave 2 is targeted — only load docs relevant to findings from Wave 1.
- Wave 3 is expensive — use agents or deep reads only when needed.

---

## Convergence Criteria

The loop terminates when ANY of these conditions is met:

| Condition | Action |
|-----------|--------|
| **0 FAILs** | Stop. Report PASS (CONVERGED). |
| **Max 5 rounds** | Stop. Report remaining FAILs for user action. |
| **FAILs increased** in a round | Revert that round's changes. Stop. Report. |
| **Same findings for 3 rounds** | Stop. Convergence detected — remaining FAILs are not mechanically fixable. |

After FAILs reach 0, remaining WARNs may be presented to the user as a final batch. Trivial WARNs (additive-only, <10 lines, zero ambiguity) may be auto-fixed alongside FAILs.

---

## CONVERGE Changes to Normal Review Flow

When CONVERGE is active, the following modifications apply to any review skill:

- **Skip interactive stage gates.** CONVERGE implies "just go -- fix what you can, escalate what you can't."
- **Show a findings summary before fixing:** "Found {N} issues: {count} MECHANICAL, {count} DECISION. Fixing MECHANICAL items now." This gives the user visibility before changes are made.
- **Replace per-finding interactive walkthrough** with a classified summary table (MECHANICAL / JUSTIFIED_DEVIATION / DECISION).
- **WARNs are listed** but NOT auto-fixed unless trivial (additive-only, <10 lines).
- **READ-ONLY does not apply** — artifacts are modified directly to fix MECHANICAL findings.

---

## Same-Session Detection

When the artifact under review was created in the current conversation (same agent session), the review has reduced independence:

### Confidence Levels

| Level | Criteria |
|-------|----------|
| **HIGH** | Independent reviewer, fresh context, all authority sources loaded from disk |
| **MODERATE** | Same-session review, non-greenfield artifact with mostly verification tasks |
| **LOW** | Same-session review, same agent, large artifact with many judgment calls |

### Same-Session Mitigations

1. **Flag as same-session** in the review report.
2. **Increase spot-checks** to 5 minimum (vs 3 for independent reviews).
3. **Phase 2 confidence is LOW** — the reviewer shares the generating agent's blind spots.
4. **Re-read authority sources from disk** — do NOT rely on conversation context. Force line-by-line comparison.
5. **Load one authority source the generating agent didn't read** — spot-check 2 claims against it.
6. **For COMPREHENSIVE mode, recommend deferring to a fresh session** — same-session COMPREHENSIVE has limited additional value over STANDARD.

---

## Combining CONVERGE with Review Depth

CONVERGE is a mode modifier, not a depth. It combines with any review depth:

| Invocation | Behavior |
|-----------|----------|
| `CONVERGE` alone | Uses STANDARD depth |
| `CONVERGE + COMPREHENSIVE` | Uses COMPREHENSIVE depth |
| `CONVERGE + BRIEF` | Uses BRIEF depth |

The depth determines WHAT is reviewed. CONVERGE determines WHETHER findings are auto-fixed.

---

## Report Format by Outcome

| Outcome | Report Format |
|---------|--------------|
| **Round 1 = 0 FAILs** | Compact report — verdict, WARN table, one-line per-item status |
| **CONVERGE fixed all FAILs** | Hybrid report — findings table showing what was found AND fixed, plus final PASS verdict. Include fix commits/changes. |
| **FAILs remain after CONVERGE** | Full report with unresolved findings for user action |
| **Quick convergence** (3 or fewer rounds, 10 or fewer findings) | Compact format: `{N} findings -> {N} fixed in {N} rounds. {N} decisions escalated. WARNs: {N} (not fixed).` |
