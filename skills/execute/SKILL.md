---
name: execute
description: Execute approved beads using sub-agent model. Each bead is a work package - agent loads surgical context, designs, implements, and verifies. Continues until feature complete.
disable-model-invocation: true
argument-hint: "[epic-id] or [feature-name]"
---

# Execute: Beads → Working Code

**Philosophy:** Each bead is a self-contained work package. The executing agent loads surgical context, designs the implementation on-the-fly based on codebase patterns, implements, and verifies. No copy-paste - agents write code by understanding intent.

## Core Principles

1. **Surgical context loading** - Read only what's needed for the current bead
2. **Pattern-based implementation** - Learn from existing code, don't copy from plan
3. **Autonomous execution** - Complete each bead independently
4. **Ask when uncertain** - Don't guess, request clarification
5. **Continuous verification** - Tests confirm correctness

---

## Trigger Conditions

Run this skill when:
- Beads have been approved (`/beads` completed)
- User says "beads approved", "start implementation", "execute"
- Ready beads exist (`br ready` shows tasks)

## Prerequisites

Before starting, verify:
- [ ] Beads exist for the feature (`br ready` shows tasks)
- [ ] Beads have been approved by user
- [ ] All beads assessed as "Ready" during /beads
- [ ] Tests pass before starting: `dotnet test`
- [ ] Build succeeds: `dotnet build`
- [ ] If no beads, run `/beads` first

---

## Sub-Agent Execution Model

Each bead is executed with a "fresh context" mindset - as if by an independent sub-agent. This is a mental model, not literal sub-agent spawning. The same agent executes all beads, but treats each bead as an independent unit.

**Why not literal sub-agents?**
- Same agent can apply learnings across beads
- No spawn overhead
- Maintains continuity for debugging
- Sub-agents would lose CLAUDE.md context

**The trade-off:** Context can accumulate. Mitigate by loading ONLY bead context, not carrying forward previous bead's files.

```
┌─────────────────────────────────────────────────────────────────┐
│                    BEAD EXECUTION CYCLE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. READ BEAD                                                   │
│     └─ Parse: objective, criteria, context references           │
│                                                                 │
│  2. LOAD CONTEXT (surgical)                                     │
│     └─ Read only files listed in "Context to Load"              │
│     └─ Understand patterns from referenced code                 │
│     └─ Check relevant docs/learnings                            │
│     └─ DO NOT load entire plan or design docs                   │
│     └─ DO NOT carry forward previous bead's context             │
│                                                                 │
│  3. DESIGN (on-the-fly)                                         │
│     └─ Plan implementation based on loaded context              │
│     └─ Validate design against bead objectives                  │
│     └─ If uncertain → ASK user, don't guess                     │
│                                                                 │
│  4. IMPLEMENT                                                   │
│     └─ Write code following codebase patterns                   │
│     └─ Apply project standards (CLAUDE.md)                      │
│     └─ Write tests that verify success criteria                 │
│                                                                 │
│  5. VERIFY                                                      │
│     └─ Run specified tests                                      │
│     └─ Run full test suite                                      │
│     └─ All tests must pass                                      │
│                                                                 │
│  6. SELF-REVIEW (per-bead quality gate)                         │
│     └─ Re-read bead objective                                   │
│     └─ Verify implementation achieves objective                 │
│     └─ Check success criteria are met                           │
│     └─ Confirm failure criteria not violated                    │
│     └─ Verify pattern was followed correctly                    │
│     └─ If any concern → FIX before continuing                   │
│                                                                 │
│  7. COMPLETE                                                    │
│     └─ Commit with specified message                            │
│     └─ Close bead                                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Critical Sequence

### Phase 1: Verify Baseline

**Step 1.1 - Identify Available Work:**
```bash
br ready                    # Find available tasks
br dep tree bd-{epic}       # See full feature structure (optional)
```

**Step 1.2 - Verify Baseline:**
```bash
dotnet build && dotnet test
```

If baseline fails, fix issues before proceeding.

**Step 1.3 - Initialize Progress Tracking:**
Use TodoWrite to show overall progress:
```
- [ ] Task 1: {description from br ready}
- [ ] Task 2: {description}
- [ ] Task 3: {description}
```

---

### Phase 2: Execute All Beads

**Loop until all beads complete:**

```
while (br ready shows tasks OR br list --status in_progress shows tasks):
    execute_next_bead()
