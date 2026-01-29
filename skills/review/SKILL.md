---
name: review
description: Multi-perspective code review using parallel agents. Consolidates findings by severity for user approval. Use when implementation is complete (/execute finished), user says "review", "code review", or "check the code", before creating a PR, or after significant changes.
argument-hint: "[feature-name] or [file paths]"
---

# Review: Parallel Agent Code Review

**Philosophy:** Multiple specialized perspectives catch more issues than single review. Consolidate findings. Self-review before presenting.

## Core Principles

1. **Parallel specialization** - Up to 8 agents with distinct focus areas catch more than one generalist pass
2. **Three-layer context isolation** - Review agents write to files, consolidation agent writes a structured summary to disk, main agent reads only the executive summary (~50 lines) — full findings never enter the conversation context
3. **Severity-driven action** - Deduplicate, sort by criticality, present only actionable findings
4. **Self-review before presenting** - Verify completeness and filter false positives before showing user
5. **Upstream verification** - When design and plan documents exist, verify implementation honours their constraints, intent, and boundaries

---

## Trigger Conditions

Run this skill when:
- Implementation is complete (`/execute` finished)
- User says "review", "code review", or "check the code"
- Before creating a pull request
- After significant changes that warrant a multi-perspective review

Do NOT use for:
- Quick spot checks on a single file (just read it directly)
- Pre-implementation design review (use `/brainstorm`)

---

## Prerequisites

Before starting, verify:
- [ ] All tests pass (run project test command)
- [ ] Build succeeds (run project build command)
- [ ] Changes are committed (not necessarily pushed)

---

## Critical Sequence

### Phase 1: Identify Scope

**Step 1.0 - Resolve Project Root:**

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
echo "Project root: ${PROJECT_ROOT}"
```

All subsequent document paths in this skill use `${PROJECT_ROOT}/docs/` to ensure correct resolution regardless of current working directory.

**Step 1.1 - Find Changed Files:**
```bash
# If comparing to main
git diff main --name-only

# If reviewing recent commits
git log --oneline -10
git diff HEAD~{N} --name-only
```

**Step 1.2 - Gather Context:**
- List all modified files with line counts
- Identify the feature/change being reviewed
- Note any specific concerns

**Step 1.3 - Prepare Agent Context:**
```markdown
## Review Context

**Feature:** {description}
**Files Changed:**
- `path/to/file1.cs` (lines {start}-{end})
- `path/to/file2.cs` (lines {start}-{end})
- ...

**Specific Concerns:**
- {any known issues or areas of uncertainty}
```

**Step 1.4 - Locate Design and Plan Documents:**
Use the feature name identified in Step 1.2 to look for upstream documents:

```bash
# Check for design document
ls "${PROJECT_ROOT}/docs/designs/{feature}/design.md"

# Check for plan document and sub-plans
ls "${PROJECT_ROOT}/docs/plans/{feature}/overview.md"
ls "${PROJECT_ROOT}/docs/plans/{feature}/"
```

Record which documents exist. Each enables a conditional review agent in Phase 2:
- **Design found:** Include the design-intent agent.
- **Plan found:** Include the plan-intent agent.
- **Neither found:** Phase 2 proceeds with the 6 core agents only.

---

### Phase 2: Launch Background Review Agents

**Launch all agents in a single message using Task tool with `run_in_background: true`.** Launch 6 core agents always, plus up to 2 conditional agents (design-intent and/or plan-intent) based on Step 1.4.

This writes each agent's output to a file on disk instead of into the conversation context. This prevents context bloat from up to 8 large reports and ensures no findings are lost to summarization.

| Agent | Focus | Condition |
|-------|-------|-----------|
| `pr-review-toolkit:code-reviewer` | Bugs, logic errors, security vulnerabilities, code quality | Always |
| `code-simplifier:code-simplifier` | Simplification opportunities, DRY violations, unnecessary complexity | Always |
| `pr-review-toolkit:pr-test-analyzer` | Test coverage quality, edge cases, missing tests | Always |
| `pr-review-toolkit:silent-failure-hunter` | Silent failures, swallowed errors, inappropriate fallbacks, missing error propagation | Always |
| `pr-review-toolkit:type-design-analyzer` | Type design, encapsulation, invariant expression, constructor patterns | Always |
| `pr-review-toolkit:comment-analyzer` | Comment accuracy, stale documentation, comment rot, maintainability | Always |
| `general-purpose` (design-intent) | Anti-requirements honoured, trade-offs respected, deferred items not implemented, architecture followed, complexity budget not exceeded | Design doc found |
| `general-purpose` (plan-intent) | All planned components implemented, pseudocode intent followed, failure criteria respected, pattern references honoured, dependencies correct | Plan doc found |

**Agent Prompt Template:**
```
Review the following code changes for {feature description}.

