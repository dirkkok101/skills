---
name: execute
description: >
  Execute beads autonomously. Each bead is a self-contained work package — the
  agent loads surgical context, designs the implementation from codebase patterns,
  implements, verifies, and commits. Context resets between beads to prevent drift.
  The agent runs autonomously, only stopping for blockers or when all beads are
  complete. Use when beads exist (/beads completed), user says "execute", "start
  implementation", or ready beads exist.
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
- Beads exist (`/beads` completed — beads are a mechanical decomposition of an approved plan, not separately user-approved)
- User says "start implementation", "execute", "run beads"
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
  ├─ Orient → Load → Design → Implement → Verify → Commit → Push → Reset
  └─ (if blocker) PAUSE: "Blocker encountered. How to proceed?"
Phase 3: Blocker Handling (as needed)
Phase 4: Feature Completion — write execution manifest, close epic
```

---

## Prerequisites

Before starting, verify:
- Beads exist for the feature (`/beads` completed — the plan approval is the approval, beads are not separately user-approved)
- All beads assessed as "Ready" during /beads self-assessment
- Tests pass before starting (run project build and test commands)
- Build succeeds
- If no beads exist, run `/beads` first

**Bead source:** If `docs/beads/{feature}/beads.md` exists, read bead descriptions from there (single source of truth, richer than issue tracker comments). Fall back to `br show bd-{id}` if beads.md doesn't exist.

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

Query the issue tracker for ready beads and the feature's dependency tree. Produce a flat execution plan:

```markdown
## Execution Plan: {feature}

**Ready now (no unmet dependencies):**
- bd-{id}: {title}
- bd-{id}: {title}

**Blocked (will unlock as above complete):**
- bd-{id}: {title} — blocked by: bd-{parent}
- bd-{id}: {title} — blocked by: bd-{parent1}, bd-{parent2}

**Other modules (not this session):**
- bd-{id}: {title} — different module, skip
```

Filter to YOUR module's beads only. Epic dependency trees often include beads from other modules — identify and exclude them upfront so you don't waste time tracing irrelevant dependencies.

**Step 1.2 — Verify Baseline:**

Run the project's build and test commands. If baseline fails, assess severity before proceeding:

- **Build failure:** Fix before proceeding. Do not start executing beads on a broken codebase.
- **Isolated test failures (1-10 tests, single module):** Fix if related to the feature being executed, otherwise note and proceed.
- **Systemic test failures (>10 tests across multiple modules):** **STOP.** Do not claim any beads. Report the systemic issue to the user with failure count, affected modules, and suspected root cause. Systemic failures indicate a codebase-level problem (broken migration, missing dependency, config issue) that will block every bead — fixing it first prevents wasted work across the entire session.

Use AskUserQuestion if systemic failures are found:
```
AskUserQuestion:
  question: "{N} tests failing across {M} modules. This is a systemic blocker. How should we proceed?"
  header: "Baseline"
  multiSelect: false
  options:
    - label: "Fix blockers first (Recommended)"
      description: "Diagnose and fix the systemic issue before claiming any beads."
    - label: "Investigate only"
      description: "Diagnose the root cause and report without fixing."
    - label: "Proceed anyway"
      description: "Claim beads despite failing baseline (risky — failures may cascade)."
