---
name: diagnose
description: Systematic root cause analysis for bugs and unexpected behavior. Investigates, isolates, and either fixes simple issues directly or escalates to appropriate workflow.
argument-hint: "[symptom or issue description]"
---

# Diagnose: Symptom → Root Cause → Resolution

**Philosophy:** Understand WHAT is happening before deciding what to do. Evidence over assumption. Reproduce before theorizing. The right response might be a 5-line fix or a full redesign—diagnosis tells you which.

## Core Principles

1. **Symptom over assumption** - Verify actual behavior before theorizing
2. **Evidence-driven** - Logs, commits, tests, reproduction steps—not guesses
3. **Reproduce first** - If you can't reproduce it, you can't diagnose it
4. **Isolation before explanation** - Narrow scope before root cause analysis
5. **Triage-oriented** - Output tells you exactly what to do next
6. **Minimal intervention** - Fix at the right level, don't over-engineer

---

## Trigger Conditions

Run this skill when:
- Something is broken or behaving unexpectedly
- User reports a bug or error
- Tests are failing unexpectedly
- User says "this isn't working", "there's a bug", "why is this happening"
- Behavior doesn't match expectations

**Do NOT use this skill for:**
- New feature development → Use `/brainstorm`
- Performance optimization → Different investigation pattern
- Code quality improvements → Use `/review`
- "I want to build X" → Use `/brainstorm`

---

## Critical Sequence

### Phase 0: Context Gathering

**Step 0.1 - Capture the Symptom:**

Ask if not provided:
- **"What's happening?"** (actual behavior)
- **"What did you expect?"** (expected behavior)
- **"When did this start?"** (helps narrow commits)
- **"Does it happen every time?"** (reproducibility)

Document in working notes:
```markdown
## Symptom Report

**Actual behavior:** {what's happening}
**Expected behavior:** {what should happen}
**First noticed:** {when}
**Reproducibility:** Always / Sometimes / Once
**Error messages:** {if any}
```

**Step 0.2 - Quick Context Scan:**

```bash
# Recent commits that might be relevant
git log --oneline -15

# Check for uncommitted changes
git status

# If user mentioned specific area, check recent changes there
git log --oneline -10 -- {path/to/affected/area}
```

**Step 0.3 - Check for Known Issues:**

```bash
# Check if there are existing beads for this
br search "{symptom keywords}"

# Check learnings for similar past issues
grep -r "{keywords}" docs/learnings/ 2>/dev/null || echo "No learnings folder"
```

**Verify:**
```
[ ] Symptom clearly documented
[ ] Recent commits reviewed
[ ] No existing work addressing this
[ ] Checked learnings for similar past issues
```

---

### Phase 1: Reproduce & Verify

**This is the most critical phase. Never skip it.**

**Step 1.1 - Attempt Reproduction:**

Document exact steps:
```markdown
## Reproduction Steps

### Environment
- Branch: {branch name}
- Commit: {short hash}
- OS/Platform: {if relevant}
- Configuration: {any relevant settings}

### Steps to Reproduce
1. {exact step}
2. {exact step}
3. {exact step}

### Result
- Expected: {what should happen}
- Actual: {what happens}
- Consistent: Yes / No (if no, frequency: X/10 attempts)
```

**Step 1.2 - Verify It's Not Already Fixed:**

```bash
# Check if main/master has this issue
git stash  # if needed
git checkout main
# Run reproduction steps
git checkout -  # back to original branch
git stash pop  # if needed
```

**Step 1.3 - Handle Non-Reproducible Issues:**

If you cannot reproduce after 3 genuine attempts:

```markdown
## Non-Reproducible Issue

**Attempts made:** {describe what you tried}
**Possible explanations:**
- Environment-specific (user's machine differs)
- Timing/race condition
- Data-dependent (specific input required)
- Already fixed in current code

**Recommended action:**
- [ ] Ask user for more details / screen recording
- [ ] Add logging to capture state when it occurs
- [ ] Review code for potential race conditions
- [ ] Check if user is on latest code
```

Present to user and ask for guidance before proceeding.

---

### Phase 2: Evidence Collection

**Launch parallel investigation tracks:**

