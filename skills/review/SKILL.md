---
name: review
description: >
  Multi-perspective code review using parallel agents with three-layer context
  isolation. Launches specialised review agents in the background, consolidates
  findings by severity, and presents only actionable results. Conditional
  upstream agents verify implementation against design, plan, and PRD when those
  documents exist. Use when implementation is complete (/execute finished), user
  says "review", "code review", or "check the code", before creating a PR, or
  after significant changes.
argument-hint: "[feature-name] or [file paths]"
---

# Review: Parallel Agent Code Review

**Philosophy:** Multiple specialised perspectives catch more issues than a single review pass. Each agent focuses on a narrow concern — bugs, security, test gaps, silent failures, type design, comment accuracy — and the consolidation step deduplicates and prioritises findings. Three-layer context isolation keeps raw findings on disk, not in the conversation, so nothing is lost to context compaction. When upstream documents exist (design, plan, PRD), conditional agents verify the implementation honours the decisions and requirements that shaped it.

**Duration targets:** BRIEF ~5-10 minutes (3 agents, small scope), STANDARD ~15-30 minutes (6-9 agents, typical feature), COMPREHENSIVE ~30-60 minutes (all agents + re-review rounds). Agent execution is parallel, so duration scales with the slowest agent, not the total count.

## Why This Matters

AI-generated code produces 1.7x more issues per PR than human-written code (CodeRabbit 2025 report). A well-structured review catches 70-80% of issues that would otherwise reach human reviewers, letting them focus on architecture and business logic. The key is specialisation — a security-focused reviewer catches different issues than a test coverage analyser, and running them in parallel means the review takes minutes, not hours.

---

## Trigger Conditions

Run this skill when:
- Implementation is complete (`/execute` finished)
- User says "review", "code review", or "check the code"
- Before creating a pull request
- After significant changes that warrant a multi-perspective review

Do NOT use for:
- Quick spot checks on a single file (just read it directly)
- Pre-implementation design review (use `/brainstorm` or `/technical-design`)

## Stage Gate Reference
For interactive stage gate patterns used at PAUSE points: `../_shared/references/stage-gates.md`
If `AskUserQuestion` is unavailable, fall back to presenting options as markdown text and waiting for freeform response.

---

## Mode Selection

| Mode | When | Agents | Output |
|------|------|--------|--------|
| **BRIEF** | Small changes (1-5 files, single concern) | 3 core agents | Executive summary only (no consolidation agent) |
| **STANDARD** | Typical feature (5-20 files) | 6 core agents + conditional upstream agents | Full review with consolidated report |
| **COMPREHENSIVE** | Large feature, multi-service, pre-release | 6 core agents + conditional upstream agents + second pass | Full review + re-review after fixes |

**BRIEF agents:** code-reviewer, pr-test-analyzer, silent-failure-hunter
**STANDARD agents:** All 6 core agents + design-intent, plan-intent, prd-compliance (when docs exist)
**COMPREHENSIVE agents:** Same as STANDARD, with automatic second round after fixes

---

## Prerequisites

Before starting, verify:
- All tests pass (run project test command)
- Build succeeds (run project build command)
- Changes are committed (not necessarily pushed)

---

## Three-Layer Context Isolation

This is the core architectural pattern of the review skill. It prevents context bloat from large review reports.

| Layer | What | Where | Size |
|-------|------|-------|------|
| Review agents (3-9) | Raw findings | Background output files | Unlimited |
| Consolidation agent | Deduplicated structured report | `docs/reviews/review-{timestamp}.md` | Full report |
| Main agent | Executive summary only | Conversation context | ~50 lines |

The consolidation agent gets its own fresh context to hold all reports. The main agent reads only the compact executive summary. Full findings stay on disk, accessed on-demand during fix implementation.

**BRIEF mode exception:** With only 3 agents and 1-5 files, skip the consolidation agent. Read agent outputs directly and produce the executive summary inline. The overhead of a consolidation agent exceeds the benefit for small reviews.

---

## Critical Sequence

### Phase 1: Identify Scope

**Step 1.1 — Find Changed Files:**

Identify all files changed relative to the base branch (typically main). Gather:
- List of all modified files with line counts
- The feature/change being reviewed
- Any specific concerns from the user

