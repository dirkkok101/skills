---
name: review
description: Multi-perspective code review using parallel agents. Consolidates findings by severity for user approval. Use when implementation is complete (/execute finished), user says "review", "code review", or "check the code", before creating a PR, or after significant changes.
argument-hint: "[feature-name] or [file paths]"
---

# Review: Parallel Agent Code Review

**Philosophy:** Multiple specialized perspectives catch more issues than single review. Consolidate findings. Self-review before presenting.

## Core Principles

1. **Parallel specialization** - 6 agents with distinct focus areas catch more than one generalist pass
2. **Context isolation** - Agent output stays on disk, not in conversation; a consolidation agent merges results in its own fresh context
3. **Severity-driven action** - Deduplicate, sort by criticality, present only actionable findings
4. **Self-review before presenting** - Verify completeness and filter false positives before showing user

---

## Prerequisites

Before starting, verify:
- [ ] All tests pass (run project test command)
- [ ] Build succeeds (run project build command)
- [ ] Changes are committed (not necessarily pushed)

---

## Critical Sequence

### Phase 1: Identify Scope

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

---

### Phase 2: Launch Background Review Agents

**Launch ALL 6 agents in a single message using Task tool with `run_in_background: true`.**

This writes each agent's output to a file on disk instead of into the conversation context. This prevents context bloat from 6 large reports and ensures no findings are lost to summarization.

| Agent | Focus |
|-------|-------|
| `pr-review-toolkit:code-reviewer` | Bugs, logic errors, security vulnerabilities, code quality |
| `code-simplifier:code-simplifier` | Simplification opportunities, DRY violations, unnecessary complexity |
| `pr-review-toolkit:pr-test-analyzer` | Test coverage quality, edge cases, missing tests |
| `pr-review-toolkit:silent-failure-hunter` | Silent failures, swallowed errors, inappropriate fallbacks, missing error propagation |
| `pr-review-toolkit:type-design-analyzer` | Type design, encapsulation, invariant expression, constructor patterns |
| `pr-review-toolkit:comment-analyzer` | Comment accuracy, stale documentation, comment rot, maintainability |

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

**Each agent call returns an `output_file` path. Record all 6 paths for Phase 3.**

---

### Phase 3: Wait for Agents and Consolidate via Agent

**Step 3.1 - Wait for All Agents:**
Use `Read` or `Bash` with `tail` to check each output file. Wait until all 6 agents have completed. You will receive notifications as each background agent finishes.

**Step 3.2 - Launch Consolidation Agent:**
Launch a single Task agent (subagent_type: `general-purpose`, foreground) that reads all 6 output files and produces a deduplicated, severity-sorted summary.

**Consolidation Agent Prompt Template:**
```
Read the following 6 review agent output files and produce a consolidated review summary.

Output files:
- {output_file_1} (code-reviewer)
- {output_file_2} (code-simplifier)
- {output_file_3} (pr-test-analyzer)
- {output_file_4} (silent-failure-hunter)
- {output_file_5} (type-design-analyzer)
- {output_file_6} (comment-analyzer)

Consolidation rules:
1. DEDUPLICATE: Same issue flagged by multiple agents counts once. Note which agents flagged it (higher confidence).
2. SORT by severity: Must Fix (8-10), Should Consider (5-7), Observations (1-4).
3. PRESERVE exact file paths and line numbers from the original findings.
4. Keep suggestions actionable and specific.

Return the consolidated findings in this exact format:

## Review Findings

### Must Fix (Criticality 8-10)
Issues that MUST be addressed before approval.

| # | File:Line | Issue | Agents |
|---|-----------|-------|--------|
| 1 | `file.cs:123` | {description} | code-reviewer, simplifier |

### Should Consider (Criticality 5-7)
Recommended improvements for code quality.

| # | File:Line | Issue | Suggestion |
|---|-----------|-------|------------|
| 1 | `file.cs:78` | {description} | {suggestion} |

### Observations (Criticality 1-4)
Minor notes, no action required.

- `file.cs:90` - {observation}

### Agent Completion Status
| Agent | Findings Count | Completed |
|-------|---------------|-----------|
| {agent name} | {count} | Yes/No |
```

**Why a consolidation agent instead of inline processing:** The consolidation agent gets its own fresh context, so it can hold all 6 reports without risk of losing detail. Only the compact consolidated summary enters the main conversation context.

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

```markdown
## Code Review Summary

**Feature:** {name}
**Files Reviewed:** {count}
**Review Agents:** code-reviewer, code-simplifier, pr-test-analyzer, silent-failure-hunter, type-design-analyzer, comment-analyzer

### Quick Stats
- 🔴 Must Fix: {count}
- 🟡 Should Consider: {count}
- ⚪ Observations: {count}

---

{Consolidated findings from Phase 3}

---

## Recommended Actions

1. **Must Fix items are blocking** - These should be addressed
2. **Should Consider items are optional** - Your call on each

Select which items to implement:
- "all" - Implement all Must Fix + Should Consider
- "must-fix" - Only implement Must Fix items
- "{numbers}" - Implement specific items (e.g., "1, 3, 5")
- "none" - Skip implementation, changes approved as-is
```

---

### Phase 6: Implement Approved Fixes

**Only implement what user approves.**

**For each approved fix:**

1. **Make the change:**
   - Follow the suggestion exactly
   - Keep changes minimal

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
- Always use all 6 agents in parallel with `run_in_background: true`
- Never do manual review instead of agents
- Provide full context to each agent
- Always use a consolidation agent to read output files (never read raw agent output into the main conversation)

### Findings
- Deduplicate across agents
- Sort by severity
- Make suggestions actionable

### Implementation
- Only implement approved items
- Keep fixes minimal
- Run tests after each fix

### Self-Review
- Verify all agents completed (check Agent Completion Status table)
- Check for false positives in consolidated summary
- Cross-reference with learnings
- If detail is needed on a specific finding, read the original agent output file

---

## Anti-Patterns

❌ **Running agents in foreground (dumps all output into conversation context)**
```
Launch 6 agents → all reports land in context → context bloats → findings lost to summarization
```

✅ **Running agents in background with consolidation agent**
```
Launch 6 agents (run_in_background: true) → output to files → consolidation agent reads files → compact summary enters context
```

❌ **Reading raw agent output files directly into the main conversation**
```
# Don't do this — defeats the purpose of background execution
Read output_file_1... Read output_file_2... (all 6 reports enter main context)
```

✅ **Launching a consolidation agent to read the files**
```
# Consolidation agent has its own fresh context, returns only the compact summary
Task(general-purpose): "Read these 6 output files and produce a deduplicated summary"
```

❌ **Manual inline review instead of agents**
```
Let me read each file and review it myself...
```

✅ **Always use all 6 specialized agents**
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
