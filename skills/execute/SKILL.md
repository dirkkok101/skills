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

**Duration targets:** BRIEF ~15-30 minutes (3-6 simple beads), STANDARD ~1-3 hours (typical feature), COMPREHENSIVE ~3-8 hours (multi-service, high-risk). These vary widely with feature complexity — the key signal is whether individual beads are completing smoothly, not total elapsed time.

## Why This Matters

A well-written bead tells the agent what to build and how to verify it. But execution is where the value is delivered — turning intent into working, tested code. The execution loop must be:
- **Autonomous** — the agent completes beads without unnecessary interruption
- **Verifiable** — every change is tested before committing
- **Recoverable** — failures are handled gracefully with rollback and retry
- **Resumable** — interrupted execution can pick up where it left off
- **Context-clean** — each bead starts with fresh context, preventing drift from accumulated state

---

## Trigger Conditions

Run this skill when:
- Beads have been approved (`/beads` completed)
- User says "beads approved", "start implementation", "execute"
- Ready beads exist in the issue tracker

## Stage Gates — AskUserQuestion

At every PAUSE point in this skill, **call the `AskUserQuestion` tool** to present structured options to the user. Do not present options as plain markdown text — use the tool. The YAML blocks at each PAUSE point show the exact parameters to pass.

For pattern details and examples: `../_shared/references/stage-gates.md`

> **Fallback:** Only if `AskUserQuestion` is not available as a tool (check your tool list), fall back to presenting options as markdown text and waiting for freeform response.

---

## Mode Selection

| Mode | When | Behaviour |
|------|------|-----------|
| **BRIEF** | 3-6 simple beads | Execute all, commit per bead, report at end |
| **STANDARD** | Typical feature | Execute all, self-review per bead, upstream verification, report at end |
| **COMPREHENSIVE** | Multi-service, high-risk | Execute with per-bead user check-in for high-risk beads, full upstream verification |

In COMPREHENSIVE mode, beads tagged as high-risk in the plan get a user check-in after implementation and before committing. Present the implementation summary and use AskUserQuestion (Decision Gate — Pattern 1) with options: "Approve & commit", "Modify", "Escalate". All other beads execute autonomously.

---

## Collaborative Model

```
Phase 1: Verify Baseline
Phase 2: Execute Beads (loop until all complete)
  ├─ Implementation beads: Orient → Load → Design → Implement → Verify → Commit → Reset
  ├─ Review beads: Run /simplify on changed files → Fix issues → Commit → Reset
  └─ (if blocker) PAUSE: "Blocker encountered. How to proceed?"
Phase 3: Blocker Handling (as needed)
Phase 4: Feature Completion
  ── PAUSE: "Feature complete. Ready to push?" ──
```

---

## Prerequisites

Before starting, verify:
- Beads exist for the feature and have been approved by user
- All beads assessed as "Ready" during /beads
- Tests pass before starting (run project test command)
- Build succeeds (run project build command)
- If no beads exist, run `/beads` first

---

## Execution Loop

