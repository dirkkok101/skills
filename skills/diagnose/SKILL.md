---
name: diagnose
description: >
  Systematic root cause analysis for bugs and unexpected behavior. Investigates,
  isolates, and either fixes simple issues directly or escalates to appropriate
  workflow. Use when something is broken, tests fail unexpectedly, behavior
  doesn't match expectations, user says 'this isn't working', 'there's a bug',
  'why is this happening', 'debug this', or 'diagnose'. Do NOT use for new
  features, performance optimization, or code quality improvements.
argument-hint: "[symptom or issue description]"
---

# Diagnose: Symptom → Root Cause → Resolution

**Philosophy:** Understand WHAT is happening before deciding what to do. Evidence over assumption. Reproduce before theorizing. The right response might be a 5-line fix or a full redesign — diagnosis tells you which.

## Why This Matters

Bugs are the most common interrupt in software development, yet most debugging time is wasted on the wrong hypothesis. Studies show developers spend 35-50% of their time debugging, but the majority of that time goes to understanding the problem, not writing the fix. The fix itself is usually small — the hard part is finding the right place to fix.

AI agents make this worse when they guess instead of investigate. Without a systematic approach, agents attempt shotgun fixes — changing code based on surface symptoms, introducing new bugs, and burning context window on dead ends. A structured diagnostic process prevents this by enforcing evidence collection before any code changes and escalating appropriately when the fix exceeds simple scope.

---

## Trigger Conditions

Run this skill when:
- Something is broken or behaving unexpectedly
- User reports a bug or error
- Tests are failing unexpectedly
- User says "this isn't working", "there's a bug", "why is this happening"
- Behavior doesn't match expectations

Do NOT use for:
- New feature development → `/brainstorm`
- Performance optimization → Different investigation pattern
- Code quality improvements → `/review`

---

## Collaborative Model

```
Phase 0: Context Gathering
Phase 1: Reproduce & Verify
Phase 2: Investigation & Isolation
  ── PAUSE 1: "Isolated the fault. Here's what I found." ──
Phase 3: Root Cause Analysis
Phase 4: Triage Decision
  ── Self-Review gates presentation ──
Phase 5: Resolution (Fix / Beads / Design)
  ── PAUSE 2: "Here's the proposed resolution. Proceed?" ──
```

---

## Critical Sequence

### Phase 0: Context Gathering

**Step 0.1 — Read the Error First:**

Before doing anything else: **read the COMPLETE error message, stack trace, and any linked logs.** Do not pattern-match from the first line. AI agents have a specific failure mode where they see an error, match it to a common cause, and start fixing without reading the full output. Read everything. Then proceed.

**Step 0.2 — Capture the Symptom:**

Ask if not provided:
- **"What's happening?"** (actual behavior)
- **"What did you expect?"** (expected behavior)
- **"When did this start?"** (helps narrow commits)
- **"Does it happen every time?"** (reproducibility)

```markdown
## Symptom Report
**Actual behavior:** {what's happening}
**Expected behavior:** {what should happen}
**First noticed:** {when}
**Reproducibility:** Always / Sometimes / Once
**Error messages:** {if any — quote in full}
```

**Step 0.3 — Quick Context Scan:**

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)

# Recent commits that might be relevant
git log --oneline -15

# Uncommitted changes
git status

# Recent changes in affected area
git log --oneline -10 -- {path/to/affected/area}
```

**Step 0.4 — Check for Known Issues:**

```bash
# Past learnings for similar issues
grep -r "{keywords}" "${PROJECT_ROOT}/docs/learnings/" 2>/dev/null

# If issue tracker available (e.g., br, gh, jira CLI)
# Search for existing issues matching this symptom
```

---

### Phase 1: Reproduce & Verify

**This is the most critical phase. Never skip it.**

**Step 1.1 — Attempt Reproduction:**

```markdown
## Reproduction
**Branch:** {name}
**Commit:** {hash}

### Steps
1. {exact step}
2. {exact step}

### Result
- Expected: {what should happen}
- Actual: {what happens}
- Consistent: Yes / No (frequency: X/10)
```

**Step 1.2 — Verify It's Not Already Fixed:**

```bash
git stash  # if needed
git checkout main
# Run reproduction steps
git checkout -
git stash pop  # if needed
```

**Step 1.3 — Handle Non-Reproducible Issues:**

If you cannot reproduce after 3 genuine attempts:

```markdown
## Non-Reproducible Issue
**Attempts:** {what you tried}
**Possible explanations:**
- Environment-specific
- Timing/race condition
- Data-dependent
- Already fixed in current code

