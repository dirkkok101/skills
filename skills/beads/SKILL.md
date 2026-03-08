---
name: beads
description: >
  Convert approved plans into intent-based work packages through structured
  dialogue. Each bead is a self-contained unit an agent can execute independently
  — it carries the objective, context references, acceptance criteria, and
  verification commands needed to produce working code. Beads contain INTENT,
  not implementation. The agent writes code from codebase patterns, not from
  copy-paste snippets. Co-authored with the user, pausing to validate
  decomposition and readiness before finalising. Use when the plan is approved,
  user says "create beads", "beads for...", or plan documents exist.
argument-hint: "[feature-name] or path to plan"
---

# Beads: Plan → Intent-Based Work Packages

**Philosophy:** A bead is a self-contained work package that an agent can pick up, understand, and execute without needing to read the full plan or design. The plan decided WHAT to build and in what order. Beads translate that into packages an agent can act on — each one carrying just enough context to produce working, tested code. Beads contain intent, not implementation. The agent writes code by understanding codebase patterns, not by copying snippets from the bead.

## Why This Matters

A plan with 8 well-ordered tasks is useless if the executing agent can't figure out what to do with each one. Beads bridge the gap between planning and execution by packaging each task with:
- **Clear objective** — what to achieve in 1-2 sentences
- **Surgical context** — exactly which files to read and why
- **Acceptance criteria** — how to know it's done (not "make sure it works")
- **Verification commands** — executable test commands, not vague instructions
- **Scope boundaries** — what's in scope and what explicitly isn't

The result: an agent can load a bead, read the referenced files, implement, verify, commit, and move on — without asking questions or guessing at intent.

---

## Trigger Conditions

Run this skill when:
- Plan has been approved (`/plan` completed)
- User says "plan approved", "create beads", "beads for..."
- Plan exists at `${PROJECT_ROOT}/docs/plans/{feature}/overview.md`

---

## Mode Selection

| Mode | Input Required | When | Output |
|------|---------------|------|--------|
| **BRIEF** | Single overview.md with inline tasks | BRIEF scope, 3-6 tasks | Beads created directly from overview tasks |
| **STANDARD** | overview.md + sub-plan files | STANDARD scope, typical feature | Beads created from sub-plans |
| **COMPREHENSIVE** | overview.md + sub-plans + risk register | COMPREHENSIVE scope, multi-service | Beads + risk-aware ordering + parallel tracks |

---

## Collaborative Model

```
Phase 1: Load Plan & Map Tasks to Beads
  ── PAUSE 1: "Here's the mapping. Right beads? Right granularity?" ──
Phase 2: Create Beads (epic, tasks, dependencies)
Phase 3: Self-Assessment Gate
  ── PAUSE 2: "All beads assessed. Review readiness?" ──
Phase 4: Present & Approve
  ── PAUSE 3: "Beads ready. Approve for /execute?" ──
```

---

## Prerequisites

**Step 0: Resolve Project Root:**

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
```

**Import upstream artifacts:**

```bash
# Plan overview (primary input)
cat "${PROJECT_ROOT}/docs/plans/{feature}/overview.md"

# Sub-plans (STANDARD+ mode)
ls "${PROJECT_ROOT}/docs/plans/{feature}/"

# PRD for FR references and acceptance criteria
cat "${PROJECT_ROOT}/docs/prd/{feature}/prd.md" 2>/dev/null

