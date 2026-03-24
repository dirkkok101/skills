# Review Agent Prompt Templates

Reference file for all agent prompt templates used by the review skill.

---

## Core Agent Prompt Template

Used by: code-reviewer, code-simplifier, pr-test-analyzer, silent-failure-hunter, type-design-analyzer, comment-analyzer.

```
Review the following code changes for {feature description}.

Files changed:
{list of files with line numbers}

Focus on:
- {agent-specific focus from table above}
- AI slop detection: unnecessary wrapper classes with no added behavior, docstrings restating
  the method signature, defensive null checks against structurally impossible states (type
  system guarantees non-null), premature configuration (extracting a constant used once into
  a config file), over-commenting self-evident code

Rate each finding:
- Criticality (1-10): 8-10 must fix, 5-7 should consider, 1-4 observation
- Confidence (0-100): How confident are you this is a real issue?

Only report findings with confidence >= 70.

Return findings in this format:
### Finding {N}
**File:** `path/to/file:line`
**Criticality:** {1-10}
**Confidence:** {0-100}
**Issue:** {description}
**Suggestion:** {how to fix}
```

**Agent output cap:** Each agent should report at most 15 findings (BRIEF: 10, STANDARD: 15, COMPREHENSIVE: 25). If more exist, keep only the highest-criticality findings and note "N additional findings omitted (highest omitted criticality: X)" at the end. This prevents noise flooding while ensuring the consolidation agent knows if important findings were truncated.

---

## Conditional Upstream Agent Prompts

### Design-Intent Agent Prompt Template

```
Review the following code changes against the design document.

Design documents: ${PROJECT_ROOT}/docs/designs/{feature}/ (read design.md and all feature subdirs)

Files changed:
{list of files with line numbers}

Read the design document and verify the implementation against:

1. **Anti-Requirements** — Verify every "Must NOT" item is absent. Flag violations.
2. **Trade-offs Accepted** — Verify the implementation reflects stated trade-offs.
3. **Deferred Items** — Verify deferred scope was NOT implemented. Flag scope creep.
4. **Kill Criteria** — Flag if any kill criteria are now triggered.
5. **Complexity Budget** — Check implementation against stated complexity limits.
6. **Chosen Approach** — Verify implementation follows the chosen approach, not a rejected alternative.
7. **Architecture** — Verify component responsibilities and interfaces match the design.
8. **ADR Consistency** — If any changed files include new or modified ADRs (`docs/adr/`), read ALL existing ADRs and check for contradictions (numbering conflicts, superseded decisions, incompatible approaches). New ADRs that conflict with existing ones are criticality 8-10.

Rate each finding:
- Criticality (1-10): 8-10 violates anti-requirements/implements deferred scope/triggers kill criteria,
  5-7 trade-off drift/complexity stretch, 1-4 minor style deviation
- Confidence (0-100): How confident are you?

Only report findings with confidence >= 70.

Return findings in this format:
### Finding {N}
**File:** `path/to/file:line`
**Design Section:** {which section above}
**Criticality:** {1-10}
**Confidence:** {0-100}
**Issue:** {description}
**Design Says:** {relevant quote}
**Suggestion:** {how to align}
```

### Plan-Intent Agent Prompt Template

```
Review the following code changes against the implementation plan.

Plan overview: ${PROJECT_ROOT}/docs/plans/{feature}/overview.md
Sub-plans directory: ${PROJECT_ROOT}/docs/plans/{feature}/
Patterns directory: ${PROJECT_ROOT}/docs/patterns/ (if exists)

Files changed:
{list of files with line numbers}

Read the plan overview and all sub-plan files. Verify:

1. **Component Completeness** — Every planned component has implementation. Flag missing.
2. **Intent Followed** — Implementation logic matches the plan's intent. Flag divergent logic.
3. **Failure Criteria** — Anti-patterns from sub-plans are absent. Flag violations.
4. **Pattern References** — Implementation follows referenced patterns from sub-plans and docs/patterns/.
5. **Dependencies** — Component dependencies match the plan's dependency graph.
6. **Success Criteria** — Observable outcomes are achievable by the implementation.
7. **Kill Criteria** — Flag if implementation reveals kill criteria are triggered (e.g., scope exceeded, timeline blown).

Rate each finding:
- Criticality (1-10): 8-10 missing component/logic contradiction/failure criteria violated/kill criteria triggered,
  5-7 partial pattern adherence/unclear success criteria, 1-4 minor deviation
- Confidence (0-100): How confident are you?

Only report findings with confidence >= 70.

Return findings in this format:
### Finding {N}
**File:** `path/to/file:line`
**Plan Section:** {sub-plan and task}
**Criticality:** {1-10}
**Confidence:** {0-100}
**Issue:** {description}
**Plan Says:** {relevant quote}
**Suggestion:** {how to align}
```

### PRD-Compliance Agent Prompt Template