```

---

#### For Each Bead:

**Step 2.1 - Claim Bead:**
```bash
br ready                              # Get next available bead(s)
br update bd-{bead-id} --status in_progress
```

**Step 2.2 - Read Bead:**
```bash
br show bd-{bead-id}
```

Parse the bead for:
- **Objective** - What to achieve
- **Success Criteria** - How to know it's done
- **Failure Criteria** - What to avoid
- **Context to Load** - Files to read
- **Approach** - Guidance on implementation
- **Verification** - How to test

**Step 2.3 - Load Surgical Context:**

Read ONLY the files specified in the bead's "Context to Load" section:

```bash
# Example from bead:
# - Read: Src/Models/Item.cs - understand existing curse flags
# - Pattern: CursedForOwner property - follow same structure
```

Load these files. Understand the patterns. Do NOT load:
- Entire plan documents
- Design documents (unless referenced)
- Unrelated services

**Step 2.4 - Design Implementation:**

Based on loaded context:
1. Identify the specific change needed
2. Choose the pattern to follow (from referenced code)
3. Plan where to add/modify code
4. Design the test that will verify success criteria

**If uncertain about anything:**
- ASK the user for clarification
- Do NOT guess or improvise beyond the bead's objective
- Explain what's unclear and what options you see

**Step 2.5 - Implement:**

Write code following:
- The pattern from referenced files
- Project standards from CLAUDE.md
- The approach guidance in the bead

**Write test first:**
- Test should verify the success criteria
- Test should check failure criteria aren't violated
- Use project test patterns (TestFactories, CombatTestBase, etc.)

**Then implement:**
- Minimal code to make test pass
- Follow existing patterns exactly
- No additional features beyond objective

**Step 2.6 - Verify (Tests):**

```bash
# Run the specific test
{command from bead's Verification section}

# Run full test suite
dotnet test
```

All tests must pass before proceeding.

**Step 2.7 - Self-Review (Per-Bead Quality Gate):**

Before committing, verify implementation quality:

```markdown
## Per-Bead Self-Review

### Objective Achievement
Re-read the bead objective. Ask: "Does my implementation achieve this?"
- [ ] Objective is fully achieved (not partially)
- [ ] No scope creep (didn't add unrequested features)

### Success Criteria Verification
For each success criterion in the bead:
- [ ] Criterion 1: {how it's met}
- [ ] Criterion 2: {how it's met}

### Failure Criteria Check
For each failure criterion in the bead:
- [ ] ❌ Criterion 1: NOT violated
- [ ] ❌ Criterion 2: NOT violated

### Pattern Adherence
- [ ] Implementation follows the referenced pattern
- [ ] Code style matches existing codebase
- [ ] No foreign patterns introduced

### Quick Quality Check
- [ ] No obvious bugs or logic errors
- [ ] Error handling is appropriate
- [ ] No hardcoded values that should be configurable
```

**If any item fails:** Fix the issue, re-run tests, then re-review.

**If all items pass:** Proceed to commit.

**Step 2.8 - Complete:**

```bash
# Commit with message from bead
git add -A && git commit -m "{commit message from bead}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"

# Close the bead
br close bd-{bead-id}
```

**Step 2.9 - Context Reset & Continue:**

Before starting next bead:
- Clear mental model of previous bead's implementation details
- Do NOT carry forward files loaded for previous bead
- Fresh start with next bead's context only

Update TodoWrite progress. Loop back to Step 2.1 for next ready bead.

---

### Phase 3: Handle Parallel Beads

**When `br ready` shows multiple beads:**

Parallel beads can be executed in any order. Choose based on:
1. Beads labeled `model` before `service`
2. Beads labeled `test` before `integration`
3. Independent beads in any order

Execute each bead fully before moving to the next.

---

### Phase 4: Post-Review Learning Identification

**After fixing issues from review, proactively identify learnings:**

```
For each fix applied:
  1. Was it non-obvious? (took investigation, not a typo)
  2. Would it recur in similar features?
  3. Does it reveal a process/skill/bead gap?

  If YES to any → Add to learnings list
```

**Present learnings to user:**

```markdown
## Review Fixes Complete

Fixed {N} issues from review.

### Learnings Identified

I identified {M} potential learnings worth documenting:

1. **{Topic}** ({learning_type})
   {1-sentence description}

2. **{Topic}** ({learning_type})
   {1-sentence description}

Options:
- "compound all" → Document all learnings
- "compound 1" → Document specific learning
- "skip" → Continue without compounding
- "done" → Finish review cycle
```

**On approval:**
- Run `/compound` for each approved learning
- Agent provides the topic and context (user doesn't need to specify)

**Learning types to look for:**
| Type | Signal |
|------|--------|
| Pattern_Discovery | "I should use this approach elsewhere" |
| Gotcha_Pitfall | "This was non-obvious, would bite someone again" |
| Context_Gap | "The bead should have mentioned this" |
| Process_Improvement | "Our skill/workflow should change" |

---

### Phase 5: Auto-Recovery

**Handle issues automatically before asking user:**

#### Implementation Doesn't Work
```
1. Re-read bead objective and success criteria
2. Re-read context files for correct pattern
3. Check if you deviated from the pattern
4. Check for typos, missing imports
5. Debug: add logging, check intermediate values
6. Fix implementation
7. Re-run tests
```

#### Test Doesn't Pass
```
1. Verify test actually tests the success criteria
2. Check test is using correct assertions
3. Check test setup matches real usage
4. Review failure criteria - did you violate one?
5. Fix test or implementation as appropriate
6. Re-run tests
```

#### Regression (Other Tests Break)
```
1. Identify which test(s) broke
2. Analyze if your change was intentional or accidental
3. If accidental: Fix to not break existing behavior
4. If intentional: The bead should have mentioned this - ask user
5. Re-run full suite
```

#### Auto-Recovery Limit
- Try auto-recovery up to **3 times** per issue type
- If still failing → Stop and ask user (see Phase 5)

---

### Phase 5: Blocker Handling

**Only stop execution for these conditions:**

| Blocker Type | Why It Needs User |
|--------------|-------------------|
| Bead objective is ambiguous | Need clarification on intent |
| Pattern reference doesn't exist | Need alternative pattern |
| Discovered architectural issue | Design decision needed |
| Auto-recovery failed 3 times | Human debugging needed |
| Success criteria conflict with codebase | Need to resolve contradiction |

**When stopping:**
```markdown
⚠️ Blocker Encountered

**Bead:** bd-{id} - {title}
**Objective:** {from bead}
**Issue:** {what's unclear or failing}
**Context Loaded:** {what you read}
**Auto-Recovery Attempts:** {what was tried}

**What I Need:** {specific clarification or decision}

Reply with:
- Clarification/decision, OR
- "skip" to skip this bead and continue, OR
- "stop" to halt execution entirely
```

**After user provides resolution:**
- Apply the guidance
- Resume execution from current bead
- Continue until feature complete

---

### Phase 6: Feature Completion

**When `br ready` shows no beads and no in_progress beads:**

**Step 6.1 - Final Quality Gates:**
```bash
dotnet build && dotnet test
```

**Step 6.2 - Verify All Beads Closed:**
```bash
br list --status open  # Should only show epic
br dep tree bd-{epic}  # All beads should be closed
```

**Step 6.3 - Push All Changes:**
```bash
git push
```
**MANDATORY** - Work is NOT complete until pushed.

**Step 6.4 - Close Epic:**
```bash
br close bd-{epic}
```

**Step 6.5 - Report Completion:**
```markdown
## Execution Complete ✅

**Feature:** {name}
**Epic:** bd-{epic-id}
**Beads Completed:** {N} of {N}
**Commits:** {count}
**Tests:** All passing ✅
**Pushed:** ✅

### Implementation Summary
{Brief description of what was built}

### Commits Made
```
{git log --oneline for this feature's commits}
```

### Files Changed
```
{git diff main --stat}
```

---

**Ready for code review. Run `/review` to start.**
```

---

## Self-Review During Execution

**After each bead:**
```
[ ] Loaded only files specified in bead context
[ ] Implementation follows pattern from referenced code
[ ] Test verifies bead's success criteria
[ ] Failure criteria not violated
[ ] No code beyond bead's objective
[ ] Full test suite passes
[ ] Committed with bead's commit message
[ ] Bead closed
```

**Testing Standards (MANDATORY):**
```
[ ] Test uses pure functions only (no side effects)
[ ] No Godot dependencies in test
[ ] Random behavior uses QueueNextValues() - no `new Random()`
[ ] Test is deterministic
[ ] Uses project test patterns (TestFactories, CombatTestBase)
```

---

## Context Compaction Recovery

**If context was compacted during execution:**

Beads are self-contained. To continue:

1. **Find current bead:**
   ```bash
   br list --status in_progress
   ```

2. **Load bead:**
   ```bash
   br show bd-{bead-id}
   ```

3. **Load surgical context:**
   Read files from bead's "Context to Load" section

4. **Continue execution:**
   Design → Implement → Verify → Complete

**No need to reload plan documents.** Each bead has everything needed.

---

## Resume Capability

**If execution was interrupted:**

```bash
# Find where we left off
br list --status in_progress  # Bead that was being worked on
br ready                       # Beads that can be started

# Resume from in_progress bead
br show bd-{bead-id}
# Load context, continue implementation
```

---

## Quality Standards

### Surgical Context Loading
- Read ONLY files listed in bead
- Understand patterns from context
- Don't load entire plans/designs
- Keep context focused

### Pattern-Based Implementation
- Learn from existing codebase
- Follow referenced patterns exactly
- Write code like the codebase would
- No foreign patterns or styles

### Verification
- Test must verify success criteria
- Check failure criteria not violated
- Full suite must pass
- No regressions allowed

### Asking When Uncertain
- Ask BEFORE implementing if unclear
- Explain what's unclear specifically
- Provide options you're considering
- Don't guess at design decisions

---

## Exit Signals

| Condition | Action |
|-----------|--------|
| All beads complete | Report completion, suggest `/review` |
| Blocker hit | Stop, ask user, resume after resolution |
| User says "stop" | Push current work, report progress |

When all beads complete: **"Feature complete. Run /review to start code review."**