# Learnings from past features
ls "${PROJECT_ROOT}/docs/learnings/" 2>/dev/null
```

---

## Critical Sequence

### Phase 1: Map Plan Tasks to Beads

**Step 1.1 — Read Plan Structure:**

Read the plan overview and sub-plans. For each task, capture:
- Title and phase
- Objective (from sub-plan's "Intent" section)
- Dependencies (from plan's dependency graph)
- FR references (from plan's FR coverage table)
- Acceptance criteria (from sub-plan or PRD)
- Scope boundaries (from sub-plan's in/out scope)

**Step 1.2 — Decide Bead Granularity:**

Most plan tasks map 1:1 to beads. Split a task into multiple beads only when the task exceeds agent context capacity.

| Signal | Action |
|--------|--------|
| Task touches 2-5 related files | Keep as one bead |
| Task touches 8+ unrelated files | Split by concern |
| Task has "and then..." in its description | Split at the conjunction |
| Task spans multiple services or layers | One bead per service/layer |
| Task has multiple independent acceptance criteria groups | Consider splitting by group |

**The context budget test:** An agent has roughly 100-200K tokens of context. After loading the system prompt (~5-10K), reference files (~20-40K), and the bead itself (~2-5K), the remaining context is for reasoning and code generation. If a bead's context references plus the expected implementation would strain this budget, split it.

**Practical sizing guide:**
- **Good size:** 2-8 files to read or modify, one coherent behaviour change, clear "done" state
- **Too small:** Single trivial change with nothing meaningful to test
- **Too large:** Multiple unrelated behaviours, 15+ files across different concerns

**Step 1.3 — Map Dependencies:**

Import dependencies from the plan's dependency graph. Beads inherit the ordering from the plan — don't re-derive it.

If a plan task was split into multiple beads, order the sub-beads logically (typically: data model → business logic → integration → verification).

**Step 1.4 — Identify Parallel Tracks:**

Mark beads that can execute in parallel (no dependency between them). This helps the executing agent (or user) optimise throughput.

```markdown
### Parallel Tracks
- Track A: bd-002 → bd-005 (user-facing flow)
- Track B: bd-003 → bd-006 (admin flow)
- Tracks merge at: bd-007 (integration)
```

**PAUSE 1:** Present the task-to-bead mapping to the user.
"Here's how I've mapped plan tasks to beads: {N} beads across {N} phases. {N} can run in parallel. Does the granularity look right? Any tasks that should be split or merged?"

---

### Phase 2: Create Beads

**Step 2.1 — Create Epic:**

```bash
br create "Feature: {feature-name}" --type feature -p 2
```

Record epic ID for linking all beads.

**Step 2.2 — Create Each Bead:**

```bash
br create "{Bead title}" --type task -p 2 \
  --tag "FR-{MODULE}-{NAME}"
```

**Bead Description Format:**

```markdown
## Objective
{What to achieve — 1-2 sentences. State the intent, not the implementation.
"Add user verification tracking to the Account entity" not "Add a boolean field."}

## Depends On
- bd-{id}: {title}
- (or "None" if no dependencies)

## Implements
- FR-{MODULE}-{NAME}: {FR title from PRD}

## In Scope
- {Specific deliverable 1}
- {Specific deliverable 2}

## Out of Scope
- {What this bead does NOT include — handled by other beads}
- {Boundary that prevents agent drift}

## Success Criteria
- {Observable, testable outcome}
- {Observable, testable outcome}

## Failure Criteria
- {Anti-pattern to avoid}
- {Common mistake that would break other beads}

## Context to Load
- **Read:** `{file path}` — {what to learn: understand existing property patterns}
- **Pattern:** `{file path}` — {what to follow: same structure as ExistingComponent}
- **Reference:** `{doc path}` — {what to check: validation rules from design}

## Approach
{Brief guidance on HOW to approach the work — not implementation code.
"Follow the existing boolean property pattern used by IsActive."
"Use the repository pattern established in UserRepository."
Reference design decisions: "We chose X over Y — see design.md §Alternatives."}

## Acceptance Criteria
Given {precondition}
When {action}
Then {expected result}

Given {error condition}
When {error action}
Then {error handling result}

## Verification
- **Test:** `{executable test command}` — verifies {what}
- **Build:** `{executable build command}` — confirms no regressions
- **Commit:** `{type}({scope}): {message}`
```

**Step 2.3 — Add Labels:**

```bash
br label add bd-{id} model          # Data model changes
br label add bd-{id} service        # Business logic
br label add bd-{id} api            # API / endpoint changes
br label add bd-{id} ui             # Frontend / UI changes
br label add bd-{id} test           # Test-focused bead
br label add bd-{id} integration    # Cross-component wiring
br label add bd-{id} config         # Configuration changes
```

**Step 2.4 — Set Dependencies:**

```bash
# Bead B depends on Bead A (B is blocked by A)
br dep add bd-{B} bd-{A}