**Step 1.2 — Determine Mode:**

Count changed files and assess scope. If the user hasn't specified a mode:
- 1-5 files, single concern → BRIEF
- 5-20 files, typical feature → STANDARD
- 20+ files, multi-service, or pre-release → COMPREHENSIVE

**Step 1.3 — Locate Upstream Documents:**

Check for the existence of upstream artifacts:
- **Design doc** — `docs/designs/{feature}/design.md` (and feature subdirs `docs/designs/{feature}/features/*/`)
- **Plan** — `docs/plans/{feature}/overview.md`
- **PRD** — `docs/prd/{feature}/prd.md`
- **Discovery brief** — `docs/discovery/{feature}/discovery-brief.md`
- **Browser E2E plans** — `docs/browser-e2e-plans/` (if exists, note in agent prompts for test coverage assessment)

Record which documents exist. Each enables a conditional review agent:
- **Design found:** Include design-intent agent
- **Plan found:** Include plan-intent agent
- **PRD found:** Include prd-compliance agent
- **Browser E2E plans found:** Add to pr-test-analyzer prompt for E2E coverage verification
- **None found:** Proceed with core agents only

---

### Phase 2: Launch Review Agents

**Launch all agents in a single message using Task tool with `run_in_background: true`.**

#### Core Agents (always)

| Agent | Focus |
|-------|-------|
| `pr-review-toolkit:code-reviewer` | Bugs, logic errors, security vulnerabilities, code quality |
| `code-simplifier:code-simplifier` | Simplification, DRY violations, unnecessary complexity |
| `pr-review-toolkit:pr-test-analyzer` | Test coverage quality, edge cases, missing tests |
| `pr-review-toolkit:silent-failure-hunter` | Silent failures, swallowed errors, inappropriate fallbacks |
| `pr-review-toolkit:type-design-analyzer` | Type design, encapsulation, invariant expression |
| `pr-review-toolkit:comment-analyzer` | Comment accuracy, stale documentation, comment rot |

In BRIEF mode, launch only: code-reviewer, pr-test-analyzer, silent-failure-hunter.

#### Conditional Upstream Agents (STANDARD+, when docs exist)

| Agent | Focus | Condition |
|-------|-------|-----------|
| `general-purpose` (design-intent) | Anti-requirements, trade-offs, deferred items, architecture, complexity budget, kill criteria | Design doc found |
| `general-purpose` (plan-intent) | Component completeness, intent followed, failure criteria, pattern references, dependencies, kill criteria | Plan doc found |
| `general-purpose` (prd-compliance) | Must-Have FR coverage, acceptance criteria, security criteria, scope compliance, kill criteria | PRD found |

**Agent Prompt Template (core agents):**
```
Review the following code changes for {feature description}.

Files changed:
{list of files with line numbers}

Focus on:
- {agent-specific focus from table above}

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

**Design-Intent Agent Prompt Template:**
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

**Plan-Intent Agent Prompt Template:**
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

**PRD-Compliance Agent Prompt Template:**
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

**Record all output_file paths for Phase 3.**

#### Alignment Audit Agent (COMPREHENSIVE, when 2+ upstream docs exist)

When design, plan, AND PRD all exist, launch an additional alignment audit agent that performs systematic cross-document verification. This produces a permanent audit document (not just review findings).

**Alignment Audit Agent Prompt:**
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
> **Scope:** PRD ↔ Design ↔ Plan cross-alignment
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

### Phase 3: Consolidate Findings

**Step 3.1 — Wait for All Agents:**

You will receive notifications as each background agent finishes. Wait until all have completed.

**Agent Health Check:** If any agent fails, times out, or returns zero findings on a substantial change (20+ files), note the gap in the summary. Do not re-run failed agents automatically — present the gap to the user and let them decide: "The {agent-name} agent failed/timed out. Want me to re-run it, or proceed without?"

**Step 3.2 — Consolidate:**

**BRIEF mode:** Read agent outputs directly. Produce the executive summary inline — no consolidation agent needed.

**STANDARD/COMPREHENSIVE mode:** Launch a single Task agent (`subagent_type: general-purpose`, `run_in_background: true`) that reads all output files and writes to `docs/reviews/review-{timestamp}.md`.

**Consolidation Agent Prompt:**
```
Read the following review agent output files and produce a consolidated review.
Write the result to ${PROJECT_ROOT}/docs/reviews/review-{timestamp}.md using the Write tool.
Create the directory if needed.