```

**Step 1.3 — Initialise Progress Tracking:**

Track overall progress so you (and the user) can see what's been completed and what remains. Use whatever progress mechanism is available (TodoWrite, comments, etc.).

---

### Phase 2: Execute Beads

**Loop until all beads are complete.**

When multiple beads are ready simultaneously (no dependency between them), they can be executed in any order. Prefer: data model beads before service beads, service beads before integration beads. Execute each bead fully before starting the next.

#### Multi-Agent Concurrent Execution

When multiple agents execute on the same branch simultaneously (e.g., parallel module execution), expect these issues and handle them proactively:

**Build artifact collisions:** Other agents' builds delete/lock DLLs mid-compilation, causing spurious build errors. **Fix:** Retry the build once. If it fails again with the same MSB3030/FileNotFoundException, wait 10 seconds and retry — the other agent's build will finish.

**File reverts:** Other agents may revert your changes via their own git operations (commit, checkout, stash). **Fix:** After each commit, verify your changes are in the commit with `git show --stat HEAD`. If a file you changed is missing, re-apply with `Write` (full file overwrite) rather than `Edit` (which fails on stale content).

**Shared file conflicts:** Other agents may break files you depend on (test files, shared components). **Fix:** Do NOT fix other agents' files. If their broken code blocks your tests, use module-scoped tests (`--filter "YourModule"`) instead of the full suite.

**File reservation (if agent-mail available):** Use `macro_file_reservation_cycle` to reserve files before editing. This prevents concurrent writes to the same file. Without reservation, other agents may commit YOUR unstaged files as part of their commits — your subsequent `git add` then fails with "no changes added."

**Pre-commit hook transience:** Pre-commit hooks that run builds (e.g., `dotnet build`) may fail when another agent is building simultaneously due to file locks. **Fix:** Retry the commit once after a transient hook failure. If it fails twice with the same error, wait 10 seconds and retry.

**Verification strategy during concurrent execution:**
- **Per-bead:** Module-scoped tests (`--filter "YourModule"`) — reliable even when other agents have broken code
- **Test gate bead:** Full suite — run only when your module's beads are complete and other agents aren't actively building
- **If full suite is broken by others:** Log the failing tests, verify they're NOT in your changed files (`git diff --name-only`), proceed with module-scoped tests

**Test gate beads:** When the next bead is a test gate (tagged `test`), run the verification commands specified in the gate bead (e.g., `dotnet test --filter`, `ng test`). If all pass, close the gate and proceed. If any fail, fix the failing implementation beads before continuing.

**Review/simplify gate beads (legacy):** If you encounter `/review` or `/simplify` gate beads (from older bead sets), do NOT launch full /review or /simplify agents. Instead:
- **If preceding beads changed <5 files total:** Self-review is sufficient. Run the self-review checklist from Step 2.7, close the gate, proceed. Launching review agents for 1-2 file changes is pure overhead.
- **If preceding beads changed 8+ files or touched cross-cutting concerns:** Run a targeted self-review against design docs. Still do not launch full agents — /review-execute at the end covers this.
- Close the gate bead with a comment: "Self-reviewed — /review-execute handles deep review post-execution."

**E2E / Aspire beads:** If a bead requires a different execution context (e.g., Aspire AppHost, browser automation, Docker compose), skip it with a comment: "Requires {context} — deferred to separate session." Do not block on beads that can't run in the current environment. Close as "deferred" not "completed."

**UC verification gates:** When the next bead is a UC verification gate (`verify({module}): UC-{ID}`), trace the use case's main scenario steps through the implemented code:
1. Read the UC document referenced by the gate
2. For each main scenario step, confirm the endpoint/component exists and handles it
3. For each extension/alternative flow, confirm error handling exists
4. Run the gate's verification commands
If any step can't be traced through code, flag as a blocker.

**Module completion gates:** When the next bead is a module completion gate (`verify({module}): module complete`), run the full test suite for the module and verify all UC gates passed.

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

Read the full bead description from `docs/beads/{feature}/beads.md` (preferred) or `br show bd-{id}`. Parse:
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

**Context budget per bead:** Beads should load a bounded amount of context to prevent bloat. Module spec files (loaded in Step 2.3a on the first bead in a module) are excluded from this budget — they are reference documents, not bead-specific context:
- **BRIEF mode:** Max 5 bead-specific context files
- **STANDARD mode:** Max 8 bead-specific context files
- **COMPREHENSIVE mode:** Max 12 bead-specific context files

If a bead references more files than the budget, load the most directly relevant first. If the bead genuinely needs all files, it may be too coarse — flag as a potential splitting candidate before proceeding.

**Step 2.3a — Load Module Specs (first bead in module only):**

When starting the FIRST bead in a module, load the module's key design documents. Use the doc map from `docs/beads/{feature}/beads.md` (if it contains one) or discover paths using the project's doc structure:

1. **Design overview** — technical design for the module
2. **Data model** — entity specifications (if exists)
3. **API surface** — endpoint specs for the feature being implemented (if referenced by bead)
4. **PRD** — requirements (skim for referenced FRs and UCs)
5. **Use cases** — UC documents referenced by beads in this module

Common path patterns (vary by project):
```
docs/designs/{module}/           — technical design (source of truth for HOW)
docs/prd/{module}/               — requirements (source of truth for WHAT)
docs/use-cases/ or docs/prd/{module}/use-cases/  — UC scenarios
docs/adr/                        — architectural decisions (source of truth for WHY)
docs/patterns/                   — coding patterns (source of truth for STYLE)
docs/architecture/               — system architecture (source of truth for CONSTRAINTS)
```

For subsequent beads in the same module, reload module specs only if context was compacted since the last bead. The reset in Step 2.9 clears implementation details (code written, errors fixed, patterns followed) — module-level reference documents naturally remain in the conversation context until compaction forces a reload.
Do NOT re-read these on every bead — only on the first bead or after context compaction.

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

If a bead involves modifying more than 8 files, checkpoint periodically:
```bash
git stash push -m "checkpoint: bd-{id} - {description}"
```

This prevents total work loss on crash. After all files are done,
pop the stashes and make a single clean commit.

Most beads modify 1-8 files — skip checkpointing for these. The per-file stash overhead isn't worth it for small beads.

**Step 2.6 — Verify:**

Run the **full test suite**, not filtered tests. Do NOT use `--filter "ModuleName"` or equivalent — filtered tests miss cross-module regressions. A bead that changes status codes or contracts can break tests in completely separate test files that aren't listed in the bead's context. The full suite is the only reliable verification.

If the full suite is slow (>5 minutes), run the bead's specific verification commands first as a fast check, then run the full suite. But never skip the full suite.

**Concurrent execution exception:** See "Multi-Agent Concurrent Execution" section above. During concurrent execution, use module-scoped tests per bead and defer full suite to the test gate bead.

**Rationalization Prevention (Iron Law):** Every completion claim requires FRESH verification evidence. Common rationalizations to catch:
- "It should work now" → RUN the tests. "Should" is not evidence.
- "I'm confident this is correct" → Confidence is not evidence. Run verification.
- "This is the same pattern as the last bead" → The last bead's tests don't verify this bead. Run tests.
- "I only changed one line" → One-line changes cause regressions. Run tests.

**Step 2.7 — Self-Review:**

Before committing, run a lightweight self-review. This is a fast sanity check — deep adversarial verification is done by `/review-execute` after all beads complete.

**Proportionality:** For verification beads (checking existing code matches design) and test-only beads, the self-review can skip pattern/style/slop checks — focus only on: objective achieved, success criteria met, tests pass.

```
Per-Bead Self-Review (lightweight):
- [ ] Re-read bead objective — does the implementation achieve it?
- [ ] Each success criterion met (check specifically)
- [ ] No failure criterion violated (check specifically — failure criteria often encode
      design decisions like "Do NOT use SaveRequest" per command-pattern.md; verify
      against the referenced decision doc, not just as arbitrary rules)
