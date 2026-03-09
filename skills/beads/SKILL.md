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

**Duration targets:** BRIEF ~10-15 minutes, STANDARD ~20-40 minutes, COMPREHENSIVE ~45-90 minutes. Most time should be spent on Phase 3 (self-assessment). If bead creation is fast but assessment reveals many "Needs" items, the plan's sub-plans may lack detail — consider going back to refine them.

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
Phase 3: Self-Assessment Gate (per-bead readiness + cross-bead review)
  ── PAUSE 2: "All beads assessed and ready. Approve for /execute?" ──
```

---

## Prerequisites

Import upstream artifacts into the beads workspace:
- **Plan overview** (primary input) — `docs/plans/{feature}/overview.md` (task summary, dependency graph, FR coverage)
- **Sub-plans** (STANDARD+ mode) — `docs/plans/{feature}/NN-*.md` (per-task intent, scope, acceptance criteria)
- **PRD** — `docs/prd/{feature}/prd.md` (FR references and acceptance criteria)
- **Learnings** — `docs/learnings/` (relevant compound learnings from past features)

Do not re-derive information that exists in these artifacts. Import it, reference it, build on it.

---

## Critical Sequence

### Phase 1: Map Plan Tasks to Beads

**Step 1.0 — Scope Growth Check:**

Before creating beads, review brainstorm kill criteria. As you map tasks to beads, watch for scope growth — if splitting tasks produces significantly more beads than the plan anticipated, the feature may be larger than originally scoped:
- Plan estimated {N} tasks → bead mapping produces {M} beads
- If M > N × 1.5, flag: "Bead count ({M}) significantly exceeds plan task count ({N}). This suggests the work is larger than estimated. Kill criterion '{criterion}' may be at risk. Continue or return to plan?"

**Step 1.1 — Read Plan Structure:**

Read the plan overview and sub-plans. For each task, capture:
- Title and phase
- Objective (from sub-plan's "Intent" section)
- Dependencies (from plan's dependency graph)
- FR references (from plan's FR coverage table)
- Acceptance criteria (from sub-plan or PRD)
- Scope boundaries (from sub-plan's in/out scope)

**Step 1.2 — Place Review Beads:**

After mapping implementation beads, insert `/simplify` review beads at logical boundaries. Review beads are real work packages — they sit in the dependency chain between implementation groups. During /execute, the agent runs `/simplify` to review all code changed since the last review before continuing.

**Where to place review beads:**

| Boundary | Why Review Here |
|----------|----------------|
| After foundation beads | Verify patterns before feature code builds on them |
| After each vertical feature slice | Ensure the first feature sets good patterns for subsequent slices |
| After high-risk beads | Confirm risky work is solid before depending on it |
| Before polish beads | Last chance to simplify before edge cases add complexity |

**Rules by scope:**
- BRIEF: one review bead after the final implementation bead
- STANDARD: 2-3 review beads at phase boundaries
- COMPREHENSIVE: review bead after each phase + after each major feature slice
- Never more than 4-5 implementation beads between review beads

**Step 1.3 — Decide Implementation Bead Granularity:**

Most plan tasks map 1:1 to implementation beads. Split a task into multiple beads only when the task exceeds agent context capacity.

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

**Step 1.4 — Map Dependencies:**

Import dependencies from the plan's dependency graph. Beads inherit the ordering from the plan — don't re-derive it.

If a plan task was split into multiple beads, order the sub-beads logically (typically: data model → business logic → integration → verification).

Review beads depend on the last implementation bead in their group and block the next group's first implementation bead. This creates natural quality gates in the dependency chain.

**Step 1.5 — Identify Parallel Tracks:**

Mark beads that can execute in parallel (no dependency between them). This helps the executing agent (or user) optimise throughput.

```markdown
### Parallel Tracks
- Track A: bd-002 → bd-005 (user-facing flow)
- Track B: bd-003 → bd-006 (admin flow)
- Tracks merge at: bd-007 (integration)
```

**PAUSE 1:** Present the task-to-bead mapping to the user.
"Here's how I've mapped plan tasks to beads: {N} beads across {N} phases. {N} can run in parallel. Does the granularity look right? Any tasks that should be split or merged?"

Response options:
- **Accept** — mapping is correct, proceed to create beads
- **Modify** — adjust granularity for specific tasks (specify which)
- **Escalate** — mapping reveals the plan needs revision; return to /plan

---

### Phase 2: Create Beads

This phase creates work packages in the project's issue tracker. The examples below use `br` (beads-rust); adapt commands to your issue tracker as configured in your CLAUDE.md.

**Step 2.1 — Create Epic:**

Create a parent work item for the feature to link all beads under. Example: `br create "Feature: {feature-name}" --type feature -p 2`

Record epic ID for linking all beads.

**Step 2.2 — Create Each Bead:**

For each bead, create a work item with the full bead description. Example: `br create "{Bead title}" --type task -p 2 --tag "FR-{MODULE}-{NAME}"`

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

**Step 2.3 — Create Review Beads:**

For each review boundary from Step 1.2, create a review bead. Review beads run `/simplify` rather than implementing features:

```markdown
## Objective
Code quality review checkpoint. Run /simplify to review all code changed
since the last checkpoint for reuse opportunities, quality issues, and
efficiency improvements.