```
┌─────────────────────────────────────────────────────────────┐
│                    BEAD EXECUTION CYCLE                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. ORIENT                                                   │
│     └─ Read bead: objective, criteria, context refs          │
│     └─ Check progress for prior state                        │
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
│     └─ Close bead in issue tracker                           │
│                                                              │
│  7. SUMMARISE & RESET                                        │
│     └─ Record what was done for this bead                    │
│     └─ Update progress tracking                              │
│     └─ Clear mental model of previous bead                   │
│     └─ Check execution health                                │
│     └─ Start next bead fresh                                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Critical Sequence

### Phase 1: Verify Baseline

**Step 1.1 — Identify Available Work:**

Query the issue tracker for ready beads and the feature's dependency tree. Confirm the expected beads exist and are in the right order.

**Step 1.2 — Verify Baseline:**

Run the project's build and test commands. If baseline fails, fix issues before proceeding. Do not start executing beads on a broken codebase.

**Step 1.3 — Initialise Progress Tracking:**

Track overall progress so you (and the user) can see what's been completed and what remains. Use whatever progress mechanism is available (TodoWrite, comments, etc.).

---

### Phase 2: Execute Beads

**Loop until all beads are complete.**

When multiple beads are ready simultaneously (no dependency between them), they can be executed in any order. Prefer: data model beads before service beads, service beads before integration beads. Execute each bead fully before starting the next.

**Review beads:** When the next bead is a `/simplify` review bead (tagged `review`), execute it by running `/simplify` on all files changed since the last review checkpoint. Fix any issues found, commit with `refactor({scope}): simplify {what}`, then close the review bead and proceed to the next implementation bead.

#### For Each Bead:

**Step 2.1 — Verify Module is Unblocked:**

Before starting any bead, check if its module epic has upstream dependencies:
```bash
br dep tree bd-{module-epic}  # Check if upstream epics are closed
```

If the module epic depends on unclosed upstream epics, do NOT start work on this module.
Pick a bead from an unblocked module instead.

The dependency map at docs/plans/dependency-map.md shows the tier ordering.

**Step 2.1a — Claim Bead:**

Mark the next available bead as in-progress to track state.

**Step 2.2 — Orient (Read Bead):**

Read the full bead description and parse:
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

**Step 2.3a — Load Module Specs (first bead in module only):**

When starting the FIRST bead in a module, also read:
1. `docs/designs/{module}/design.md` — technical design overview
2. `docs/designs/{module}/data-model.md` — entity specifications (if exists)
3. `docs/designs/{module}/features/{feature}/api-surface.md` — endpoint specs (if referenced by bead)
4. `docs/prd/{module}/prd.md` — requirements (skim for referenced FRs)

For subsequent beads in the same module, these are already in context.
Do NOT re-read these on every bead — only on the first bead or after context compaction.

**Lookup order for specs:**
```
docs/designs/{module}/           — technical design (source of truth for HOW)
docs/prd/{module}/               — requirements (source of truth for WHAT)
docs/adr/                        — architectural decisions (source of truth for WHY)
docs/patterns/                   — coding patterns (source of truth for STYLE)
docs/architecture/               — system architecture (source of truth for CONSTRAINTS)
```

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

**Step 2.5a — Checkpoint (for large beads):**

If a bead involves modifying more than 3 files, checkpoint after each file:
```bash
git stash push -m "checkpoint: bd-{id} - {filename}"
```

This prevents total work loss on crash. After all files are done,
pop the stashes and make a single clean commit.

For smaller beads (1-3 files), skip checkpointing — just implement and commit.

**Step 2.6 — Verify:**

Run the bead's specific verification commands, then run the full test suite. All tests must pass before proceeding.

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
- [ ] Tests verify application logic, not framework guarantees
- [ ] Tests use the project's test infrastructure (check existing test files for patterns)
- [ ] Tests are deterministic (no random, no time-dependent assertions)
- [ ] No object serialization in log messages
- [ ] Integration tests use the project's test factory/fixture patterns
- [ ] Run both the specific test AND the full suite before committing
- [ ] Staged specific files (not git add -A)

### Design & Spec Alignment
- [ ] Implementation matches the module's design doc (api-surface, data-model)
- [ ] Implementation satisfies the PRD functional requirements (FRs referenced in bead)
- [ ] All referenced ADRs are followed (check docs/adr/)
- [ ] Patterns from docs/patterns/ are applied correctly
- [ ] Architecture constraints from docs/architecture/ are respected

### How to verify
1. Read the bead's "Implements" or "FR" references
2. Find the corresponding design doc in docs/designs/{module}/
3. Compare your implementation against the api-surface.md endpoint spec
4. Check the data-model.md for entity field correctness
5. If any mismatch → FIX before committing (the design is the source of truth)
```

If any item fails, fix the issue, re-run tests, then re-review.

**Step 2.8 — Upstream Verification (STANDARD+):**

After self-review passes, verify against upstream artifacts:

