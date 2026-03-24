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

## Stage Gates — AskUserQuestion

At every PAUSE point in this skill, **call the `AskUserQuestion` tool** to present structured options to the user. Do not present options as plain markdown text — use the tool. The YAML blocks at each PAUSE point show the exact parameters to pass.

For pattern details and examples: `../_shared/references/stage-gates.md`

> **Fallback:** Only if `AskUserQuestion` is not available as a tool (check your tool list), fall back to presenting options as markdown text and waiting for freeform response.

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

Assess scope using BOTH file count AND diff size. If the user hasn't specified a mode:

| Signal | BRIEF | STANDARD | COMPREHENSIVE |
|--------|-------|----------|---------------|
| File count | 1-4 files | 5-19 files | 20+ files |
| Diff size | <200 lines | 200-799 lines | 800+ lines |

Use `max(file_count_mode, diff_size_mode)` as the effective mode. A 200-line change across 3 files is more complex than 10 one-line changes across 10 files.

**Step 1.3 — Locate Upstream Documents:**

Check for the existence of upstream artifacts:
- **Design doc** — `docs/designs/{feature}/design.md` (and feature subdirs `docs/designs/{feature}/features/*/`)
- **Plan** — `docs/plans/{feature}/overview.md`
- **PRD** — `docs/prd/{feature}/prd.md`
- **Discovery brief** — `docs/discovery/{feature}/discovery-brief.md`
- **Browser E2E plans** — `docs/browser-e2e-plans/` (if exists, note in agent prompts for test coverage assessment)

Create the output directory if it doesn't exist: `docs/reviews/`

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

See [references/agent-prompts.md](references/agent-prompts.md) for the full core agent prompt template (shared by all 6 core agents). Each agent receives the same structure with its specific focus area injected. Includes AI slop detection criteria, criticality/confidence rating scale, and finding output format.

**Agent output cap:** Each agent should report at most 15 findings (BRIEF: 10, STANDARD: 15, COMPREHENSIVE: 25). If more exist, keep only the highest-criticality findings and note "N additional findings omitted (highest omitted criticality: X)" at the end.

See [references/agent-prompts.md](references/agent-prompts.md) for the full conditional upstream agent prompt templates:
- **Design-Intent** — Verifies anti-requirements, trade-offs, deferred items, kill criteria, complexity budget, chosen approach, architecture, and ADR consistency.
- **Plan-Intent** — Verifies component completeness, intent followed, failure criteria, pattern references, dependencies, success criteria, and kill criteria.
- **PRD-Compliance** — Verifies FR coverage, acceptance criteria, security/compliance criteria, scope compliance, discovery requirements, and kill criteria.

**Record all output_file paths for Phase 3.**

#### Alignment Audit Agent (COMPREHENSIVE, when 2+ upstream docs exist)

When design, plan, AND PRD all exist, launch an additional alignment audit agent that performs systematic cross-document verification. This produces a permanent audit document (not just review findings).

See [references/agent-prompts.md](references/agent-prompts.md) for the full alignment audit agent prompt. It performs 4 parallel audits (PRD vs Design, Design vs Plan, Plan vs Patterns, Internal Consistency) and writes results to `docs/reference/alignment-audit.md`.

---

### Phase 3: Consolidate Findings

**Step 3.1 — Wait for All Agents:**

You will receive notifications as each background agent finishes. Wait until all have completed.

**Agent Health Check:** If any agent fails, times out, or returns zero findings on a substantial change (20+ files), note the gap in the summary. Do not re-run failed agents automatically — present the gap to the user and let them decide: "The {agent-name} agent failed/timed out. Want me to re-run it, or proceed without?"

**Step 3.2 — Consolidate:**

**BRIEF mode:** Read agent outputs directly. Produce the executive summary inline — no consolidation agent needed.

**STANDARD/COMPREHENSIVE mode:** Launch a single Task agent (`subagent_type: general-purpose`, `run_in_background: true`) that reads all output files and writes to `docs/reviews/review-{timestamp}.md`.

See [references/agent-prompts.md](references/agent-prompts.md) for the full consolidation agent prompt and output template. The consolidation agent deduplicates findings, filters by confidence >= 70, sorts by criticality, classifies each as MECHANICAL ([AUTO-FIX]) or JUDGMENT ([ASK]), and includes a PRAISE section. The executive summary MUST be self-contained within the first ~50 lines of the output file.

**Consolidation Failure Recovery:** If the consolidation agent fails or times out:
1. Retry once with the same prompt
2. If retry fails, read only the first 20 lines of each agent output (finding summaries, not full detail) and produce a minimal executive summary inline
3. Note in the summary: "Consolidation agent failed — summary produced from truncated reading. Full findings require re-running the consolidation agent."

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

**MECHANICAL/JUDGMENT applies within the user's chosen scope:**
- If user selected "Fix all": AUTO-FIX all MECHANICAL findings (Must Fix + Should Consider), then present JUDGMENT findings in batches of 4 via Batch Review (Pattern 3).
- If user selected "Must-fix only": AUTO-FIX MECHANICAL findings at criticality 8-10 only. Present JUDGMENT findings at 8-10 in batches of 4 via Batch Review. Skip everything below 8.
- If user selected "Cherry-pick": Skip the MECHANICAL/JUDGMENT split — present all Should Consider items in batches of 4 as before (user is explicitly choosing).

**Apply [AUTO-FIX] items first** — implement the mechanical fixes within scope, run tests, and commit as a batch. Then present [ASK] items via Batch Review.

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

*Skill Version: 3.7 — [Version History](VERSIONS.md)*