| Track | Focus | Method |
|-------|-------|--------|
| **Code Path** | Trace execution flow | Read affected code, understand flow |
| **History** | What changed recently | `git log`, `git blame` on affected files |
| **Tests** | What's passing/failing | Run relevant test suite |
| **Dependencies** | Related components | Check what the affected code depends on |

**Step 2.1 - Code Path Analysis:**

Use Explore agent:
```
"Trace the execution path for {symptom}.
Start from {entry point} and follow through to where {unexpected behavior} occurs.
Document the flow and identify where behavior diverges from expected."
```

**Step 2.2 - Git History Analysis:**

```bash
# Blame the specific file(s) exhibiting the bug
git blame {affected_file} | head -50

# Find commits that touched this area recently
git log --oneline -10 -- {affected_path}

# If you suspect a specific commit
git show {commit_hash} --stat
```

**Step 2.3 - Test Analysis:**

```bash
# Run tests for affected area
{project_test_command} {affected_test_path}

# Check test coverage - is the buggy path tested?
# Look for missing test cases
```

**Step 2.4 - Document Evidence:**

```markdown
## Evidence Collected

### Code Path
- Entry point: {where execution starts}
- Key functions: {list}
- Failure point: {where it goes wrong}
- Flow diagram (if helpful):
  ```
  A → B → C → [FAILURE HERE] → D
  ```

### Git History
| Commit | Date | Author | Change Summary |
|--------|------|--------|----------------|
| {hash} | {date} | {who} | {what changed} |

**Suspect commits:** {commits that might have introduced issue}

### Test Status
- Relevant tests: {list}
- Passing: {count}
- Failing: {count}
- Missing coverage: {areas not tested}

### Dependencies
- Upstream: {what this code depends on}
- Downstream: {what depends on this code}
```

---

### Phase 3: Isolation

**Goal: Narrow down to the smallest reproducing case and exact fault location.**

**Step 3.1 - Scope Reduction:**

Start broad, narrow systematically:

```markdown
## Isolation Progress

### Initial Scope
- Suspected area: {broad area}
- Files involved: {count}

### Narrowing Steps
1. {what you ruled out} → Reduced scope to {remaining}
2. {what you ruled out} → Reduced scope to {remaining}
3. ...

### Isolated Fault Location
- File: {exact file}
- Function/Method: {name}
- Lines: {approximate range}
```

**Step 3.2 - Binary Search Debugging:**

If the fault location isn't obvious:

1. Add logging/breakpoint at midpoint of suspected code
2. Does issue occur before or after this point?
3. Repeat, halving the search space each time

**Step 3.3 - Minimal Reproducing Case:**

Can you reproduce with:
- Fewer steps?
- Simpler input?
- Mocked dependencies?

Document the minimal case—it often reveals the root cause.

---

### Phase 4: Root Cause Analysis

**Step 4.1 - The Diagnostic 5 Whys:**

Different from brainstorm's 5 Whys—this asks "why is this happening" not "why build this":

```markdown
## Root Cause Analysis (5 Whys)

**Symptom:** {the bug/unexpected behavior}

1. Why does {symptom} occur?
   → Because {immediate cause}

2. Why does {immediate cause} happen?
   → Because {deeper cause}

3. Why does {deeper cause} happen?
   → Because {even deeper}

4. Why does {even deeper} happen?
   → Because {root cause emerging}

5. Why does {root cause emerging} exist?
   → Because {ROOT CAUSE}

**Root Cause:** {1-2 sentence summary}
```

**Step 4.2 - Classify the Root Cause:**

| Category | Description | Example |
|----------|-------------|---------|
| **Logic Error** | Code does wrong thing | Off-by-one, wrong condition |
| **State Error** | Unexpected state | Null, stale data, race condition |
| **Integration Error** | Components miscommunicate | Wrong API usage, contract violation |
| **Configuration Error** | Settings wrong | Wrong env var, missing config |
| **Data Error** | Bad input/data | Corrupt data, edge case input |
| **Design Flaw** | Architecture problem | Missing abstraction, wrong pattern |

**Step 4.3 - Identify Contributing Factors:**

Root cause is necessary but often not sufficient. What else contributed?