**Recommended:** Ask user for more details, add logging, review for race conditions.
```

Present to user and ask for guidance before proceeding.

---

### Phase 2: Investigation & Isolation

Evidence collection and isolation are iterative — each piece of evidence narrows scope, which tells you what to investigate next. Don't treat them as separate sequential phases.

**Step 2.1 — Launch Parallel Investigation Tracks:**

| Track | Focus | Method |
|-------|-------|--------|
| Code Path | Trace execution flow | Read affected code, follow the flow |
| History | What changed recently | `git log`, `git blame` on affected files |
| Tests | What's passing/failing | Run relevant test suite |
| Dependencies | Related components | Check what the affected code depends on |

**Step 2.2 — Code Path Analysis:**

Use Explore agent to trace execution from entry point through to where behavior diverges from expected.

**Step 2.3 — Git History Analysis:**

```bash
git blame {affected_file} | head -50
git log --oneline -10 -- {affected_path}
git show {suspect_commit} --stat
```

**Step 2.4 — Test Analysis:**

```bash
# Run tests for affected area
{project_test_command} {affected_test_path}
```

Note missing test coverage for the buggy path — this is often a contributing factor.

**Step 2.5 — Narrow Scope Iteratively:**

Start broad, narrow systematically:

```markdown
## Isolation Progress
1. Ruled out {X} → Remaining: {Y}
2. Ruled out {X} → Remaining: {Y}

**Isolated to:** {file}:{function}:{line range}
```

**Step 2.6 — Binary Search Debugging:**

If the fault location isn't obvious:
1. Add logging at midpoint of suspected code
2. Does issue occur before or after this point?
3. Repeat, halving the search space each time

For regressions, use `git bisect`:
```bash
git bisect start
git bisect bad HEAD
git bisect good {known_good_commit}
# Test at each step
```

**Step 2.7 — Minimal Reproducing Case:**

Can you reproduce with fewer steps, simpler input, or mocked dependencies? The minimal case often reveals the root cause.

**Circuit Breaker:** If 3 consecutive investigation steps yield no progress toward narrowing the fault, stop and reconsider. Your hypothesis may be wrong. Step back, review all evidence from scratch, and consider alternative explanations before continuing down the same path.

**Step 2.8 — Document Evidence:**

```markdown
## Evidence

### Code Path
- Entry point: {where execution starts}
- Failure point: {where it goes wrong}
- Flow: A → B → C → [FAILURE] → D

### Git History
**Suspect commits:** {commits that might have introduced issue}

### Test Status
- Passing: {count} | Failing: {count}
- Missing coverage: {areas not tested}

### Dependencies
- Upstream: {what this code depends on}
- Downstream: {what depends on this code}
```

**PAUSE 1:** Present investigation results.
"I've isolated the fault to {file}:{function}. Here's what I found: {evidence summary}. The issue is in {area}, which {matches/differs from} where you expected. Does this align with what you're seeing?"

If non-reproducible (from Phase 1): "I couldn't reproduce this after {N} attempts. Here's what I tried: {summary}. Can you provide more details?"

---

### Phase 3: Root Cause Analysis

**Step 3.1 — The Diagnostic 5 Whys:**

Different from brainstorm's 5 Whys — this asks "why is this happening" not "why build this":

```markdown
## Root Cause Analysis (5 Whys)

**Symptom:** {the bug}

1. Why does {symptom} occur?
   → Because {immediate cause}
2. Why does {immediate cause} happen?
   → Because {deeper cause}
3. Why?
   → Because {even deeper}
4. Why?
   → Because {root cause emerging}
5. Why?
   → Because {ROOT CAUSE}