## Depends On
- bd-{id}: {last implementation bead in this group}

## Review Focus
{Specific to this boundary — e.g., "Pattern consistency with foundation.
Verify base abstractions are solid before feature code builds on them."}

## In Scope
- All files changed by beads since last review checkpoint
- Code quality: duplication, naming, abstraction opportunities
- Pattern consistency with established codebase conventions
- Test coverage adequacy

## Out of Scope
- New feature work (that's the next implementation bead)
- Architecture changes (escalate to /plan if needed)

## Verification
- **Run:** `/simplify`
- **Fix:** Apply any issues found by /simplify before proceeding
- **Commit:** `refactor({scope}): simplify {what was improved}`
```

Label review beads with `review` tag to distinguish them from implementation beads.

**Step 2.4 — Apply Labels:**

Categorise each bead by concern area (e.g., model, service, api, ui, test, integration, config, review). Labels help with parallel track identification and progress reporting.

**Step 2.5 — Set Dependencies:**

Register dependencies between beads as specified in the plan's dependency graph. Verify:
- No circular dependencies
- The dependency tree reflects the plan's ordering
- First bead(s) have no blockers and are ready to execute

---

### Phase 3: Self-Assessment Gate

Every bead must pass a readiness check before presenting to the user. This catches missing context, ambiguous objectives, and oversized beads before they cause problems during execution.

**Step 3.1 — Pre-Assessment Verification:**

Before assessing individual beads, verify structural integrity:
- All context file references in beads point to files that actually exist in the codebase
- All FR references match FRs in the PRD
- Check for relevant learnings that should be referenced but aren't

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

**Step 3.4 — Cross-Bead Review:**

After individual assessment, review the full bead set against these themes:

**Completeness:**
- [ ] Every Must-Have FR covered by at least one bead?
- [ ] Every bead has acceptance criteria from the PRD?
- [ ] Every bead has executable verification commands?
- [ ] Dependencies imported from plan?

**Independence:**
- [ ] Each bead executable without reading other beads?
- [ ] Context references sufficient for the agent to proceed?
- [ ] No implicit knowledge required beyond what's referenced?
- [ ] Scope boundaries (in/out) defined?

**Sizing:**
- [ ] No bead exceeds agent context budget?
- [ ] No bead too small to test meaningfully?
- [ ] Each bead produces a committable unit of work?

**Clarity:**
- [ ] Objectives state intent, not implementation?
- [ ] Success criteria are observable and testable?
- [ ] Failure criteria flag realistic anti-patterns?
- [ ] Context references point to files that exist?

**Traceability:**
- [ ] Every implementation bead tags the FR(s) it implements?
- [ ] FR coverage table has no Must-Have gaps?
- [ ] Beads reference design decisions where relevant?

**Review Beads:**
- [ ] Review beads placed at phase boundaries and after feature slices?
- [ ] No more than 4-5 implementation beads between review beads?
- [ ] Each review bead specifies a review focus (not just "run /simplify")?
- [ ] Review beads correctly gate the next group (depend on prior, block next)?

**Step 3.5 — Record Assessment:**

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

**Re-assess until ALL beads show "Ready" and cross-bead review passes.**

**Step 4 — FR Coverage Check:**

```markdown
### FR Coverage
| FR | Bead(s) | Status |
|----|---------|--------|
| FR-{MODULE}-{NAME} (Must) | bd-{id} | Covered |
| FR-{MODULE}-{NAME} (Must) | bd-{id}, bd-{id} | Covered |
| FR-{MODULE}-{NAME} (Should) | — | Deferred |
```

All Must-Have FRs must be covered. Flag any gaps as blocking. If the project uses an issue tracker, offer to create tracked items for gaps.

**PAUSE 2:** Present the full bead set with readiness assessment and FR coverage.

```markdown
## Beads Summary

**Feature:** {name}
**Epic:** {epic-id}
**Beads:** {N} intent-based work packages
**Parallel tracks:** {N} beads can run in parallel

### Beads Created

| # | Title | Phase | Labels | Status |
|---|-------|-------|--------|--------|
| bd-{id} | {title} | 0: Foundation | model | Ready |
| bd-{id} | {title} | 0: Foundation | config | Ready |
| bd-{id} | /simplify review | checkpoint | review | Ready |
| bd-{id} | {title} | 1: Core | service | Ready |
| bd-{id} | {title} | 2: Feature | api, ui | Ready |
| bd-{id} | /simplify review | checkpoint | review | Ready |

### Dependency Tree
{Visual hierarchy of bead dependencies}

### Parallel Tracks
{From Phase 1.4}

### Self-Assessment Summary
| Category | Count |
|----------|-------|
| Ready | {N} |
| Resolved | {N} (details in assessment) |
| Split | {N} into {M} sub-beads |

### FR Coverage
{Table from Step 4}

---

All beads assessed as Ready.

Options:
1. "Accept" / "beads approved" → Proceed to /execute
2. "Adjust bd-{id}" → Modify specific bead
3. "Reassess" → Re-run self-assessment gate
4. "Back to plan" → Revise plan first
5. "Park" → Save for later
```

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
- Read: src/models/account.{ext} — understand existing status flag pattern
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

**Source code** — the agent writes code from patterns, not from bead content. Including implementation creates false confidence and prevents the agent from adapting to the actual codebase state.

**Test code** — the agent designs tests from acceptance criteria. Pre-written tests can't account for the actual implementation shape.

**Duplicated content** — reference upstream docs, don't copy them. When the design changes, only one location should need updating.

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
- **Read:** `src/models/account.{ext}` — understand existing status flag pattern
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
  isVerified = false

Then add this test:
  test Account_HasIsVerifiedProperty:
      account = new Account(isVerified: true)
      assert account.isVerified == true

See plan for details.
```

**Why bad:**
- Contains implementation code (agent should write this from patterns)
- Contains test code (agent should design tests from criteria)
- Vague "see plan" — no specific context references
- No success/failure criteria — agent can't self-verify
- No scope boundaries — agent might drift into related work
- No verification commands — agent doesn't know how to test

---

## Bead Quality Signal

The ultimate test of bead quality is execution. If agents frequently need to ask questions during /execute, the beads need improvement. Well-written beads should be executable with minimal or no clarification.

Track this across features: if the same types of questions recur (missing pattern references, ambiguous criteria, unclear scope), capture that as a compound learning so future beads avoid the same gaps.

---

## Anti-Patterns

**The Code Bead** — Including source code or test code in the bead description. The agent should write code from codebase patterns, not copy from beads. Code in beads becomes stale, creates false confidence, and prevents the agent from learning project conventions. Beads that contain code also tend to be fragile — any refactoring of the codebase invalidates the bead's snippets.

**The Kitchen Sink** — Packing everything into one bead because "it's all related." If a bead touches 10+ files across multiple concerns, it's too large. Split by concern, even if the pieces are small. Large beads produce large diffs that are harder to review and more likely to conflict with parallel work.

**Vague Verification** — "Make sure it works" or "Test thoroughly." Give executable commands with specific filters. If you can't write a verification command, the acceptance criteria aren't specific enough — fix the criteria first, then the verification follows naturally.

**Plan Duplication** — Copying paragraphs from the design doc or plan into every bead. Reference the upstream doc with a file path and section pointer. Duplication drifts and creates conflicting sources of truth — when the design changes, every bead with copied content becomes stale.

**Missing Scope Boundaries** — Without an "Out of Scope" section, agents tend to expand their work into adjacent areas. Explicit boundaries prevent scope creep and keep each bead focused. The most effective boundaries name the OTHER bead that handles the excluded work.

**Dependency Amnesia** — Creating beads without importing the plan's dependency graph. Dependencies should flow directly from the plan. Re-deriving them risks introducing circular dependencies or breaking the critical path that was carefully designed in /plan.

---

## BRIEF Mode

For BRIEF scope (3-6 tasks from a BRIEF plan), create beads directly from the overview's inline task descriptions. No sub-plans to import — the overview IS the plan.

The bead format is identical. The only difference is that you extract objectives and criteria from the overview's inline task descriptions rather than from separate sub-plan files.

---

## Output Structure

Beads live in the project's issue tracker (e.g., `br` database), not as files. The output of this skill is:
- An epic linking all beads
- Individual beads with full descriptions
- Dependencies set between beads
- Labels applied for categorisation
- Self-assessment completed with all beads Ready

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "beads approved" / "accept" | All beads ready | Proceed to /execute |
| "adjust bd-{id}" | Modify specific bead | Update and re-assess |
| "reassess" | Re-run assessment gate | Return to Phase 3 |
| "back to plan" | Plan needs changes | Return to /plan |

**On approval:** "Beads approved. Run /execute to start implementation."

---

*Skill Version: 3.3*
*v3.2: Review beads — /simplify code review work packages inserted at logical boundaries (phase transitions, feature slices, after high-risk work). Review beads sit in the dependency chain between implementation groups, gating progression until code quality is verified. Placement rules by scope tier. Review bead template with focus guidance. Cross-bead assessment validates review bead coverage.*
*v3.1: Duration targets, scope growth check (kill criteria), prose-based artifact import (no hardcoded shell), merged PAUSE 2+3 into single approval, integrated self-review themes into self-assessment gate, issue tracker commands framed as examples (tool-agnostic), structured PAUSE response options, execution uncertainty reframed as quality signal, language-neutral examples, anti-patterns explain WHY*