```markdown
## Contributing Factors

| Factor | How It Contributed |
|--------|-------------------|
| {missing test} | Would have caught this |
| {unclear documentation} | Led to wrong assumption |
| {recent refactor} | Introduced the regression |
```

**Step 4.4 - Check Learnings:**

```bash
# Has this type of issue occurred before?
grep -r "{root cause keywords}" docs/learnings/
```

If similar learning exists, reference it. If not, this might become a new learning.

---

### Phase 5: Triage Decision

**Step 5.1 - Assess Scope:**

```markdown
## Scope Assessment

- [ ] **Isolated** - Single function/method, <20 lines affected
- [ ] **Localized** - Single file or tightly coupled set of files
- [ ] **Cross-cutting** - Multiple components/services affected
- [ ] **Systemic** - Architectural flaw, affects many areas
```

**Step 5.2 - Assess Complexity:**

```markdown
## Fix Complexity

- [ ] **Simple** - Clear fix, one approach, minimal risk
- [ ] **Moderate** - Clear fix but touches multiple places
- [ ] **Complex** - Multiple valid approaches, needs design decisions
- [ ] **Uncertain** - Root cause unclear or fix approach unknown
```

**Step 5.3 - Apply Triage Matrix:**

| Scope | Complexity | → Action |
|-------|------------|----------|
| Isolated | Simple | **Fix-in-Place** |
| Isolated | Moderate | **Fix-in-Place** (with care) |
| Localized | Simple | **Fix-in-Place** or **Targeted Beads** |
| Localized | Moderate | **Targeted Beads** |
| Localized | Complex | **Design Required** |
| Cross-cutting | Any | **Design Required** |
| Systemic | Any | **Design Required** |
| Any | Uncertain | **More Investigation** or **Design Required** |

**Step 5.4 - Document Triage Decision:**

```markdown
## Triage Decision

**Scope:** {isolated/localized/cross-cutting/systemic}
**Complexity:** {simple/moderate/complex/uncertain}
**Decision:** {Fix-in-Place / Targeted Beads / Design Required}

**Rationale:**
{Why this is the right response level}
```

---

### Phase 6a: Fix-in-Place (Simple Bugs)

**Use this path when: Isolated scope + Simple/Moderate complexity**

**Step 6a.1 - Design the Fix:**

```markdown
## Proposed Fix

### Summary
{1-2 sentence description of the fix}

### Changes Required
| File | Change |
|------|--------|
| {file} | {what changes} |

### Why This Fixes It
{Connect fix to root cause}

### Risk Assessment
- Regression risk: Low / Medium / High
- Side effects: {any potential}
- Reversibility: Easy (can revert commit)
```

**Step 6a.2 - Present to User:**

```markdown
## Fix Proposal

**Root Cause:** {summary}
**Proposed Fix:** {summary}

### Code Change
{Show the specific change with context}

**Shall I apply this fix?**
- "yes" / "apply" → Implement the fix
- "modify" → Adjust approach based on feedback
- "escalate" → This needs more design work
```

**Step 6a.3 - Apply Fix (with approval):**

1. Make the code change
2. Run relevant tests
3. Verify the fix resolves the symptom

```bash
# Run tests to verify
{test_command}

# Verify symptom is resolved
# (reproduction steps should no longer trigger the bug)
```

**Step 6a.4 - Post-Fix:**

```markdown
## Fix Applied

**Files changed:** {list}
**Tests passing:** Yes / No
**Symptom resolved:** Yes / No

### Commit Message
```
fix: {brief description}

Root cause: {1 sentence}
Fix: {1 sentence}
```

---

**Learning Opportunity?**

If this bug reveals something worth remembering:
- Pattern that prevents this class of bug
- Gotcha others might hit
- Missing test coverage

→ Offer: "This might be worth capturing. Run `/compound` to document the learning?"
```

---

### Phase 6b: Targeted Beads (Medium Issues)

**Use this path when: Localized scope + Moderate complexity OR clear multi-file fix**

**Step 6b.1 - Document Diagnostic Context:**

```markdown
## Diagnostic Context for Beads

### Root Cause
{Summary from Phase 4}

### Fix Approach
{High-level approach}

### Affected Files
| File | Required Change |
|------|-----------------|
| {file} | {change needed} |

### Verification
- Tests to run: {list}
- Manual verification: {steps}
```