**Root Cause:** {1-2 sentence summary}
```

Stop when you reach a cause you can act on. Not every issue needs all 5 levels.

**Step 3.2 — Challenge Your Hypothesis:**

Before concluding, actively look for evidence that CONTRADICTS your root cause hypothesis. Ask: "If this were NOT the root cause, what else could explain the symptoms?" If you find contradictory evidence, revise the hypothesis before proceeding.

**Step 3.3 — Classify the Root Cause:**

| Category | Description | Example |
|----------|-------------|---------|
| Logic Error | Code does wrong thing | Off-by-one, wrong condition |
| State Error | Unexpected state | Null, stale data, race condition |
| Integration Error | Components miscommunicate | Wrong API usage, contract violation |
| Configuration Error | Settings wrong | Wrong env var, missing config |
| Data Error | Bad input/data | Corrupt data, edge case input |
| Design Flaw | Architecture problem | Missing abstraction, wrong pattern |

**Step 3.4 — Contributing Factors:**

Root cause is necessary but often not sufficient. What else contributed?

```markdown
| Factor | How It Contributed |
|--------|-------------------|
| {missing test} | Would have caught this |
| {unclear docs} | Led to wrong assumption |
| {recent refactor} | Introduced the regression |
```

---

### Phase 4: Triage Decision

**Step 4.1 — Assess Scope & Complexity:**

| Scope | Description |
|-------|-------------|
| Isolated | Single function/method, <20 lines affected |
| Localized | Single file or tightly coupled set of files |
| Cross-cutting | Multiple components/services affected |
| Systemic | Architectural flaw, affects many areas |

| Complexity | Description |
|------------|-------------|
| Simple | Clear fix, one approach, minimal risk |
| Moderate | Clear fix but touches multiple places |
| Complex | Multiple valid approaches, needs design decisions |
| Uncertain | Root cause unclear or fix approach unknown |

**Step 4.2 — Apply Triage Matrix:**

| Scope | Complexity | → Action |
|-------|------------|----------|
| Isolated | Simple | **Fix-in-Place** |
| Isolated | Moderate | **Fix-in-Place** (with care) |
| Localized | Simple, single file | **Fix-in-Place** |
| Localized | Simple, multiple files | **Targeted Beads** |
| Localized | Moderate | **Targeted Beads** |
| Localized | Complex | **Design Required** |
| Cross-cutting | Any | **Design Required** |
| Systemic | Any | **Design Required** |
| Any | Uncertain | **More Investigation** or **Design Required** |

**Step 4.3 — Self-Review (gates presentation):**

Before presenting the triage and resolution to the user, verify quality:

**Theme 1: Evidence Quality**
- [ ] Symptom documented with actual vs expected?
- [ ] Reproduction verified (or non-reproducibility documented)?
- [ ] Git history and test status checked?

**Theme 2: Isolation Quality**
- [ ] Fault location narrowed to specific area?
- [ ] Ruled out red herrings?

**Theme 3: Root Cause Quality**
- [ ] 5 Whys completed to genuine root cause (not just correlation)?
- [ ] Root cause explains ALL observed symptoms?
- [ ] Hypothesis challenged with counter-evidence search?
- [ ] Contributing factors identified?

**Theme 4: Triage Quality**
- [ ] Triage decision follows the matrix?
- [ ] Scope and complexity honestly assessed (not inflated or deflated)?

If any theme fails, return to the relevant phase before proceeding.

---

### Phase 5a: Fix-in-Place (Simple Bugs)

**When: Isolated scope + Simple/Moderate complexity**

**Step 5a.1 — Write a Failing Test First:**

Before touching the buggy code, write a test that reproduces the bug:

```bash
# Write test that captures the bug
# Run it — it MUST fail (proving it catches the bug)
{project_test_command} {new_test}
```

If you can't write a failing test, reconsider whether you've truly identified the root cause.

**Step 5a.2 — Propose the Fix:**

```markdown
## Proposed Fix

**Summary:** {1-2 sentences}
**Why this fixes it:** {connect fix to root cause}

### Changes
| File | Change |
|------|--------|
| {file} | {what changes} |

### Risk
- Regression risk: Low / Medium / High
- Side effects: {any potential}
```

**PAUSE 2:** Present fix proposal.
"Root cause: {summary}. The fix is {summary}. Risk is {level}. I've written a failing test that captures the bug. Shall I apply the fix?"

**Step 5a.3 — Apply Fix (with approval):**

1. Make the code change
2. Run the regression test — it MUST now pass
3. Run the full relevant test suite
4. Verify the original symptom is resolved
5. Stage specific files and commit:
   ```
   fix: {brief description}

   Root cause: {1 sentence}
   ```

**After fix:** "This might be worth capturing as a learning. Run `/compound`?"

---

### Phase 5b: Targeted Beads (Medium Issues)

**When: Localized scope + multiple files need coordinated changes**

**Step 5b.1 — Save Diagnostic Context:**

Save to `${PROJECT_ROOT}/docs/diagnosis/{issue-slug}.md` so beads can reference it:

```markdown
## Diagnostic Context: {Issue Title}