Files changed:
{list of files with line numbers}

Focus on:
- {agent-specific focus from table above}

Rate each finding with criticality (1-10):
- 8-10: Must fix (bugs, security, correctness)
- 5-7: Should consider (code quality, maintainability)
- 1-4: Observation (style, minor improvements)

Return findings in this format:
### Finding {N}
**File:** `path/to/file.cs:line`
**Criticality:** {1-10}
**Issue:** {description}
**Suggestion:** {how to fix}
```

**Design-Intent Agent Prompt Template (only if design document exists):**
```
Review the following code changes against the design document.

Design document: ${PROJECT_ROOT}/docs/designs/{feature}/design.md

Files changed:
{list of files with line numbers}

Read the design document and verify the implementation against these specific sections:

1. **Anti-Requirements** — Verify every "Must NOT" item is absent from the implementation. Flag any violations.
2. **Trade-offs Accepted** — Verify the implementation reflects the trade-offs stated in the design, not different ones.
3. **Deferred Items** — Verify deferred scope was NOT implemented. Flag any scope creep.
4. **Kill Criteria** — Flag if any kill criteria defined in the design are now triggered.
5. **Complexity Budget** — Check the implementation against stated complexity limits.
6. **Chosen Approach** — Verify the implementation follows the chosen approach, not a rejected alternative.
7. **Architecture** — Verify component responsibilities and interfaces match the design.

Rate each finding with criticality (1-10):
- 8-10: Must fix (violates anti-requirements, implements deferred scope, triggers kill criteria)
- 5-7: Should consider (trade-off drift, complexity budget stretch, minor architecture deviation)
- 1-4: Observation (style differs from design intent but not harmful)

Return findings in this format:
### Finding {N}
**File:** `path/to/file.cs:line`
**Design Section:** {which section above}
**Criticality:** {1-10}
**Issue:** {description}
**Design Says:** {relevant quote from design document}
**Suggestion:** {how to align with design}
```

**Plan-Intent Agent Prompt Template (only if plan document exists):**
```
Review the following code changes against the implementation plan.

Plan overview: ${PROJECT_ROOT}/docs/plans/{feature}/overview.md
Sub-plans directory: ${PROJECT_ROOT}/docs/plans/{feature}/

Files changed:
{list of files with line numbers}

Read the plan overview and all sub-plan files (NN-{component}.md). Verify the implementation against these aspects:

1. **Component Completeness** — Verify every component in the task breakdown has a corresponding implementation. Flag missing components.
2. **Pseudocode Intent** — For each sub-plan task, verify the implementation logic matches the pseudocode intent. Flag divergent logic.
3. **Failure Criteria** — Each sub-plan lists anti-patterns to avoid. Verify none are present in the implementation.
4. **Pattern References** — Sub-plans reference existing code patterns to follow. Verify the implementation follows them.
5. **Dependencies** — Verify component dependencies and build order match the plan's dependency graph.
6. **Success Criteria** — Check that observable outcomes listed in the plan are achievable by the implementation.