**Step 6b.2 - Create Beads:**

Create focused beads for the fix:

```markdown
## Bead: Fix {specific aspect}

**Objective:** {what this bead accomplishes}

**Context to load:**
- {file to read for context}
- This diagnostic report

**Success criteria:**
- {specific behavior fixed}
- Tests pass: {list}

**Approach:**
{Brief description of fix approach}
```

**Step 6b.3 - Handoff:**

```markdown
## Ready for Execution

Created {N} beads to fix this issue.

**Next step:** Run `/execute` to implement the fix.

**Verification after execution:**
1. {reproduction steps should no longer fail}
2. {tests that should pass}
```

---

### Phase 6c: Design Required (Complex Issues)

**Use this path when: Cross-cutting/Systemic OR Complex/Uncertain**

**Step 6c.1 - Prepare Diagnostic Handoff:**

The diagnosis becomes input to `/brainstorm`. Create a context document:

```markdown
## Diagnostic Context for Design

### Problem Discovered

**Original symptom:** {what user reported}
**Root cause:** {what we found}
**Why design is needed:** {scope/complexity justification}

### Evidence Summary

**Affected areas:**
| Component | How Affected |
|-----------|--------------|
| {name} | {impact} |

**Key findings:**
- {finding 1}
- {finding 2}

### Constraints Discovered

- {constraint from investigation}
- {constraint from investigation}

### Questions for Design Phase

- {question that emerged}
- {approach decision needed}

### Relevant Learnings

| Learning | Relevance |
|----------|-----------|
| {from docs/learnings/} | {how it applies} |
```

**Step 6c.2 - Present Handoff:**

```markdown
## Diagnosis Complete - Design Required

**Root Cause:** {summary}
**Why this needs design:** {reasoning}

This issue is too complex for a direct fix because:
- {reason 1}
- {reason 2}

### Recommended Next Step

Run `/brainstorm` with this context:

"{Feature/fix description based on root cause}"

The diagnostic context above will inform the design phase.

---

**Proceed?**
- "brainstorm" → Start design phase with this context
- "try fix anyway" → Attempt targeted fix (higher risk)
- "park" → Save findings for later
```

---

### Phase 7: Self-Review

**Before presenting findings to user, verify quality.**

**Diagnostic Self-Review Checklist:**

```markdown
## Self-Review

### Evidence Quality
- [ ] Symptom is clearly documented with actual vs expected
- [ ] Reproduction steps are complete and verified
- [ ] Git history reviewed for relevant changes
- [ ] Test status documented

### Isolation Quality
- [ ] Fault location narrowed to specific area
- [ ] Minimal reproducing case identified (if possible)
- [ ] Ruled out red herrings

### Root Cause Quality
- [ ] 5 Whys completed to genuine root cause
- [ ] Root cause explains symptom (not just correlation)
- [ ] Contributing factors identified
- [ ] Checked learnings for similar past issues

### Triage Quality
- [ ] Scope assessment is accurate
- [ ] Complexity assessment is honest
- [ ] Triage decision follows matrix
- [ ] Rationale is documented

### Fix/Handoff Quality
- [ ] (If fix) Change is minimal and targeted
- [ ] (If fix) Risk assessment completed
- [ ] (If escalation) Diagnostic context is complete
- [ ] (If escalation) Questions for next phase are clear
```

---

## Working Document Structure

**During diagnosis (temporary):**

```
.diagnosis/{issue-slug}/
├── notes.md          # Working notes, scratch
├── evidence/         # Screenshots, logs
└── report.md         # Structured findings
```

**After resolution:**
- Delete `.diagnosis/` folder
- If valuable learning: Run `/compound` to capture permanently
- If led to design: `docs/designs/{feature}/` has permanent record

**Note:** Add `.diagnosis/` to `.gitignore` if not already there.

---

## Presentation Templates

### Simple Fix Complete

```markdown
## Bug Fixed

**Symptom:** {original issue}
**Root Cause:** {1 sentence}
**Fix:** {1 sentence}

### Changes Made
- {file}: {change summary}

### Verified
- [x] Reproduction steps no longer trigger bug
- [x] Tests pass

### Commit
`{commit hash}` - {commit message}

---

**Learning opportunity?** If this bug reveals a pattern worth remembering, run `/compound`.
```