### Root Cause
{Summary from Phase 3}

### Fix Approach
{High-level approach}

### Affected Files
| File | Required Change |
|------|-----------------|
| {file} | {change needed} |

### Verification
- Regression test: {describe test to write}
- Tests to run: {list}
- Manual verification: {steps}
```

**Step 5b.2 — Create Beads:**

Create focused beads that reference the diagnostic context document. Each bead should include a pointer to the saved diagnosis.

**PAUSE 2:** "Diagnosis saved to `docs/diagnosis/{issue-slug}.md`. Created {N} beads. Run `/execute` to implement the fix."

---

### Phase 5c: Design Required (Complex Issues)

**When: Cross-cutting/Systemic scope OR Complex/Uncertain complexity**

Save diagnostic context to `${PROJECT_ROOT}/docs/diagnosis/{issue-slug}.md`:

```markdown
## Diagnostic Context: {Issue Title}

### Problem Discovered
**Original symptom:** {what user reported}
**Root cause:** {what we found}
**Why design is needed:** {scope/complexity justification}

### Evidence Summary
| Component | How Affected |
|-----------|--------------|
| {name} | {impact} |

### Constraints Discovered
- {constraint from investigation}

### Questions for Design Phase
- {question that emerged}
```

**PAUSE 2:** "This issue needs design work because {reasoning}. Diagnosis saved to `docs/diagnosis/{issue-slug}.md`. Run `/brainstorm` with the diagnostic context?"

---

## Anti-Patterns

**Fixing Symptoms, Not Causes** — Adding a null check to prevent a crash without asking WHY the value is null. The null check masks the real bug, which will surface elsewhere. The 5 Whys exist specifically to push past the immediate symptom to the underlying cause.

**Shotgun Debugging** — Making multiple speculative changes at once ("maybe it's this, and also this, and let me try this"). When the bug goes away, you don't know which change fixed it — and the other changes may introduce new bugs. Change one thing at a time, verify, then proceed.

**Guessing Without Evidence** — "I think the bug is probably in the auth code" based on intuition rather than evidence. Before theorizing, collect data: git blame, logs, reproduction steps. Evidence narrows the search space; guesses expand it.

**Skipping Reproduction** — Jumping straight to code inspection without confirming the bug exists and understanding exactly when it triggers. Without reproduction steps, you can't verify the fix works. If you can't reproduce it, say so and investigate why.

**Over-Engineering the Fix** — A simple off-by-one bug doesn't need a module refactor. Fix the specific issue, verify it, and move on. If the surrounding code needs improvement, that's a separate brainstorm/design effort — don't mix bug fixes with refactoring.

**Premature Escalation** — Routing to "Design Required" before actually isolating the issue. Many bugs that look complex turn out to be simple once isolated. Complete the investigation phase before deciding on triage.

**Confirmation Bias** — Forming a hypothesis early and only looking for evidence that supports it. The most dangerous bugs are the ones that almost match a familiar pattern but have a different root cause. Step 3.2 exists to force a counter-evidence search before concluding.

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| Fix applied | Simple bug resolved | Offer `/compound` for learning |
| Beads created | Medium fix ready | Proceed to `/execute` |
| Design required | Complex issue | Proceed to `/brainstorm` |
| Cannot reproduce | Insufficient info | Ask user for more details |
| Not a bug | Working as designed | Explain behavior to user |
| "park" | Save for later | Document findings, deprioritize |

**Exit message:** "Diagnosis complete. {Resolution summary}."

---

*Skill Version: 3.0*
*v3: PAUSE points repositioned after isolation and before resolution, self-review gates presentation, regression test before fix, confirmation bias guard, error reading discipline, investigation circuit breaker, diagnostic context persistence, merged evidence/isolation phases, tightened anti-patterns, reduced from 907 to ~430 lines*
