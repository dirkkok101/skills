---
name: execute
description: >
  Execute approved beads autonomously. Each bead is a self-contained work
  package — the agent loads surgical context, designs the implementation from
  codebase patterns, implements, verifies, and commits. Context resets between
  beads to prevent drift. The agent runs autonomously, only stopping for
  blockers or when all beads are complete. Use when beads are approved, user
  says "execute", "start implementation", or ready beads exist.
argument-hint: "[epic-id] or [feature-name]"
---

# Execute: Beads → Working Code

**Philosophy:** Each bead is a self-contained work package. The agent loads surgical context, designs the implementation from codebase patterns, implements, verifies, and commits — then resets context and moves to the next bead. Beads carry intent, not implementation. The agent writes code by understanding the codebase, not by copying from the bead. Execution is autonomous — the agent runs until all beads are complete or a genuine blocker requires human input.

## Why This Matters

A well-written bead tells the agent what to build and how to verify it. But execution is where the value is delivered — turning intent into working, tested code. The execution loop must be:
- **Autonomous** — the agent completes beads without unnecessary interruption
- **Verifiable** — every change is tested before committing
- **Recoverable** — failures are handled gracefully with rollback and retry
- **Resumable** — interrupted execution can pick up where it left off
- **Context-clean** — each bead starts fresh, preventing drift from accumulated context

---

## Trigger Conditions

Run this skill when:
- Beads have been approved (`/beads` completed)
- User says "beads approved", "start implementation", "execute"
- Ready beads exist (`br ready` shows tasks)

---

## Mode Selection

| Mode | When | Behaviour |
|------|------|-----------|
| **BRIEF** | 3-6 simple beads | Execute all, commit per bead, report at end |
| **STANDARD** | Typical feature | Execute all, self-review per bead, upstream verification, report at end |
| **COMPREHENSIVE** | Multi-service, high-risk | Execute with per-bead user check-in for high-risk beads, full upstream verification |

In COMPREHENSIVE mode, beads tagged as high-risk in the plan get a user check-in after implementation and before committing. All other beads execute autonomously.

---

## Prerequisites

Before starting, verify:
- [ ] Beads exist for the feature (`br ready` shows tasks)
- [ ] Beads have been approved by user
- [ ] All beads assessed as "Ready" during /beads
- [ ] Tests pass before starting (run project test command)
- [ ] Build succeeds (run project build command)
- [ ] If no beads, run `/beads` first

---

## Execution Loop

```
┌─────────────────────────────────────────────────────────────┐
│                    BEAD EXECUTION CYCLE                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. ORIENT                                                   │
│     └─ Read bead: objective, criteria, context refs          │
│     └─ Check progress file for prior state                   │
│                                                              │
│  2. LOAD CONTEXT (surgical)                                  │
│     └─ Read ONLY files listed in "Context to Load"           │
│     └─ Understand patterns from referenced code              │
│     └─ DO NOT load entire plan or design docs                │
│     └─ DO NOT carry forward previous bead's context          │
│                                                              │
│  3. DESIGN (on-the-fly)                                      │
│     └─ Plan implementation based on loaded context           │
│     └─ Choose the pattern to follow from referenced code     │
│     └─ If uncertain → ASK user, don't guess                  │
│                                                              │
│  4. IMPLEMENT                                                │
│     └─ Write tests that verify success criteria              │
│     └─ Write code following codebase patterns                │
│     └─ Apply project standards (CLAUDE.md)                   │
│     └─ Run build after each file change (fail fast)          │
│                                                              │
│  5. VERIFY                                                   │
│     └─ Run bead's verification commands                      │
│     └─ Run full test suite (no regressions)                  │
│     └─ Self-review against success/failure criteria          │
│     └─ Upstream verification (FR acceptance criteria)        │
│                                                              │
│  6. COMMIT                                                   │
│     └─ Stage specific files (not git add -A)                 │
│     └─ Commit with message from bead                         │
│     └─ Close bead in br                                      │
│                                                              │
│  7. RESET                                                    │
│     └─ Update progress tracking                              │
│     └─ Clear mental model of previous bead                   │
│     └─ Start next bead fresh                                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Critical Sequence

### Phase 1: Verify Baseline

**Step 1.1 — Identify Available Work:**
```bash
br ready                    # Find available beads
br dep tree bd-{epic}       # See full feature structure
```

**Step 1.2 — Verify Baseline:**
```bash
{project build command} && {project test command}
```

If baseline fails, fix issues before proceeding. Do not start executing beads on a broken codebase.

**Step 1.3 — Initialise Progress Tracking:**

Use TodoWrite to show overall progress:
```
- [ ] bd-{id}: {title}
- [ ] bd-{id}: {title}
- [ ] bd-{id}: {title}
```

---

### Phase 2: Execute Beads

**Loop until all beads are complete:**

```
while (br ready shows tasks OR br list --status in_progress shows tasks):
    execute_next_bead()