Output files:
- {output_file_1} (code-reviewer)
- {output_file_2} (code-simplifier)
...
- {output_file_N} (prd-compliance) ← conditional

Consolidation rules:
1. DEDUPLICATE: Same issue from multiple agents counts once.
   Note which agents flagged it (more agents = higher confidence).
2. FILTER: Drop findings with confidence < 70.
3. SORT by criticality: Must Fix (8-10), Should Consider (5-7), Observations (1-4).
4. PRESERVE exact file paths and line numbers.
5. Keep suggestions actionable and specific.
6. Include a PRAISE section for well-written code worth highlighting.

Write the file with this EXACT structure. The executive summary MUST come
first and be self-contained within the first ~50 lines.

---

# Review Summary

## Executive Summary

**Total Findings:** {count} (deduplicated from {raw count} across {N} agents)
- Must Fix: {count}
- Should Consider: {count}
- Observations: {count}

### Must Fix (Criticality 8-10)

| # | File:Line | Issue | Confidence | Agents |
|---|-----------|-------|------------|--------|
| 1 | `file:123` | {description} | {0-100} | code-reviewer, simplifier |

### Praise
- `file:45` — {what's well done and why it's worth highlighting}

### Agent Status
| Agent | Findings | Completed |
|-------|----------|-----------|
| {name} | {count} | Yes/No |

---

## Full Findings

### Should Consider (Criticality 5-7)

| # | File:Line | Issue | Suggestion | Confidence |
|---|-----------|-------|------------|------------|
| 1 | `file:78` | {description} | {suggestion} | {0-100} |

### Observations (Criticality 1-4)

- `file:90` — {observation}

---
```

**Step 3.3 — Read Executive Summary Only:**

Read the first ~50 lines of the review file. This gives you the stats, must-fix table, praise, and agent status without pulling the full report into context.

---

### Phase 4: Present to User

Present the executive summary from Step 3.3. Do NOT read the full findings file into context.

```markdown
## Code Review Summary

**Feature:** {name}
**Mode:** {BRIEF | STANDARD | COMPREHENSIVE}
**Files Reviewed:** {count}
**Agents Used:** {list}

{Executive summary from Step 3.3}

Full report: `docs/reviews/review-{timestamp}.md`
```

Then use a **Decision Gate** (Pattern 1) to collect the user's decision:

```
AskUserQuestion:
  question: "How should we handle the review findings?"
  header: "Findings"
  multiSelect: false
  options:
    - label: "Fix all (Recommended)"
      description: "Implement all Must Fix + Should Consider items"
    - label: "Must-fix only"
      description: "Only implement Must Fix (criticality 8-10) items"
    - label: "Cherry-pick"
      description: "I'll select specific Should Consider items to fix."
    - label: "Approved as-is"
      description: "Accept changes without fixes. No issues need addressing."
    - label: "Another round"
      description: "Run review agents again for a fresh perspective"
```

If the user selects "Fix all" or "Must-fix only", proceed to Phase 5.

If the user wants to cherry-pick from Should Consider items, first read the "Should Consider" section from `docs/reviews/review-{timestamp}.md` and present each finding as formatted markdown (file:line, issue, suggestion, confidence) in batches of up to 4. Then use a follow-up **Batch Review** (Pattern 3) multi-select for each batch:

```
AskUserQuestion:
  question: "Which Should Consider items should we fix? (Unselected items are skipped)"
  header: "Items"
  multiSelect: true
  options:
    - label: "{finding #} — {short description}"
      description: "{file:line} — {suggestion}"
    - label: "{finding #} — {short description}"
      description: "{file:line} — {suggestion}"
    ...up to 4 items per batch