```
Review the following code changes against the Product Requirements Document.

PRD: ${PROJECT_ROOT}/docs/prd/{feature}/prd.md
Discovery brief (if exists): ${PROJECT_ROOT}/docs/discovery/{feature}/discovery-brief.md

Files changed:
{list of files with line numbers}

Read the PRD and verify:

1. **FR Coverage** — For each Must-Have FR, verify implementation exists. Flag missing.
2. **Acceptance Criteria** — For each FR's Given/When/Then, verify expected outcomes.
3. **Security Criteria** — For FRs with security criteria, verify actual implementation.
4. **Compliance Criteria** — For FRs with compliance criteria, verify implementation.
5. **Scope Compliance** — Flag implemented features NOT in the PRD. Flag Won't-Have items.
6. **Discovery Requirements** — If discovery brief exists, verify IN SCOPE domain requirements.
7. **Kill Criteria** — Flag if implementation violates or triggers any kill criteria from brainstorm/PRD.

Rate each finding:
- Criticality (1-10): 8-10 Must-Have FR missing/security not enforced/scope creep/kill criteria triggered,
  5-7 Should-Have partially done/compliance gaps, 1-4 Could-Have not done
- Confidence (0-100): How confident are you?

Only report findings with confidence >= 70.

Return findings in this format:
### Finding {N}
**File:** `path/to/file:line`
**Requirement:** {FR/NFR ID}
**Criticality:** {1-10}
**Confidence:** {0-100}
**Issue:** {description}
**PRD Says:** {relevant requirement text}
**Suggestion:** {how to align}
```

---

## Alignment Audit Agent Prompt

Used in COMPREHENSIVE mode when 2+ upstream docs exist. Produces a permanent audit document at `docs/reference/alignment-audit.md`.

```
Perform a systematic cross-document alignment audit for {feature}.

Documents to audit:
- PRD: ${PROJECT_ROOT}/docs/prd/{feature}/prd.md
- Design: ${PROJECT_ROOT}/docs/designs/{feature}/design.md
- Plan overview: ${PROJECT_ROOT}/docs/plans/{feature}/overview.md
- Sub-plans: ${PROJECT_ROOT}/docs/plans/{feature}/*.md

Read ALL documents. Perform 4 parallel audits:

1. **PRD vs Design** — Do design decisions honour all PRD requirements?
   Are NFRs addressed? Are Must-Have FRs all designed?
2. **Design vs Plan** — Does the plan decomposition cover all design
   components? Do sub-plan pseudocode patterns match design specs?
3. **Plan vs Patterns** — Do sub-plan pattern references match actual
   codebase patterns? Are there undocumented deviations?
4. **Internal Consistency** — Naming consistency across all docs? Enum
   values match? Entity fields in plan match design ERD?

For each issue found:
- Classify: Critical (blocks implementation) / Medium (causes confusion) / Low (cosmetic)
- Specify exact locations in both documents
- Provide concrete fix

Write the result to ${PROJECT_ROOT}/docs/reference/alignment-audit.md using
the Write tool. Create the directory if needed.

Use this structure:

---
# Documentation Alignment Audit: {Feature Name}

> **Date:** {date}
> **Scope:** PRD <-> Design <-> Plan cross-alignment
> **Method:** Four parallel audits

## Executive Summary

The documents are **{substantially aligned / partially aligned / misaligned}**.
{N} critical issues, {N} medium issues, {N} low issues.
Critical themes: {1-sentence each}

## Critical Issues ({N})

### C1. {Issue title}
| Location | {doc1 section} vs {doc2 section} |
|----------|---|
| **Impact** | {what goes wrong if not fixed} |
| **Fix** | {concrete resolution} |

## Medium Issues ({N})
{Same format, abbreviated}

## Low Issues ({N})
{One-line each}
---
```

---

## Consolidation Agent Prompt

Used in STANDARD/COMPREHENSIVE mode to deduplicate and structure findings from all review agents.

```
Read the following review agent output files and produce a consolidated review.
Write the result to ${PROJECT_ROOT}/docs/reviews/review-{timestamp}.md using the Write tool.
Create the directory if needed.

Output files:
- {output_file_1} (code-reviewer)
- {output_file_2} (code-simplifier)
...
- {output_file_N} (prd-compliance) <- conditional

Consolidation rules:
1. DEDUPLICATE: Same issue from multiple agents counts once.
   Note which agents flagged it (more agents = higher confidence).
2. FILTER: Drop findings with confidence < 70.
3. SORT by criticality: Must Fix (8-10), Should Consider (5-7), Observations (1-4).
4. CLASSIFY each finding as MECHANICAL or JUDGMENT:
   - MECHANICAL: Dead code, missing import, wrong HTTP verb, stale comment, unused variable,
     missing null check on external input, formatting inconsistency.
     -> Tag as [AUTO-FIX] — these are applied without asking.
   - JUDGMENT: Security concern, race condition, design deviation, architecture question,
     N+1 query fix (may involve architectural choices), test logic correction,
     anything where reasonable people could disagree.
     -> Tag as [ASK] — these are batched for user decision.
   - **When uncertain, classify as JUDGMENT.** False ASK is a minor inconvenience;
     false AUTO-FIX can introduce bugs.
5. PRESERVE exact file paths and line numbers.
6. Keep suggestions actionable and specific.
7. Include a PRAISE section for well-written code worth highlighting.
```

### Consolidation Output Template

```
# Review Summary

## Executive Summary

**Total Findings:** {count} (deduplicated from {raw count} across {N} agents)
- Must Fix: {count}
- Should Consider: {count}
- Observations: {count}

### Must Fix (Criticality 8-10)

| # | Type | File:Line | Issue | Confidence | Agents |
|---|------|-----------|-------|------------|--------|
| 1 | [AUTO-FIX] | `file:123` | {description} | {0-100} | code-reviewer, simplifier |

### Praise
- `file:45` — {what's well done and why it's worth highlighting}

### Agent Status
| Agent | Findings | Completed |
|-------|----------|-----------|
| {name} | {count} | Yes/No |

---

## Full Findings

### Should Consider (Criticality 5-7)

| # | Type | File:Line | Issue | Suggestion | Confidence |
|---|------|-----------|-------|------------|------------|
| 1 | [ASK] | `file:78` | {description} | {suggestion} | {0-100} |

### Observations (Criticality 1-4)

- `file:90` — {observation}
```