```
- [ ] Read bead's FR references from PRD (`docs/prd/{feature}/prd.md`)
- [ ] Verify each FR's acceptance criteria are satisfied
- [ ] Check: do endpoints match API spec? (if API bead)
- [ ] Check: do entities match data model spec? (if data bead)
- [ ] If BDD scenarios exist for referenced UCs (in `docs/prd/{feature}/use-cases/`), run them
```

Skip this step for infrastructure-only beads with no FR references.

**Step 2.9 — Commit:**

Track which files you created or modified during implementation. Stage ONLY those files — NEVER use `git add -A` or `git add .`. Commit with the message specified in the bead, following the project's commit conventions from CLAUDE.md for co-authorship and formatting.

Close the bead in the issue tracker.

**Step 2.9a — Push:**
```bash
git push
```
Push after each bead. Do NOT accumulate unpushed commits.
This prevents work loss on crash.

**Step 2.10 — Summarise & Reset:**

Record a brief per-bead completion note:
```markdown
**bd-{id}: {title}** — Completed
- Files changed: {list}
- Tests added: {count}
- Key implementation choice: {one sentence}
```

Update progress tracking. Then reset:
- Clear mental model of the previous bead's implementation details
- Do NOT carry forward files loaded for the previous bead
- Start the next bead fresh — re-read from Step 2.1

#### Auto-Recovery

Handle issues automatically before asking the user. Different errors need different strategies.

**Build Failure:**
1. Read the error message carefully
2. Fix the specific error (missing import, type mismatch, etc.)
3. Re-run build
4. If same error persists after 2 fixes → re-read context files for correct pattern

**Test Failure:**
1. Read the failing test and the assertion message
2. Compare expected vs actual — is the test wrong or the implementation?
3. Fix whichever is incorrect
4. Re-run tests

**Regression (Other Tests Break):**
1. Identify which test(s) broke and why
2. If your change accidentally broke existing behaviour → fix to preserve it
3. If the change intentionally alters behaviour → the bead should have mentioned this
4. If the bead didn't mention it → ask the user before proceeding

**Implementation Doesn't Work:**
1. Re-read the bead objective and success criteria
2. Re-read context files for the correct pattern
3. Check if you deviated from the referenced pattern
4. Try a different approach based on the codebase patterns

**Recovery Limits:**
- Try auto-recovery up to **3 times** per issue
- After 3 attempts, try a **different approach** (max 2 alternative approaches)
- After exhausting alternatives → escalate to user (see Blocker Handling)

#### Execution Health Check

After every 3 completed beads, or when auto-recovery is triggered, check overall health:

- **Beads completing smoothly?** If most beads require recovery, the bead descriptions may lack sufficient context or patterns. Consider pausing to improve remaining beads.
- **Scope growing?** If implementation reveals that remaining beads are larger than expected, flag to the user: "Implementation is revealing more complexity than expected in upcoming beads. Continue or reassess?"
- **Kill criteria still valid?** If execution is taking significantly longer than estimated, check brainstorm kill criteria. Flag if a time-based criterion is at risk.

If 3+ beads in a row require recovery or produce unexpected complexity, stop and present an honest assessment: "Execution is struggling — {N} of {M} beads needed recovery. This may indicate the design or beads need revision rather than more implementation attempts."

---

### Phase 3: Blocker Handling

**Stop execution only for these conditions:**

| Blocker Type | Why It Needs User |
|--------------|-------------------|
| Bead objective is ambiguous | Need clarification on intent |
| Pattern reference doesn't exist | Need alternative pattern |
| Discovered architectural issue | Design decision needed |
| Auto-recovery exhausted | Human debugging needed |
| Success criteria conflict with codebase | Need to resolve contradiction |

**When stopping:**

Present blocker details as formatted markdown:
```markdown
## Blocker Encountered

**Bead:** bd-{id} — {title}
**Objective:** {from bead}
**Issue:** {what's unclear or failing}
**Context Loaded:** {what you read}
**Recovery Attempts:** {what was tried and why it failed}

**What I Need:** {specific clarification or decision}
```