```

If more than 4 Should Consider items exist, present them in sequential batches of 4. Unselected items in each batch are skipped.

---

### Phase 5: Implement Approved Fixes

**Only implement what the user approves.**

If the user selects items from the "Should Consider" section, read the relevant portion of `docs/reviews/review-{timestamp}.md` at this point (offset past the executive summary). Read only what's needed — do not load the entire file.

**For each approved fix:**

1. Make the change following the suggestion
2. Keep changes minimal — fix the finding, don't refactor adjacent code
3. Run tests after each fix
4. **Self-review the fix** — before committing, verify:
   - Does the fix address the finding without introducing new issues?
   - Does it follow the project's existing patterns?
   - Are tests still passing (including regressions)?
5. Stage specific files and commit following the project's commit conventions from CLAUDE.md

---

### Phase 6: Review Cycle Decision

Present the fixes implemented summary as formatted markdown:

```markdown
## Fixes Implemented

**Changes Made:**
- {list of implemented fixes}

**Tests:** All passing
**Build:** Succeeds
```

Then use a **Decision Gate** (Pattern 1) to collect the user's decision:

```
AskUserQuestion:
  question: "Fixes applied and tests passing. What next?"
  header: "Review cycle"
  multiSelect: false
  options:
    - label: "Approved (Recommended)"
      description: "Review complete. Proceed to /compound for learnings."
    - label: "Another round"
      description: "Run review agents again on the new changes."
    - label: "Specific concerns"
      description: "I have particular areas I want re-examined."
```

In COMPREHENSIVE mode, automatically run another round after fixes (up to 3 rounds total or until no Must Fix findings remain).

When approved: **"Review complete. Run /compound to capture learnings from this feature."**

---

## Anti-Patterns

**Foreground Agent Execution** — Running review agents in the foreground dumps all reports into the conversation context, causing bloat and lost findings during compaction. Always use `run_in_background: true`. The three-layer isolation exists specifically to prevent this — bypassing it defeats the skill's core architectural pattern.

**Reading Raw Output Files** — Reading agent output files directly into the main conversation defeats the purpose of background execution. Let the consolidation agent read them and produce a structured summary. The exception is BRIEF mode, where the small report size makes direct reading appropriate.

**Reading the Full Summary** — Even the consolidated report can be large. Read only the executive summary (~50 lines) into context. Access full findings on-demand during Phase 5. This discipline is what makes the three-layer pattern work — breaking it cascades into context pressure.

**Manual Review Instead of Agents** — "Let me read each file and review it myself" misses the benefit of parallel specialised perspectives. Always use agents, even for small changes (use BRIEF mode). A single reviewer has blind spots that specialised agents cover.

**No Confidence Filtering** — Presenting every finding regardless of confidence overwhelms the developer with false positives. Filter to confidence >= 70 and let agents self-assess. Low-confidence findings are noise that erodes trust in the review process.

**Auto-Pushing After Fixes** — Pushing should always require user confirmation. The user may want to review the fixes before they're visible to others. The review found issues in the code — fixes for those issues deserve the same scrutiny.

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "another round" | Run agents again | Return to Phase 2 |
| "approved" | Review complete | Proceed to /compound |
| specific concerns | Address and re-review | Target specific areas |

When approved: **"Review complete. Run /compound to capture learnings."**

---

*Skill Version: 3.5*
*v3.5: Design-intent agent scopes feature subdirs. Plan-intent agent receives patterns path. Consolidation agent uses ${PROJECT_ROOT} path. Browser E2E plans noted in upstream doc check and pr-test-analyzer. Cherry-pick option added to findings decision gate. Phase 4 cherry-pick workflow with Batch Review for Should Consider items.*
*v3.4: AskUserQuestion stage gates at Phase 4 (findings decision) and Phase 6 (review cycle decision) using Decision Gate (Pattern 1) and Batch Review (Pattern 3) patterns from `../_shared/references/stage-gates.md`.*
*v3.2: Alignment audit agent for COMPREHENSIVE mode — produces permanent `docs/reference/alignment-audit.md` with systematic PRD ↔ Design ↔ Plan ↔ Patterns cross-verification. Modelled on AMPS actions project's alignment audit (found 11 critical, ~30 medium, ~25 low issues across ~30 files).*
*v3.1: Duration targets, BRIEF mode skips consolidation agent, agent failure/timeout recovery with health check, kill criteria added to plan-intent and prd-compliance agent prompts, self-review step before committing fixes, removed duplicate Quality Standards section, structured PAUSE response options, removed Phase 7 learning identification (handled by execute re-entry and compound), commit format deferred to CLAUDE.md, anti-patterns explain WHY*