Rate each finding with criticality (1-10):
- 8-10: Must fix (missing planned component, logic contradicts pseudocode, failure criteria violated)
- 5-7: Should consider (partial pattern adherence, success criteria unclear, dependency order differs)
- 1-4: Observation (minor deviation from plan that doesn't affect correctness)

Return findings in this format:
### Finding {N}
**File:** `path/to/file.cs:line`
**Plan Section:** {which sub-plan and task}
**Criticality:** {1-10}
**Issue:** {description}
**Plan Says:** {relevant quote from plan document}
**Suggestion:** {how to align with plan}
```

**Each agent call returns an `output_file` path. Record all paths (6, 7, or 8) for Phase 3.**

---

### Phase 3: Wait for Agents and Consolidate via Agent

**Step 3.1 - Wait for All Agents:**
Use `Read` or `Bash` with `tail` to check each output file. Wait until all agents (6-8) have completed. You will receive notifications as each background agent finishes.

**Step 3.2 - Launch Consolidation Agent:**
Generate a timestamp for this review session (e.g., `date +%Y%m%d-%H%M%S` → `20250129-143052`).

Launch a single Task agent (subagent_type: `general-purpose`, **`run_in_background: true`**) that reads all output files (6-8) and writes a structured summary to `docs/reviews/review-{timestamp}.md` (e.g., `docs/reviews/review-20250129-143052.md`). Create the `docs/reviews/` directory if it doesn't exist.

The consolidation agent runs in the background so its full output stays on disk. The main agent then selectively reads only the executive summary section, keeping the main conversation context compact.

**Consolidation Agent Prompt Template:**
```
Read the following review agent output files and produce a consolidated review summary.
Write the result to `docs/reviews/review-{timestamp}.md` using the Write tool. Create the directory if needed.

Output files:
- {output_file_1} (code-reviewer)
- {output_file_2} (code-simplifier)
- {output_file_3} (pr-test-analyzer)
- {output_file_4} (silent-failure-hunter)
- {output_file_5} (type-design-analyzer)
- {output_file_6} (comment-analyzer)
- {output_file_7} (design-intent) ← OPTIONAL: only present if a design document was found.
- {output_file_8} (plan-intent) ← OPTIONAL: only present if a plan document was found.

NOTE: The design-intent and plan-intent agents are conditional. Proceed with whichever output files exist (6, 7, or 8).

Consolidation rules:
1. DEDUPLICATE: Same issue flagged by multiple agents counts once. Note which agents flagged it (higher confidence).
2. SORT by severity: Must Fix (8-10), Should Consider (5-7), Observations (1-4).
3. PRESERVE exact file paths and line numbers from the original findings.
4. Keep suggestions actionable and specific.

IMPORTANT: Write the file with this EXACT structure. The executive summary MUST come first
and be self-contained within the first ~50 lines so the main agent can read only that section.

---

# Review Summary

## Executive Summary

**Total Findings:** {count} ({deduplicated from {raw count} raw findings across {6-8} agents)
- 🔴 Must Fix: {count}
- 🟡 Should Consider: {count}
- ⚪ Observations: {count}

### Must Fix (Criticality 8-10)
Issues that MUST be addressed before approval.

| # | File:Line | Issue | Agents |
|---|-----------|-------|--------|
| 1 | `file.cs:123` | {description} | code-reviewer, simplifier |

### Agent Completion Status
| Agent | Findings Count | Completed |
|-------|---------------|-----------|
| {agent name} | {count} | Yes/No |

---

## Full Findings

### Should Consider (Criticality 5-7)
Recommended improvements for code quality.

| # | File:Line | Issue | Suggestion |
|---|-----------|-------|------------|
| 1 | `file.cs:78` | {description} | {suggestion} |

### Observations (Criticality 1-4)
Minor notes, no action required.

- `file.cs:90` - {observation}

---
```

**Step 3.3 - Read Executive Summary Only:**
Once the consolidation agent completes, read only the executive summary section:
```
Read docs/reviews/review-{timestamp}.md with limit: 50
```
This gives you the stats, must-fix table, and agent status without pulling the full report into context. The full findings remain on disk at `docs/reviews/review-{timestamp}.md` for Phase 6.

**Why this three-layer isolation works:**
| Layer | What | Where |
|-------|------|-------|
| Review agents | Raw findings | 6-8 output files (background) |
| Consolidation agent | Deduplicated structured report | `docs/reviews/review-{timestamp}.md` (background) |
| Main agent | Executive summary only | Conversation context (selective read) |

The consolidation agent gets its own fresh context to hold all 6-8 reports. The main agent never reads the full report — only the compact executive summary enters the conversation context. This prevents compaction from losing findings.

---

### Phase 4: Self-Review Findings

**Before presenting, verify:**

```
[ ] All agent results collected
[ ] Findings deduplicated
[ ] Severity ratings are consistent
[ ] Suggestions are actionable
[ ] No false positives included
```

**Cross-reference with docs/learnings/:**
- Check if any findings relate to past learnings
- Note if this reveals a pattern worth documenting

---

### Phase 5: Present to User

Present the executive summary read in Step 3.3. Do NOT read the full findings file into context here.

```markdown
## Code Review Summary

**Feature:** {name}
**Files Reviewed:** {count}
**Review Agents:** code-reviewer, code-simplifier, pr-test-analyzer, silent-failure-hunter, type-design-analyzer, comment-analyzer{, design-intent}{, plan-intent}

{Executive summary from Step 3.3 — stats + must-fix table + agent status}

📄 **Full report:** `docs/reviews/review-{timestamp}.md` (includes Should Consider and Observations)

---

## Recommended Actions

1. **Must Fix items are blocking** - These should be addressed
2. **Should Consider items are in the full report** - Review at `docs/reviews/review-{timestamp}.md`

Select which items to implement:
- "all" - Implement all Must Fix + Should Consider
- "must-fix" - Only implement Must Fix items
- "{numbers}" - Implement specific items (e.g., "1, 3, 5")
- "none" - Skip implementation, changes approved as-is
```

---

### Phase 6: Implement Approved Fixes

**Only implement what user approves.**

**If user selects "all" or "should-consider" items:** Read the full findings from `docs/reviews/review-{timestamp}.md` at this point (offset past the executive summary to the "Full Findings" section). Read only the relevant section — do not load the entire file if only specific items are needed.

**For each approved fix:**

1. **Make the change:**
   - Follow the suggestion exactly
   - Keep changes minimal
   - If detail is needed on a specific finding, read that section from `docs/reviews/review-{timestamp}.md` or the original agent output file

2. **Run tests** (project test command)

3. **Commit:**
   ```bash
   git commit -m "fix: {description from finding}"
   ```

**After all fixes:**
Build, run tests, and push.

---

### Phase 7: Review Cycle Decision

```markdown
## Fixes Implemented

**Changes Made:**
- {list of implemented fixes}

**Tests:** All passing ✅
**Pushed:** ✅

---

Options:
1. "another round" - Run review agents again on new changes
2. "changes approved" - Complete review, ready for /compound
3. Continue with specific concerns
```

**Typical cycle:** 2-3 review rounds until "no significant findings"

---

## Quality Standards

### Agent Usage
- Always use all 6 core agents in parallel with `run_in_background: true`, plus design-intent and/or plan-intent agents when their respective documents exist
- Never do manual review instead of agents
- Provide full context to each agent
- Always use a consolidation agent (`run_in_background: true`) to read output files and write to `docs/reviews/review-{timestamp}.md`
- Never read raw agent output files or the full summary file into the main conversation
- Read only the executive summary (~50 lines) from the summary file into context

### Design & Plan Verification
- When a design document exists (`${PROJECT_ROOT}/docs/designs/{feature}/design.md`), always include the design-intent agent
- When a plan document exists (`${PROJECT_ROOT}/docs/plans/{feature}/overview.md`), always include the plan-intent agent
- Design-intent findings (anti-requirement violations, scope creep, kill criteria) should be treated as Must Fix severity
- Plan-intent findings (missing components, logic contradicting pseudocode, failure criteria violated) should be treated as Must Fix severity

### Findings
- Deduplicate across agents
- Sort by severity
- Make suggestions actionable

### Implementation
- Only implement approved items
- Keep fixes minimal
- Run tests after each fix

### Self-Review
- Verify all agents completed (check Agent Completion Status table in executive summary)
- Check for false positives in consolidated summary
- Cross-reference with learnings
- If detail is needed on a specific finding, read that section from `docs/reviews/review-{timestamp}.md` or the original agent output file (do not load the entire file)

---

## Anti-Patterns

❌ **Running agents in foreground (dumps all output into conversation context)**
```
Launch 6-8 agents → all reports land in context → context bloats → findings lost to summarization
```

❌ **Running consolidation agent in foreground**
```
Consolidation agent (foreground) → full deduplicated report enters context → still too large → compaction → findings lost
```

✅ **Three-layer context isolation**
```
6-8 agents (background) → output files → consolidation agent (background) → docs/reviews/review-{timestamp}.md → main agent reads ONLY executive summary (~50 lines)
```

❌ **Reading raw agent output files directly into the main conversation**
```
# Don't do this — defeats the purpose of background execution
Read output_file_1... Read output_file_2... (all 6-8 reports enter main context)
```

❌ **Reading the full summary file into the main conversation**
```
# Don't do this — the full report can still be large enough to cause compaction
Read docs/reviews/review-{timestamp}.md (entire file enters main context)
```

✅ **Selective reading of executive summary only**
```
# Read only the first ~50 lines (stats + must-fix table + agent status)
Read docs/reviews/review-{timestamp}.md with limit: 50
# Full findings stay on disk, read on-demand during Phase 6
```

❌ **Manual inline review instead of agents**
```
Let me read each file and review it myself...
```

✅ **Always use all applicable agents (6 core + design-intent and/or plan-intent when docs exist)**
```
Each agent catches issues others miss. The consolidation step deduplicates overlap.
```

---

## Exit Signals

| Signal | Meaning |
|--------|---------|
| "another round" | Run agents again |
| "changes approved" | Review complete |
| specific concerns | Address and re-review |

When approved: **"Review complete. Run /compound to capture learnings."**
