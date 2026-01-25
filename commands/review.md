---
description: "Multi-perspective code review using parallel agents."
---

# Review: Parallel Agent Code Review

**Philosophy:** Multiple specialized perspectives catch more issues than single review. Consolidate findings. Self-review before presenting.

## Trigger Conditions

Run this skill when:
- Implementation is complete (`/execute` finished)
- User says "review", "code review", "check the code"
- Before creating a PR
- After significant changes

## Prerequisites

Before starting, verify:
- [ ] All tests pass: `dotnet test`
- [ ] Build succeeds: `dotnet build`
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

### Phase 2: Launch Parallel Review Agents

**Launch ALL 6 agents in a single message using Task tool:**

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

---

### Phase 3: Consolidate Findings

**Step 3.1 - Collect All Results:**
Wait for all 6 agents to complete.

**Step 3.2 - Deduplicate:**
- Same issue from multiple agents counts once
- Note when multiple agents flag same issue (higher confidence)

**Step 3.3 - Sort by Severity:**

```markdown
## Review Findings - {date}

### Must Fix (Criticality 8-10)
Issues that MUST be addressed before approval.

| # | File:Line | Issue | Agents |
|---|-----------|-------|--------|
| 1 | `file.cs:123` | {description} | code-reviewer, simplifier |
| 2 | `file.cs:456` | {description} | code-reviewer |

### Should Consider (Criticality 5-7)
Recommended improvements for code quality.

| # | File:Line | Issue | Suggestion |
|---|-----------|-------|------------|
| 1 | `file.cs:78` | {description} | {suggestion} |

### Observations (Criticality 1-4)
Minor notes, no action required.

- `file.cs:90` - {observation}
- `file.cs:102` - {observation}
```

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

2. **Run tests:**
   ```bash
   dotnet test
   ```

3. **Commit:**
   ```bash
   git commit -m "fix: {description from finding}"
   ```

**After all fixes:**
```bash
dotnet build && dotnet test && git push
```

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
- Always use all 6 agents in parallel
- Never do manual review instead of agents
- Provide full context to each agent

### Findings
- Deduplicate across agents
- Sort by severity
- Make suggestions actionable

### Implementation
- Only implement approved items
- Keep fixes minimal
- Run tests after each fix

### Self-Review
- Verify all agents completed
- Check for false positives
- Cross-reference with learnings

---

## Exit Signals

| Signal | Meaning |
|--------|---------|
| "another round" | Run agents again |
| "changes approved" | Review complete |
| specific concerns | Address and re-review |

When approved: **"Review complete. Run /compound to capture learnings."**