### Escalation to Beads

```markdown
## Diagnosis Complete

**Symptom:** {original issue}
**Root Cause:** {summary}
**Scope:** Localized ({N} files affected)

### Fix Approach
{High-level description}

### Beads Created
| Bead | Purpose |
|------|---------|
| {id} | {objective} |

---

**Next:** Run `/execute` to implement the fix.
```

### Escalation to Brainstorm

```markdown
## Diagnosis Complete - Design Required

**Symptom:** {original issue}
**Root Cause:** {summary}

### Why Design Is Needed
{This is too complex for a direct fix because...}

### Key Findings
- {finding}
- {finding}

### Questions for Design
- {question}
- {question}

---

**Next:** Run `/brainstorm {suggested feature description}`

Diagnostic context will inform the design phase.
```

---

## Quality Standards

### Evidence
- Symptom documented with actual vs expected
- Reproduction verified (or non-reproducibility documented)
- Git history and test status checked
- Learnings consulted

### Isolation
- Fault location narrowed systematically
- Binary search or similar technique applied
- Minimal reproducing case sought

### Root Cause
- 5 Whys completed genuinely
- Root cause explains symptom
- Contributing factors identified
- Appropriate category assigned

### Triage
- Scope honestly assessed
- Complexity honestly assessed
- Decision follows matrix
- Rationale documented

### Resolution
- Fix is minimal (no scope creep)
- Risk acknowledged
- Verification completed
- Learning opportunity offered

---

## Anti-Patterns

❌ **Fixing symptoms, not causes**
```
"The null check here prevents the crash"
→ But WHY is it null? That's the real bug.
```

✅ **Fixing root causes**
```
"The object is null because initialization is skipped when X.
Fixed the initialization logic."
```

---

❌ **Guessing without evidence**
```
"I think the bug is probably in the authentication code"
→ Based on what evidence?
```

✅ **Evidence-driven investigation**
```
"Git blame shows auth code changed 3 days ago.
The symptom started appearing after that commit.
Reviewing that change..."
```

---

❌ **Over-engineering the fix**
```
"While fixing this, I also refactored the entire module
and added comprehensive error handling everywhere"
```

✅ **Minimal targeted fix**
```
"Fixed the specific null check that caused the crash.
The broader refactor could be valuable but should be
a separate brainstorm/design effort."
```

---

❌ **Skipping reproduction**
```
"The user says it crashes, let me look at the code..."
→ How will you know when it's fixed?
```

✅ **Reproduce first**
```
"Reproduced the crash with these steps: ...
Now I can verify the fix actually works."
```

---

❌ **Premature escalation**
```
"This seems complicated, let's do a full design"
→ Have you actually isolated the issue?
```

✅ **Appropriate triage**
```
"Isolated to single function, clear fix, low risk.
This is a fix-in-place, no need for design overhead."
```

---

## Exit Signals

| Signal | Meaning | Action |
|--------|---------|--------|
| Fix applied | Simple bug resolved | Offer `/compound` for learning |
| Beads created | Medium fix ready | Proceed to `/execute` |
| Design required | Complex issue | Proceed to `/brainstorm` |
| Cannot reproduce | Insufficient info | Ask user for more details |
| Not a bug | Working as designed | Explain behavior to user |
| Park | Save for later | Document findings, deprioritize |

---

## Integration Points

### → /compound
After any fix, offer learning capture:
- Gotchas discovered
- Missing test coverage identified
- Patterns that prevent this bug class

### → /execute
For targeted beads:
- Pass diagnostic context in bead descriptions
- Include verification criteria

### → /brainstorm
For design-required issues:
- Root cause becomes part of problem statement
- Evidence informs documentation foundation
- Questions identified feed into design exploration

### ← Learnings
Always check `docs/learnings/` for similar past issues:
- Avoids re-diagnosing known problems
- Applies known solutions
- Identifies recurring patterns

---

*Skill version: 1.0*
*Approach: Evidence-driven root cause analysis with adaptive triage*