```

#### For Each Bead:

**Step 2.1 — Claim Bead:**
```bash
br ready                              # Get next available bead(s)
br update bd-{bead-id} --status in_progress
```

**Step 2.2 — Orient (Read Bead):**
```bash
br show bd-{bead-id}
```

Parse the bead for:
- **Objective** — what to achieve
- **Success Criteria** — how to know it's done
- **Failure Criteria** — what to avoid
- **Context to Load** — files to read
- **Approach** — guidance on implementation
- **Verification** — how to test
- **In/Out of Scope** — boundaries to respect

**Step 2.3 — Load Surgical Context:**

Read ONLY the files specified in the bead's "Context to Load" section. Understand the patterns. Do NOT load:
- Entire plan or design documents (unless specifically referenced)
- Files from previous beads
- Unrelated services or modules

**Step 2.4 — Design Implementation:**

Based on loaded context:
1. Identify the specific changes needed
2. Choose the pattern to follow (from referenced code)
3. Plan where to add or modify code
4. Design the test that will verify success criteria

**If uncertain about anything:**
- ASK the user for clarification
- Explain what's unclear and what options you see
- Do NOT guess or improvise beyond the bead's objective

**Step 2.5 — Implement:**

**Write tests first:**
- Tests should verify the success criteria
- Tests should check failure criteria aren't violated
- Use project test patterns and conventions (see project CLAUDE.md)

**Then implement:**
- Minimal code to make tests pass
- Follow existing patterns exactly
- No additional features beyond the bead's objective
- Run the build after each file change to catch errors early

**Step 2.6 — Verify:**

```bash
# Run bead-specific tests
{command from bead's Verification section}

# Run full test suite
{project test command}
```

All tests must pass before proceeding.

**Step 2.7 — Self-Review:**

Before committing, verify implementation quality:

```
Per-Bead Self-Review:
- [ ] Re-read bead objective — does the implementation achieve it?
- [ ] Each success criterion met (check specifically)
- [ ] No failure criterion violated (check specifically)
- [ ] No scope creep (nothing added beyond the objective)
- [ ] Implementation follows the referenced pattern
- [ ] Code style matches existing codebase
- [ ] No obvious bugs, hardcoded values, or missing error handling
```

If any item fails, fix the issue, re-run tests, then re-review.

**Step 2.8 — Upstream Verification (STANDARD+):**

After self-review passes, verify against upstream artifacts:

```
- [ ] Read bead's FR references (if present)
- [ ] Verify each FR's acceptance criteria are satisfied
- [ ] Check: do endpoints match API spec? (if API bead)
- [ ] Check: do entities match data model spec? (if data bead)
- [ ] If BDD scenarios exist for referenced UCs, run them
```

Skip this step for infrastructure-only beads with no FR references.

**Step 2.9 — Commit:**

```bash
# Stage specific files (never use git add -A or git add .)
git add {specific files changed}

# Commit with message from bead
git commit -m "{commit message from bead}

Co-Authored-By: Claude <noreply@anthropic.com>"

# Close the bead
br close bd-{bead-id}
```

**Step 2.10 — Context Reset:**

Before starting the next bead:
- Update TodoWrite progress
- Clear mental model of the previous bead's implementation details
- Do NOT carry forward files loaded for the previous bead
- Start the next bead fresh — re-read from Step 2.1

---

### Phase 3: Parallel Beads

**When `br ready` shows multiple beads:**

Parallel beads can be executed in any order. Choose based on:
1. Beads labelled `model` before `service` (data before logic)
2. Beads labelled `test` before `integration`
3. Independent beads in any order

Execute each bead fully (Steps 2.1–2.10) before starting the next.

---

### Phase 4: Auto-Recovery

Handle issues automatically before asking the user. Different errors need different strategies.

**Build Failure:**
```
1. Read the error message carefully
2. Fix the specific error (missing import, type mismatch, etc.)
3. Re-run build
4. If same error persists after 2 fixes → re-read context files for correct pattern
```

**Test Failure:**
```
1. Read the failing test and the assertion message
2. Compare expected vs actual — is the test wrong or the implementation?
3. Fix whichever is incorrect
4. Re-run tests
```

**Regression (Other Tests Break):**
```
1. Identify which test(s) broke and why
2. If your change accidentally broke existing behaviour → fix to preserve it
3. If the change intentionally alters behaviour → the bead should have mentioned this
4. If the bead didn't mention it → ask the user before proceeding
```

**Implementation Doesn't Work:**
```
1. Re-read the bead objective and success criteria
2. Re-read context files for the correct pattern
3. Check if you deviated from the referenced pattern
4. Try a different approach based on the codebase patterns
```

**Recovery Limits:**
- Try auto-recovery up to **3 times** per issue
- After 3 attempts, try a **different approach** (max 2 alternative approaches)
- After exhausting alternatives → escalate to user (Phase 5)

---

### Phase 5: Blocker Handling

**Stop execution only for these conditions:**

| Blocker Type | Why It Needs User |
|--------------|-------------------|
| Bead objective is ambiguous | Need clarification on intent |
| Pattern reference doesn't exist | Need alternative pattern |
| Discovered architectural issue | Design decision needed |
| Auto-recovery exhausted | Human debugging needed |
| Success criteria conflict with codebase | Need to resolve contradiction |

**When stopping:**

```markdown
## Blocker Encountered

**Bead:** bd-{id} — {title}
**Objective:** {from bead}
**Issue:** {what's unclear or failing}
**Context Loaded:** {what you read}
**Recovery Attempts:** {what was tried and why it failed}

**What I Need:** {specific clarification or decision}

Options:
- Provide clarification/decision → I'll resume this bead
- "skip" → Skip this bead, continue with next
- "stop" → Halt execution, push current work
```

After user provides resolution, apply the guidance and resume from the current bead.

---

### Phase 6: Post-Review Learning Identification

**After fixing issues from review, identify learnings:**

For each fix applied:
1. Was it non-obvious? (took investigation, not a typo)
2. Would it recur in similar features?
3. Does it reveal a process, skill, or bead gap?

If YES to any → present to user:

```markdown
## Review Fixes Complete

Fixed {N} issues from review.

### Learnings Identified

{M} potential learnings worth documenting:

1. **{Topic}** ({type: Pattern_Discovery | Gotcha_Pitfall | Context_Gap | Process_Improvement})
   {1-sentence description}

Options:
- "compound all" → Document all learnings via /compound
- "compound 1" → Document specific learning
- "skip" → Continue without documenting
```

---

### Phase 7: Feature Completion

**When `br ready` shows no beads and no in_progress beads:**

**Step 7.1 — Final Quality Gates:**
```bash
{project build command} && {project test command}
```

**Step 7.2 — Verify All Beads Closed:**
```bash
br list --status open      # Should only show epic
br dep tree bd-{epic}      # All beads should be closed
```

**Step 7.3 — Close Epic:**
```bash
br close bd-{epic}
```

**Step 7.4 — Report Completion:**

```markdown
## Execution Complete

**Feature:** {name}
**Epic:** bd-{epic-id}
**Beads Completed:** {N} of {N}
**Tests:** All passing

### Implementation Summary
{Brief description of what was built}

### Commits Made
{git log --oneline for this feature's commits}

### Files Changed
{git diff main --stat}

---

Ready for code review. Run /review to start.
```

**Step 7.5 — Push (with user confirmation):**

Ask the user before pushing:
"Feature complete. Ready to push to remote?"

```bash
git push
```

---

## Context Management

### Between Beads: Reset

Each bead starts with a clean context. After completing a bead:
- Summarise what was done (in the TodoWrite update)
- Do NOT carry forward file contents from the previous bead
- Re-read files from scratch if the next bead references the same files (they may have changed)

### Within a Bead: Stay Focused

- Read only the files listed in the bead's context references
- If you need additional context, check the bead's "Approach" section first
- If still insufficient, check the bead's FR references in the PRD
- Only after exhausting bead-provided references should you explore the codebase independently

### Context Compaction Recovery

If context was compacted mid-execution:

1. Find current bead:
   ```bash
   br list --status in_progress
   ```

2. Load the bead:
   ```bash
   br show bd-{bead-id}
   ```

3. Load surgical context from the bead's "Context to Load" section

4. Continue: Design → Implement → Verify → Commit

Each bead is self-contained — no need to reload plan documents.

### Resume After Interruption

```bash
# Find where we left off
br list --status in_progress    # Bead being worked on
br ready                         # Beads that can be started

# Resume from in_progress bead
br show bd-{bead-id}
# Load context, continue implementation
```

---

## Anti-Patterns

**The One-Shot Attempt** — Trying to implement an entire bead in a single pass without running the build or tests until the end. Run the build after each file change. Catch errors early when the fix is obvious, not after 10 files have been modified.

**Context Hoarding** — Carrying forward file contents, error messages, and implementation details from previous beads. This leads to context rot — accuracy drops as the window fills with stale information. Reset between beads.

**Scope Creep During Execution** — "While I'm here, I'll also fix this adjacent issue." The bead has an "Out of Scope" section for a reason. If you discover adjacent work, note it for a future bead, don't act on it now.

**Guessing at Design Decisions** — When the bead's approach guidance is insufficient, the agent should ask rather than guess. A wrong design decision is far more expensive to fix than a brief pause for clarification.

**Retrying the Same Approach** — When auto-recovery fails, trying the exact same thing again with minor variations. After 3 attempts, fundamentally rethink the approach or escalate.

**Skipping Verification** — Committing without running the full test suite because "my tests pass." Regressions in other tests are just as serious as failures in new tests.

---

## Quality Standards

### Per-Bead Checklist

```
[ ] Loaded only files specified in bead context
[ ] Implementation follows pattern from referenced code
[ ] Tests verify bead's success criteria
[ ] Failure criteria not violated
[ ] No code beyond bead's objective
[ ] Build passes
[ ] Full test suite passes
[ ] Committed with bead's commit message
[ ] Bead closed in br
[ ] Staged specific files (not git add -A)
```

### Testing Standards

```
[ ] Tests use pure functions where possible (no unnecessary side effects)
[ ] Tests are deterministic (no randomness, timing, or external state)
[ ] Tests follow project patterns and conventions (see CLAUDE.md)
[ ] No flaky dependencies (network, filesystem, clock) unless testing those specifically
```

---

## Exit Signals

| Condition | Action |
|-----------|--------|
| All beads complete | Report completion, suggest /review |
| Blocker hit | Stop, ask user, resume after resolution |
| User says "stop" | Commit current work, report progress |

When all beads complete: **"Feature complete. Run /review to start code review."**

---

*Skill Version: 3.0*
*v3: Context reset between beads, mode selection, structured auto-recovery with limits, explicit staging (no git add -A), user confirmation before push, anti-patterns, context management guidance, fixed duplicate phase numbering*