# Epic blocked by final bead
br dep add bd-{epic} bd-{final-bead}
```

**Verify structure:**
```bash
br dep cycles       # Must be empty
br dep tree bd-{epic}   # Visual hierarchy
br ready             # First bead(s) with no blockers
```

---

### Phase 3: Self-Assessment Gate

Every bead must pass a readiness check before presenting to the user. This catches missing context, ambiguous objectives, and oversized beads before they cause problems during execution.

**Step 3.1 — Pre-Assessment Checks:**

```bash
# Verify pattern references actually exist
ls {pattern file paths from beads}

# Check for relevant learnings
grep -r "{keywords}" docs/learnings/ 2>/dev/null

# Verify FR references match PRD
grep "FR-{MODULE}" docs/prd/{feature}/prd.md
```

**Step 3.2 — Assess Each Bead:**

For each bead, answer: "Can an agent execute this bead with the information provided, without needing to ask questions or guess at intent?"

| Status | Meaning | Action |
|--------|---------|--------|
| Ready | Clear objective, known pattern, manageable context | Proceed |
| Needs: [X] | Missing specific information | Resolve before presenting |
| Too Large | Context exceeds agent working memory | Split into sub-beads |

**Common "Needs" items:**
- Needs: pattern reference — which existing code to follow isn't specified
- Needs: clarification — objective has multiple interpretations
- Needs: context file — a dependency exists but isn't listed
- Needs: acceptance criteria — "done" state is ambiguous
- Needs: learning applied — a relevant past lesson isn't referenced
- Needs: verification command — test command is vague or missing

**Step 3.3 — Resolve Issues:**

For "Needs" items:
- Research and add the missing information to the bead
- Clarify the objective with more specific language
- Add concrete pattern references from the codebase

For "Too Large" items:
- Split into focused sub-beads
- Each sub-bead gets its own assessment
- Update dependencies for the new beads

**Step 3.4 — Record Assessment:**

```markdown
## Bead Readiness Assessment

| Bead | Status | Notes |
|------|--------|-------|
| bd-001: {title} | Ready | Pattern clear from existing code |
| bd-002: {title} | Ready | Service pattern known |
| bd-003: {title} | Needs: pattern | Which method handles detection? |
| bd-004: {title} | Too Large | Covers 3 different flows |

### Resolutions Applied

**bd-003:** Added context reference to DetectionService pattern
**bd-004:** Split into:
- bd-004a: Detection flow integration test
- bd-004b: Identification flow integration test
- bd-004c: Blocking flow integration test
```

**Re-assess until ALL beads show "Ready".**

**PAUSE 2:** Present the readiness assessment to the user.
"All {N} beads assessed. {N} were Ready immediately, {N} needed resolution (details above), {N} were split. Ready to review the full bead set?"

---

### Phase 4: Present & Approve

**Step 4.1 — FR Coverage Check:**

```markdown
### FR Coverage
| FR | Bead(s) | Status |
|----|---------|--------|
| FR-{MODULE}-{NAME} (Must) | bd-{id} | Covered |
| FR-{MODULE}-{NAME} (Must) | bd-{id}, bd-{id} | Covered |
| FR-{MODULE}-{NAME} (Should) | — | Deferred |
```

All Must-Have FRs must be covered. Flag any gaps as blocking.

**Step 4.2 — Present Summary:**

```markdown
## Beads Summary

**Feature:** {name}
**Epic:** bd-{epic-id}
**Beads:** {N} intent-based work packages
**Parallel tracks:** {N} beads can run in parallel

### Beads Created

| # | Title | Phase | Labels | Status |
|---|-------|-------|--------|--------|
| bd-{id} | {title} | 0: Foundation | model | Ready |
| bd-{id} | {title} | 1: Core | service | Ready |
| bd-{id} | {title} | 2: Feature | api, ui | Ready |

### Sample Bead
{Show `br show bd-{first-task}` to demonstrate the format}