Then use AskUserQuestion (Decision Gate — Pattern 1):
```
AskUserQuestion:
  question: "Blocker encountered on {bead title}. How should we proceed?"
  header: "Blocker"
  multiSelect: false
  options:
    - label: "Clarify"
      description: "I'll provide the missing information so you can resume."
    - label: "Skip bead"
      description: "Skip this bead and continue with the next ready bead."
    - label: "Stop"
      description: "Halt execution. Commit and push current work."
    - label: "Escalate"
      description: "Return to /beads or /plan to revise."
```

After user provides resolution, apply the guidance and resume from the current bead.

---

### Phase 4: Feature Completion

**When no beads remain (none ready, none in-progress):**

**Step 4.1 — Final Quality Gates:**

Run the project's build and test commands. All must pass.

**Step 4.2 — Verify All Beads Closed:**

Check the issue tracker: all task beads should be closed, only the epic should remain open.

**Step 4.3 — Close Epic:**

Close the feature epic in the issue tracker.

**Step 4.4 — Report Completion:**

```markdown
## Execution Complete

**Feature:** {name}
**Epic:** {epic-id}
**Beads Completed:** {N} of {N}
**Tests:** All passing

### Implementation Summary
{Brief description of what was built}

### Per-Bead Notes
{Completion notes from Step 2.10 for each bead}

### Commits Made
{git log --oneline for this feature's commits}

### Files Changed
{git diff main --stat}

---

Feature complete. Verify with `dotnet build && dotnet test`.
```

**Step 4.5 — Push (with user confirmation):**

Use AskUserQuestion (Decision Gate — Pattern 1):
```
AskUserQuestion:
  question: "Feature complete. Ready to push to remote?"
  header: "Push"
  multiSelect: false
  options:
    - label: "Push (Recommended)"
      description: "Push all commits to remote."
    - label: "Hold"
      description: "Keep changes local for further review first."
```

---

## Re-Entry: Review Fix Cycle

When /review identifies issues and the user returns to /execute to fix them:

**Step R.1 — Load Review Findings:**

Read the review output. For each finding, understand what needs to change and why.

**Step R.2 — Fix Issues:**

Apply fixes following the same execution discipline: load context, implement, verify, commit. Each fix should be a separate commit with a clear message.

**Step R.3 — Identify Learnings:**

After fixing review issues, check if any fixes reveal learnings worth capturing:

For each fix:
1. Was it non-obvious? (took investigation, not a typo)
2. Would it recur in similar features?
3. Does it reveal a process, skill, or bead gap?

If YES to any → present learnings as formatted markdown:

```markdown
## Review Fixes Complete

Fixed {N} issues from review.

### Learnings Identified

{M} potential learnings worth documenting:

1. **{Topic}** ({type: Pattern_Discovery | Gotcha_Pitfall | Context_Gap | Process_Improvement})
   {1-sentence description}
```

Then use AskUserQuestion. For multiple learnings, use Batch Review (Pattern 3):
```
AskUserQuestion:
  question: "Which learnings should we document?"
  header: "Learnings"
  multiSelect: true
  options:
    - label: "{topic 1}"
      description: "{type} — {1-sentence description}"
    - label: "{topic 2}"
      description: "{type} — {1-sentence description}"
    - label: "{topic 3}"
      description: "{type} — {1-sentence description}"
    - label: "{topic 4}"
      description: "{type} — {1-sentence description}"
```

If more than 4 learnings identified, present in sequential batches of 4.

For a single learning, use Decision Gate (Pattern 1):
```
AskUserQuestion:
  question: "Document this learning?"
  header: "Learnings"
  multiSelect: false
  options:
    - label: "Document (Recommended)"
      description: "Capture this learning via /compound for future sessions."
    - label: "Skip"
      description: "Continue without documenting."
```

Selected learnings are documented via /compound.

---

## Context Management

