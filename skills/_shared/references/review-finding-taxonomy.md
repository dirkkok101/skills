# Review Finding Taxonomy

Shared classification model for all review skills (review-beads, review-execute, review-design, review-plan, review-prd). Each skill defines its own finding **classes** (e.g., `MISSING_BEAD`, `AC_NOT_MET`). This reference covers the shared patterns: severity model, fix heuristics, pre-existing drift handling, and finding quality standards.

---

## Severity Model

Every finding gets a **severity**. Two levels, consistently applied across all review skills:

| Severity | Meaning | Gate Effect |
|----------|---------|-------------|
| **FAIL** | Blocks the next pipeline stage (PR, merge, execution) | Must be resolved before proceeding |
| **WARN** | Quality improvement opportunity; does not block | Track for follow-up; may auto-fix if trivial |

### Calibration — Inflation Kills Trust

Be conservative. A review that cries wolf on WARNs or inflates FAILs loses credibility fast. Apply these filters before assigning severity:

**FAIL when:**
- The defect will cause incorrect behavior at runtime (wrong HTTP verb, missing property, broken contract)
- A required artifact is missing entirely (no bead, no test, no implementation)
- An architectural constraint is violated (security, multi-tenancy, CQRS)
- A must-have requirement has zero coverage

**WARN when:**
- The defect is cosmetic or unlikely to cause runtime issues
- The implementation works but deviates slightly from guidance
- A manifest or doc is stale but the code is correct
- Scope creep is minor and additive

### FAIL Examples (Cross-Skill)

- Required coverage gap: a must-have FR, AC, or bead has zero implementation or zero test
- Contract mismatch: implementation uses a different HTTP verb, route, response shape, or property than the spec
- Constraint violation: missing authorization, missing tenant isolation, CQRS violation
- Missing artifact: bead marked complete but core functionality absent; gate bead with no verification commands
- Test gap: success criterion has no corresponding test

### WARN Examples (Cross-Skill)

- Minor scope creep: a helper method or utility added beyond the stated scope
- Stale metadata: manifest claims don't match git state, but code is correct
- Style deviation: implementation follows the intent of a pattern doc but not its exact structure
- Test quality: test exists but uses hardcoded values instead of factories

---

## MECHANICAL vs DECISION Heuristic

Used by CONVERGE mode across review skills to classify findings for auto-fix vs escalation.

| Classification | Criteria | Action |
|---------------|----------|--------|
| **MECHANICAL** | The authoritative source is unambiguous AND the project has a confirming pattern (e.g., another endpoint already uses the correct status code) | Auto-fix |
| **JUSTIFIED_DEVIATION** | Implementation differs from spec with documented rationale | Verify rationale and PASS |
| **DECISION** | Genuine contradiction between sources, missing guidance, or ambiguous design — reasonable people could disagree | Escalate via AskUserQuestion |

### Key Principles

- Even if a fix touches shared types (like adding a new result type), it is MECHANICAL if the design clearly specifies the expected behavior.
- DECISION is reserved for genuine ambiguity — do not use it as a hedge when the answer is clear but the fix is large.
- When in doubt, check the authority hierarchy. If a higher-trust source is unambiguous, the finding is MECHANICAL.

### Authority Hierarchy (Highest to Lowest Trust)

```
ADRs > Pattern docs > Architecture docs > Design (api-surface, data-model) > PRD (FRs, ACs) > Plan > Beads/Implementation
```

When implementation contradicts a higher-trust source, the implementation is wrong — even if the manifest claims it is correct.

---

## Pre-existing vs Introduced

For non-greenfield reviews, design drift or defects may exist in code the current work did NOT modify. Apply this rule:

| Situation | Severity | Tag | Action |
|-----------|----------|-----|--------|
| **Introduced by current work** (file/bead was changed) | Default severity from the skill's class table | — | Fix normally |
| **Pre-existing in unmodified code** | **WARN** regardless of class | `PRE_EXISTING` | Create a `br` issue (p3) for follow-up |
| **Edge case: file was touched but not the drifting code path** | **WARN** | `PRE_EXISTING` | WARN unless the scope explicitly included that code path |

### Rationale

Pre-existing drift was not introduced by the current work. Fixing it may be out of scope and risks unintended side effects. Downgrading to WARN + issue tracking ensures visibility without blocking the current pipeline stage.

### WARN Actionability

Every `PRE_EXISTING` WARN must include exact file:line references for BOTH the code AND the upstream doc that need alignment. Example:

> W1: `UserDTO.cs:45` uses `LinkMethod` but `api-surface.md:112` specifies `LinkedMethod`.

This makes the follow-up issue actionable — the person fixing it does not need to re-discover the mismatch.

---

## Finding Quality Standards

These standards are non-negotiable. Every finding produced by any review skill must meet ALL of them:

1. **Re-read the source artifact** before writing any finding — do not flag based on cached, remembered, or stale content. Re-read the bead (`br show`), the design doc, or the code file.
2. **Read the actual artifact** (code, bead, spec) before writing any finding — do not flag based on file names, manifest claims, or assumptions alone.
3. **Quote the specific defect** — "the code at `{file}:{line}` does X" or "the bead says X" or "the bead omits X."
4. **Cite the authority source** — "bead AC2 says Y" or "api-surface.md line 34 specifies Z."
5. **The issue must cause a concrete problem** — "this means the endpoint returns the wrong shape" or "an agent executing this bead would produce [wrong outcome]."
6. **Verify the finding against current state** — grep/read to confirm before flagging. Do not rely on earlier reads that may be stale after fixes.

### What NOT to Flag (Cross-Skill)

- **Code style issues** in execution reviews — that is `/review`'s job
- **Missing coverage for artifacts outside the review scope** — only verify scoped work
- **Issues in upstream docs** — tag as `UPSTREAM_DOC` and list separately; these are not implementation or bead defects
- **Cosmetic differences from pattern docs** — if the pattern intent is followed, minor structural variations are acceptable
- **Performance or optimization concerns** — unless explicitly required by an AC or FR
- **Redundant transitive references** — if A depends on B and B depends on C, A does not need to explicitly reference C

---

*Referenced by: review-beads, review-execute, review-design, review-plan, review-prd*