### Dependency Tree
{Output from `br dep tree bd-{epic}`}

### Parallel Tracks
{From Phase 1.4}

### Ready to Start
{Output from `br ready`}

### Self-Assessment Summary
| Category | Count |
|----------|-------|
| Ready | {N} |
| Resolved | {N} (details in assessment) |
| Split | {N} into {M} sub-beads |

### FR Coverage
{Table from Step 4.1}

---

All beads assessed as Ready.

Options:
1. "beads approved" → Proceed to /execute
2. "adjust bd-{id}" → Modify specific bead
3. "reassess" → Re-run self-assessment gate
4. "back to plan" → Revise plan first
```

**PAUSE 3:** Wait for user approval.

---

## Bead Description — What Goes In, What Stays Out

### What Beads Contain

**Clear objective** — what to achieve, not how to code it:
```
Add verification tracking to the Account entity so the system can
distinguish verified from unverified accounts.
```

**Observable criteria** — testable outcomes, not vague goals:
```
- Property exists on Account entity
- Defaults to false for new accounts
- Persists correctly through the data layer
- Serialises in API responses
```

**Context references** — pointers to files, not duplicated content:
```
- Read: src/models/account.ext — understand existing status flag pattern
- Pattern: IsActive property — follow same structure and defaults
```

**Approach guidance** — rationale and direction, not code:
```
Follow the existing boolean property pattern. Use the same default
and persistence approach as IsActive. See design.md §Alternatives
for why we chose a boolean flag over a status enum.
```

**Executable verification** — commands that can be run, not descriptions:
```
- Test: {project test command} --filter "Account*Verified"
- Build: {project build command}
```

### What Beads Do NOT Contain

**Source code** — the agent writes code from patterns, not from bead content:
```
// DON'T include implementation in any language
isVerified: boolean = false
```

**Test code** — the agent designs tests from acceptance criteria:
```
// DON'T include test implementations
test("should verify") { assert(account.isVerified) }
```

**Duplicated content** — reference upstream docs, don't copy them:
```
// DON'T reproduce the design doc or plan content
// Instead: Reference: docs/designs/feature/design.md §Data Model
```

---

## Examples

### Good Bead

```markdown
## Objective
Add IsVerified boolean property to Account entity to track when an account
has completed the verification process.

## Depends On
- None (first bead in sequence)

## Implements
- FR-ACCOUNT-VERIFY: Track account verification status

## In Scope
- IsVerified property on Account entity
- Default value for new accounts
- Data layer persistence
- API serialisation

## Out of Scope
- Verification workflow logic (bd-002)
- Email notifications (bd-004)
- Admin UI for verification status (bd-005)

## Success Criteria
- Property exists on Account entity
- Defaults to false for new accounts
- Persists correctly through data layer
- Appears in API responses

## Failure Criteria
- Don't add redundant properties that duplicate existing flags
- Don't break existing data serialisation or migrations

## Context to Load
- **Read:** `src/models/account.ext` — understand existing status flag pattern
- **Pattern:** `IsActive` property — follow same structure and defaults
- **Reference:** `docs/plans/account-verification/01-models.md` — design rationale

## Approach
Add boolean property following the pattern established by IsActive.
Use the same default value approach and persistence configuration.

## Acceptance Criteria
Given a new account is created
When no verification has occurred
Then IsVerified is false

Given an account exists
When the verification process completes
Then IsVerified is set to true and persisted

## Verification
- **Test:** `{project test command} --filter "Account*Verified"`
- **Build:** `{project build command}`
- **Commit:** `feat(models): add IsVerified property to Account`
```

### Bad Bead

```markdown
## Task 2

Add the IsVerified property:
isVerified: boolean = false

Then add this test:
test Account_HasIsVerifiedProperty:
    account = new Account(isVerified: true)
    assert account.isVerified == true