### Between Beads: Reset

Each bead starts with a clean context. After completing a bead:
- Record what was done (in the per-bead completion note)
- Do NOT carry forward file contents from the previous bead
- Re-read files from scratch if the next bead references the same files (they may have changed)

### Within a Bead: Stay Focused

- Read only the files listed in the bead's context references
- If you need additional context, check the bead's "Approach" section first
- If still insufficient, check the bead's FR references in the PRD
- Only after exhausting bead-provided references should you explore the codebase independently

### Context Compaction Recovery

If context was compacted mid-execution:
1. Find the current in-progress bead in the issue tracker
2. Load the bead's full description
3. Load surgical context from the bead's "Context to Load" section
4. Continue: Design → Implement → Verify → Commit

Each bead is self-contained — no need to reload plan documents.

### Resume After Interruption

1. Query the issue tracker for in-progress and ready beads
2. Resume from the in-progress bead (re-read it, load context, continue)
3. If no in-progress bead, pick up the next ready bead

---

## Anti-Patterns

**The One-Shot Attempt** — Trying to implement an entire bead in a single pass without running the build or tests until the end. Run the build after each file change. Catch errors early when the fix is obvious, not after 10 files have been modified. Early feedback loops are the difference between smooth execution and debugging spirals.

**Context Hoarding** — Carrying forward file contents, error messages, and implementation details from previous beads. This leads to context rot — accuracy drops as the window fills with stale information. Each bead gets a clean slate because the codebase may have changed since the last bead was written.

**Scope Creep During Execution** — "While I'm here, I'll also fix this adjacent issue." The bead has an "Out of Scope" section for a reason. If you discover adjacent work, note it for a future bead, don't act on it now. Scope creep during execution produces untested changes and surprising diffs.

**Guessing at Design Decisions** — When the bead's approach guidance is insufficient, the agent should ask rather than guess. A wrong design decision is far more expensive to fix than a brief pause for clarification. The bead's "Approach" section exists to prevent guessing — if it's insufficient, that's a bead quality issue to flag.

**Retrying the Same Approach** — When auto-recovery fails, trying the exact same thing again with minor variations. After 3 attempts, fundamentally rethink the approach or escalate. Persistence is a virtue, but repeating failed strategies is not persistence — it's a loop.

**Skipping Verification** — Committing without running the full test suite because "my tests pass." Regressions in other tests are just as serious as failures in new tests. The full suite is the contract with the rest of the codebase.

---

## Exit Signals

| Condition | Action |
|-----------|--------|
| All beads complete | Report completion, run quality gates |
| Blocker hit | Stop, ask user, resume after resolution |
| User says "stop" | Commit current work, report progress |
| Execution health critical | Stop, assess whether to continue or revise |

When all beads complete: **"Feature complete. Verify with `dotnet build && dotnet test`."**

---

*Skill Version: 4.0*
*v4.0: Crash resilience — per-bead push, git stash checkpointing for large beads. Explicit file staging enforced (never git add -A). Design/PRD/ADR verification added to self-review. Tier ordering check prevents out-of-order module execution. Module spec loading from docs/ folders on first bead. Project-agnostic testing standards. Removed /review suggestion (inline self-review handles quality).*
*v3.5: Collaborative model added. Review-bead handling for /simplify checkpoints. COMPREHENSIVE mode per-bead check-in implemented with AskUserQuestion. PRD path added to upstream verification. Use case path added for BDD scenarios.*
*v3.4: PAUSE points use AskUserQuestion tool — Decision Gate for blocker handling and push confirmation, Batch Review for review fix learnings*
*v3.1: Duration targets, execution health circuit breaker, issue tracker commands framed as operations (tool-agnostic), review fix cycle as explicit re-entry section, parallel beads and auto-recovery folded into Phase 2, merged quality standards into self-review, per-bead completion summaries, removed hardcoded Co-Authored-By (defer to CLAUDE.md), generalized progress tracking, structured blocker response options, anti-patterns explain WHY*