- [ ] No scope creep (nothing added beyond the objective)
- [ ] Implementation follows the referenced pattern doc
- [ ] Code style matches existing codebase
- [ ] Tests verify application logic, not framework guarantees
- [ ] Run tests before committing (full suite solo, module-scoped if concurrent — see Multi-Agent section)
- [ ] Staged specific files (not git add -A)
- [ ] No AI slop: unnecessary abstractions for single-use logic
- [ ] No AI slop: docstrings/comments on obvious methods
- [ ] No AI slop: defensive coding against impossible internal states
- [ ] No AI slop: premature generalization (config for one value, wrapper class with no added behavior)
```

If any item fails, fix the issue, re-run tests, then re-review.

**Note:** Deep design/spec alignment (api-surface match, data-model match, ADR compliance, FR acceptance criteria, UC scenario coverage) is verified by `/review-execute` post-execution. The self-review catches obvious mismatches but does not replace adversarial review.

**Step 2.8 — Commit:**

**Verification-only fast path:** If the bead was a verification-only pass (all checks passed, zero code changes), skip commit and push. Just close the bead in the issue tracker with a comment: "Verified — no changes needed." This avoids empty commits and unnecessary push cycles.

**If code was changed:** Track which files you created or modified. Stage ONLY those files — NEVER use `git add -A` or `git add .`. Commit with the message specified in the bead, following the project's commit conventions from CLAUDE.md for co-authorship and formatting. Close the bead in the issue tracker.

**Step 2.8a — Push (if committed):**
```bash
git push
```
Push after each bead that produces a commit. Do NOT accumulate unpushed commits.
This prevents work loss on crash.

**Step 2.9 — Summarise & Reset:**

Record a structured per-bead completion entry. These entries accumulate into the execution manifest (written in Phase 4):
```markdown
### bd-{id}: {title}
- **Status:** Completed
- **Files changed:** {list of file paths}
- **Tests added:** {count} ({list of test file paths})
- **FRs addressed:** {FR IDs from bead's "Implements" field}
- **UCs contributed to:** {UC IDs and steps this bead helps implement}
- **ACs claimed:** {which acceptance criteria this bead satisfies}
- **Design elements implemented:** {api-surface endpoint, data-model entity, etc.}
- **Commit:** {commit hash} — {commit message}
- **Key implementation choice:** {one sentence}
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

Track a **cumulative health score** starting at 0. Events increase the score:

| Event | Score Impact |
|-------|-------------|
| Auto-recovery triggered | +10 |
| Revert/rollback needed | +15 |
| Test fix required (implementation was wrong) | +5 |
| File changed outside bead's scope boundaries | +20 |
| Bead required alternative approach | +10 |
| Blocker escalated to user | +15 |

**Thresholds:**
- **Score ≥ 40 — PAUSE:** "Execution health is degrading — {N} of {M} beads needed recovery. Continue or reassess?" Present via AskUserQuestion (Decision Gate).
- **Score ≥ 60 — STOP:** "Execution health critical. This may indicate the design or beads need revision rather than more implementation attempts."
- **Score resets to 0** after every 3 consecutive clean bead completions (no recovery needed).
- **Proportionality note:** For small features (≤6 beads), halve the thresholds (PAUSE at 20, STOP at 30) since fewer beads means each issue is proportionally more significant.

Also check after every 3 completed beads:
- **Scope growing?** If implementation reveals that remaining beads are larger than expected, flag to the user.
- **Kill criteria still valid?** If execution is taking significantly longer than estimated, check brainstorm kill criteria.

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

**Step 4.4 — Write Execution Manifest (MANDATORY):**

**You MUST write** a structured execution manifest to `docs/execution/{feature}/manifest.md`. This file is the primary input for `/review-execute`. Without it, review-execute must reconstruct context from git log — slower, less structured, and error-prone.

**Manifest writing robustness:**
1. **Verify working directory** before writing — `pwd` must be the project root. Late-session directory drift (e.g., after `cd` to a subfolder for a frontend build) causes silent write failures.
2. **Create directory first:** `mkdir -p docs/execution/{feature}/`
3. **Write early, update incrementally** — start the manifest after the first bead completes. Append each bead's entry as you go. Don't leave it all for Phase 4 when context is full and the session is ending.
4. Commit and push the manifest as the final commit.

```markdown
# Execution Manifest: {Feature Name}

> **Date:** {date}
> **Epic:** {epic-id}
> **Beads Completed:** {N} of {N}
> **Build:** Passing
> **Tests:** All passing

## Bead Completion Log

{All structured per-bead entries from Step 2.9}

## Commits

{git log --oneline for this feature's commits}

## Files Changed

{git diff main --stat}

## FR Coverage Claimed

| FR ID | Bead(s) | ACs Claimed | Files |
|-------|---------|-------------|-------|
| {FR-ID} | {bd-ids} | {AC list} | {file paths} |

## UC Coverage Claimed

| UC ID | Step/Flow | Bead(s) | Implementation |
|-------|-----------|---------|----------------|
| {UC-ID} | Main.{N}: {description} | {bd-ids} | {endpoint/component handling this step} |
| {UC-ID} | Ext.{N}: {description} | {bd-ids} | {error handler / validation} |

## Design Elements Implemented

| Design Element | Source Doc | Bead | Status |
|---------------|-----------|------|--------|
| {endpoint/entity/component} | {api-surface.md / data-model.md} | {bd-id} | Implemented |
```

**Step 4.5 — Report Completion:**

Present a summary to the user:

```markdown
## Execution Complete

**Feature:** {name}
**Epic:** {epic-id}
**Beads Completed:** {N} of {N}
**Tests:** All passing

### Implementation Summary
{Brief description of what was built}

Execution manifest: `docs/execution/{feature}/manifest.md`

Feature complete. Run `/review-execute` for bead-by-bead verification, or `/review` for general code review.
```

Note: Each bead was pushed individually (Step 2.8a). All commits are already on remote.

---

## Re-Entry: Review Fix Cycle

When `/review-execute` or `/review` identifies issues and the user returns to /execute to fix them:

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

**Delegating Reads to Sub-Agents** — Using Explore agents or sub-agents to read and interpret implementation files during execution. Sub-agents lack the precision needed for mechanical tasks — they may suggest the wrong pattern (e.g., `ThrowError` instead of `SendProblemAsync`). Always read implementation files directly in the main context. Use parallel direct reads for speed, not agents for interpretation.

**Confidence Substitution** — Claiming a change works based on a prior test run, pattern recognition, or "I'm confident." See the Rationalization Prevention Iron Law (Step 2.6) — every bead requires fresh verification evidence. No exceptions.

---

## Exit Signals

| Condition | Action |
|-----------|--------|
| All beads complete | Report completion, run quality gates |
| Blocker hit | Stop, ask user, resume after resolution |
| User says "stop" | Commit current work, report progress |
| Execution health critical | Stop, assess whether to continue or revise |

When all beads complete: **"Feature complete. Run `/review-execute` for bead-by-bead verification, or `/review` for general code review."**

---

*Skill Version: 4.10*
*v4.10: Production feedback from Users execution. Legacy review/simplify gate handling (self-review instead of launching agents — <5 files is self-review, 8+ is targeted review, never full agents). E2E/Aspire bead deferral (skip with comment, don't block). Pre-commit hook transience note.*
*v4.9: Applications feedback. Flat execution plan. Verification-only fast path. Pre-commit hook retry. File reservation.*
*v4.8: Languages feedback. Multi-Agent section. Module-scoped tests. Self-review multi-agent acknowledgment.*
*v4.7: Organizations feedback. Multi-agent filtered test fallback. Manifest robustness. Self-review proportionality for verification beads.*
*v4.6: Cumulative health score (PAUSE@40/STOP@60). Rationalization prevention Iron Law. AI slop detection. Context budget per bead. Confidence Substitution anti-pattern.*
*v4.5: Execution manifest made MANDATORY with stronger language (review-execute depends on it — cross-cutting run didn't produce one).*
*v4.4: Production feedback from cross-cutting execution. Full test suite mandatory (not filtered). Checkpoint threshold raised to 8+ files. Anti-pattern: sub-agent delegation for implementation reads.*
*v4.3: UC gate execution. Removed Step 2.8 upstream verification (deferred to /review-execute). Design decision awareness. Doc map paths. UC Coverage in manifest.*
*v4.2: Pipeline alignment — removed /review and /simplify gate bead handling. Execution manifest. Structured per-bead entries. beads.md as preferred source. Lightweight self-review. Removed user-approval prerequisite and hardcoded dotnet commands.*
*v4.1: Systemic blocker circuit breaker in Phase 1 baseline check — >10 failing tests across multiple modules triggers STOP with AskUserQuestion before any bead work.*
*v4.0: Crash resilience — per-bead push, git stash checkpointing. Explicit file staging (never git add -A). Design/PRD/ADR verification in self-review. Tier ordering check. Module spec loading from docs/ folders.*
*v3.5: Collaborative model. COMPREHENSIVE mode per-bead check-in. PRD path in upstream verification. Use case path for BDD scenarios.*
*v3.4: AskUserQuestion stage gates — Decision Gate for blockers, Batch Review for learnings.*
*v3.1: Duration targets, execution health circuit breaker, review fix re-entry section, auto-recovery, per-bead summaries, anti-patterns.*