See plan for details.
```

**Why bad:**
- Contains source code (agent should write this from patterns)
- Contains test code (agent should design tests from criteria)
- Vague "see plan" — no specific context references
- No success/failure criteria — agent can't self-verify
- No scope boundaries — agent might drift into related work
- No verification commands — agent doesn't know how to test

---

## Handling Execution Uncertainty

When an agent starts a bead and becomes uncertain:

**Agent should:**
- Ask the user for clarification before guessing
- Request additional context if references are insufficient
- Pause and explain specifically what's unclear

**Agent should not:**
- Guess at implementation when objective is ambiguous
- Deviate from the objective to "improve" adjacent code
- Skip verification because tests are hard to write

**The quality signal:** If agents frequently need to ask questions during /execute, the beads need improvement. Well-written beads should be executable with minimal or no clarification.

---

## Anti-Patterns

**The Code Bead** — Including source code or test code in the bead description. The agent should write code from codebase patterns, not copy from beads. Code in beads becomes stale, creates false confidence, and prevents the agent from learning project conventions.

**The Kitchen Sink** — Packing everything into one bead because "it's all related." If a bead touches 10+ files across multiple concerns, it's too large. Split by concern, even if the pieces are small.

**Vague Verification** — "Make sure it works" or "Test thoroughly." Give executable commands: `{project test command} --filter "AccountVerification"`. If you can't write a verification command, the acceptance criteria aren't specific enough.

**Plan Duplication** — Copying paragraphs from the design doc or plan into every bead. Reference the upstream doc with a file path and section pointer. Duplication drifts and creates conflicting sources of truth.

**Missing Scope Boundaries** — Without an "Out of Scope" section, agents tend to expand their work into adjacent areas. Explicit boundaries prevent scope creep and keep each bead focused.

**Dependency Amnesia** — Creating beads without importing the plan's dependency graph. Dependencies should flow directly from the plan. Re-deriving them risks introducing circular dependencies or breaking the critical path.

---

## Self-Review

**2 rounds minimum. Exit on 2 consecutive clean rounds.**

**Theme 1: Completeness**
- [ ] Every Must-Have FR covered by at least one bead?
- [ ] Every bead has acceptance criteria from the PRD?
- [ ] Every bead has executable verification commands?
- [ ] Dependencies imported from plan?

**Theme 2: Independence**
- [ ] Each bead executable without reading other beads?
- [ ] Context references sufficient for the agent to proceed?
- [ ] No implicit knowledge required beyond what's referenced?
- [ ] Scope boundaries (in/out) defined?

**Theme 3: Sizing**
- [ ] No bead exceeds agent context budget?
- [ ] No bead too small to test meaningfully?
- [ ] Each bead produces a committable unit of work?

**Theme 4: Clarity**
- [ ] Objectives state intent, not implementation?
- [ ] Success criteria are observable and testable?
- [ ] Failure criteria flag realistic anti-patterns?
- [ ] Context references point to files that exist?

**Theme 5: Traceability**
- [ ] Every bead tags the FR(s) it implements?
- [ ] FR coverage table has no Must-Have gaps?
- [ ] Beads reference design decisions where relevant?

---

## BRIEF Mode

For BRIEF scope (3-6 tasks from a BRIEF plan), create beads directly from the overview's inline task descriptions. No sub-plans to import — the overview IS the plan.

The bead format is identical. The only difference is that you extract objectives and criteria from the overview's inline task descriptions rather than from separate sub-plan files.

---

## Output Structure

Beads live in the `br` database, not as files. The output of this skill is:
- An epic in `br` linking all beads
- Individual beads in `br` with full descriptions
- Dependencies set between beads
- Labels applied for categorisation
- Self-assessment completed with all beads Ready

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "beads approved" | All beads ready | Proceed to /execute |
| "adjust bd-{id}" | Modify specific bead | Update and re-assess |
| "reassess" | Re-run assessment gate | Return to Phase 3 |
| "back to plan" | Plan needs changes | Return to /plan |

**On approval:** "Beads approved. Run /execute to start implementation."

---

*Skill Version: 3.0*
*v3: Collaborative PAUSE points, mode selection, context budget sizing, scope boundaries (in/out), parallel track identification, anti-patterns, self-review themes, plan-to-bead mapping guidance, BRIEF mode support*
