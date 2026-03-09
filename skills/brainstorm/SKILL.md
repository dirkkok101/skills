---
name: brainstorm
description: >
  Problem framing and approach selection through structured dialogue. Uses 5
  Whys to find root problems, imports research findings, generates 2-3
  genuinely different approaches with a "Do Less" option, classifies feature
  scope, and routes to the appropriate next skill. Brainstorm is lean — deep
  research moves to /research, deep requirements to /discovery or /prd. Use
  when starting any new feature, refactoring, or when user says 'brainstorm',
  'let's explore', 'how should we approach'.
argument-hint: "[feature description]"
---

# Brainstorm: Problem → Approach → Route

**Philosophy:** Understand the RIGHT problem before solving it. Pick the right approach. Define boundaries. Then route to the right depth of pipeline. Brainstorm is lean — it produces a validated problem statement, a chosen direction, and scope classification. Deep research moves to /research, detailed requirements move to /prd.

**Target duration: 15-30 minutes** for a typical brainstorm. If it's taking longer, you're going too deep — route to /discovery or /research instead.

## Why This Matters

The most expensive mistake in software development is building the wrong thing. A feature that solves a symptom instead of the root cause, or that reimplements what a library already provides, wastes weeks of effort. Brainstorming prevents this by:
- **Reframing the problem** — "I need a minimap" becomes "players need navigation feedback"
- **Surfacing alternatives** — including "Do Less" which is often the right answer
- **Right-sizing the process** — a 2-hour bugfix doesn't need a full PRD and design doc
- **Recording decisions** — so the team doesn't relitigate settled choices months later

---

## Trigger Conditions

Run this skill when:
- Starting a new feature or significant refactoring
- User describes a rough idea needing refinement
- User says "brainstorm", "let's explore", "how should we approach"
- You need to validate a problem before moving to design or planning

---

## Collaborative Model

```
Phase 1: Understand the Problem
  ── PAUSE 1: "Here's the root problem. Is this right?" ──
Phase 2: Draft Boundaries
Phase 3: Generate & Compare Approaches
Phase 4: Self-Review (gates presentation)
Phase 5: Select, Classify & Route
  ── PAUSE 2: "Here are the options, scope, and routing. Which approach? Ready for next step?" ──
```

The agent's stance should adapt to the user:
- **User gives short, vague responses** → agent leads more, asks questions, offers options
- **User gives detailed, opinionated responses** → agent follows, validates, stress-tests
- **User seems stuck** → agent facilitates with specific techniques (5 Whys, "How Might We", analogies)

---

## Prerequisites

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)

# Check for existing work
ls "${PROJECT_ROOT}/docs/brainstorm/" 2>/dev/null
ls "${PROJECT_ROOT}/docs/designs/" 2>/dev/null
ls "${PROJECT_ROOT}/docs/plans/" 2>/dev/null
ls "${PROJECT_ROOT}/docs/learnings/" 2>/dev/null

# If issue tracker available, check for existing issues
# e.g., br search "{feature keywords}" 2>/dev/null

# Check for research brief (if /research was run)
ls "${PROJECT_ROOT}/docs/research/{feature}/" 2>/dev/null
```

If existing work found, ask: "Found existing {artifact}. Build on this or start fresh?"

---

## Critical Sequence

### Phase 1: Understand the Problem

**Step 1.1 — Import Research (if available):**

If a research brief exists at `docs/research/{feature}/research-brief.md`, import tagged findings:
- **[CONSTRAINT]** → note for Phase 2 boundaries
- **[OPTION]** → seed for Phase 3 approaches
- **[RISK]** → note for risk assessment
- **[PRIOR-ART]** → consider for "Do Less" or "Adopt" approaches
- **[UNKNOWN]** → flag for discovery or further research

**Step 1.2 — The 5 Whys:**

Before accepting the problem statement, dig deeper:

```
User: "I want to add a minimap to the dungeon view"
Why? → "So players can see where they've been"
Why does that matter? → "They get lost and frustrated"
Why do they get lost? → "Dungeon layouts are confusing"
Why are they confusing? → "No landmarks, all corridors look the same"
Root Problem: Navigation feedback, not necessarily a minimap
```

Ask: **"What's the pain point you're trying to solve?"** then follow with "Why?" until you reach the root.

If the user opens with a solution instead of a problem, reframe: "That's one approach. What's the underlying problem it would solve?"

**When to abbreviate the 5 Whys:** If the user demonstrates deep domain understanding and has clearly already done root cause thinking (e.g., they present the problem with evidence and context), acknowledge their analysis and move forward. The 5 Whys is a tool for finding root causes, not a ritual — if the root cause is already clear, don't force 5 rounds of "why". Two genuine rounds may be enough.

If the user pushes back ("just build what I asked for"), acknowledge their preference, confirm the problem statement as they've framed it, and note in the output that root cause analysis was abbreviated.

**Step 1.3 — Validate Worth Solving:**

```
[ ] What happens if we DON'T solve this?
[ ] Is this solving a symptom or root cause?
[ ] Is this the right time to solve it?
[ ] Who is asking for this and why?
```

**Step 1.4 — Understand the User Journey:**

Ask: **"Walk me through how someone would use this."**

- Who uses this feature?
- What's their current workflow or workaround?
- How will they discover this feature?
- What does success look like for them?

**PAUSE 1:** Present the root problem and user journey.
"Based on our discussion, the root problem is {X}, not {original request}. The user journey is {Y}. Does this framing feel right?"

---

### Phase 2: Draft Boundaries

**Step 2.1 — Minimum Viable Version:**

Ask: **"What's the smallest version that would be useful?"**

- What can we defer to v2?
- Nice-to-have vs must-have?
- What would a 1-day version look like?

**Step 2.2 — Initial Complexity Budget:**

Ask: **"How much complexity is this problem worth?"**

```markdown
## Complexity Budget (draft — refined after approach selection)
- Maximum new services: {0-2 typically}
- Maximum new screens: {estimate}
- Estimated effort: {Low/Medium/High}
- Maintenance cost we accept: {Low/Medium/High}
```

Note: these are draft boundaries. They may need adjustment once we see what the approaches actually require.

**Step 2.3 — Anti-Requirements & Kill Criteria:**

```markdown
## Boundaries
### Must Have (v1)
- {essential requirement}

### Deferred (v2+)
- {future enhancement}

### Anti-Requirements
- Must NOT: {explicit exclusion}

### Kill Criteria
Abandon if:
- {technical blocker}
- {complexity exceeds budget by 50%+}

Kill criteria are monitored during /technical-design and /execute.
If a kill criterion triggers, return to this brainstorm to reassess.
```

---

### Phase 3: Generate & Compare Approaches

**Step 3.1 — Quick Context Scan:**

This is a QUICK scan, not a deep dive. Deep investigation is /discovery's job.

```bash
# Past learnings
grep -rl "{keywords}" "${PROJECT_ROOT}/docs/learnings/" 2>/dev/null

# Similar features in codebase (names and relevance only)
# Surface-level check for obvious patterns and constraints
```

**Step 3.2 — Create 2-3 Distinct Options:**

Each approach should be genuinely different, not variations of the same idea. Seed from research [OPTION] and [PRIOR-ART] findings if available.

```markdown
### Approach A: {Name}
**Core idea:** {1 sentence}
**How it works:** {2-3 sentences, conceptual}
**Pros:** {benefits}
**Cons:** {drawbacks}
**Complexity:** Low/Medium/High
**Within budget:** Yes/No
**Biggest risk:** {what could make this fail}

### Approach B: {Name}
...

### Approach C: Do Less
**Core idea:** {minimal or no change}
**When this is right:** {conditions where this is the best answer}
```

**Always include a "Do Less" option.** This might be adopting an existing library, using an existing feature differently, or accepting the current state. "Do Less" is not a strawman — it's often the right answer.

**Step 3.3 — Comparison Matrix:**

| Approach | Complexity | Risk | Builds On Existing | Recommendation |
|----------|-----------|------|-------------------|----------------|
| A | Medium | Low | Yes — existing patterns | Preferred |
| B | High | Medium | No — new design | Fallback |
| C: Do Less | Low | Low | N/A | If budget is tight |

---

### Phase 4: Self-Review

**Gates PAUSE 2 — complete this before presenting to the user.**

**1 round, 3 themes. Brainstorm is lean — don't over-review.**

**Theme 1: Problem Clarity**
- [ ] Root problem identified (not symptom)?
- [ ] User journey clear and realistic?

**Theme 2: Boundary Discipline**
- [ ] Must-haves truly essential?
- [ ] Anti-requirements prevent scope creep?
- [ ] Complexity budget explicit?

**Theme 3: Approach Differentiation**
- [ ] 2-3 genuinely different options (not variations of the same idea)?
- [ ] "Do Less" included and honestly assessed?
- [ ] At least one approach within complexity budget?
- [ ] Each approach has a "biggest risk" identified?

If any theme fails, fix it before proceeding to PAUSE 2.

---

### Phase 5: Select, Classify & Route

**Step 5.1 — Scope Classification:**

Scan for complexity signals:

```markdown
## Scope Classification

Signals detected:
- [ ] Auth/identity/security involvement
- [ ] Regulatory or compliance requirements
- [ ] Multiple user roles or personas
- [ ] External system integrations
- [ ] New data model with 5+ entities
- [ ] UI-heavy with multiple screens (3+)
- [ ] Cross-system data flows
- [ ] Background processing / async workflows
- [ ] Significant unknowns or unfamiliar domain
- [ ] Multiple services affected

Score:
- 0-2 signals: BRIEF
- 3-4 signals: STANDARD
- 5+ signals: COMPREHENSIVE
```

**Override rule:** Any single high-impact signal can override the count. Auth/security, regulatory compliance, or significant unknowns alone may warrant COMPREHENSIVE even with only 1-2 signals. Use judgment — the count is a starting point, not a verdict.

| Scope | Pipeline Depth |
|-------|---------------|
| **BRIEF** | brainstorm → plan → beads → execute → review → compound |
| **STANDARD** | brainstorm → prd → technical-design → plan → beads → execute → review → compound |
| **COMPREHENSIVE** | brainstorm → discovery → prd → technical-design → plan → beads → execute → review → compound |

BRIEF scope means the brainstorm document contains enough information for /plan to work directly — no PRD or design doc needed.

**PAUSE 2:** Present approaches, scope classification, and routing together.

```markdown
## Brainstorm Summary

**Feature:** {name}
**Root Problem:** {1 sentence}

### Approaches
{Comparison matrix from Phase 3}

**Which approach resonates?** We can iterate before committing.

### Stress Test (for chosen approach)
Once the user picks, challenge the selection:
- "What's the biggest risk with this approach?"
- "What would make this fail?"
- "Does this fit within the complexity budget, or should we adjust?"

If the user picks the highest-risk option, explicitly flag the risks.
If the chosen approach exceeds the complexity budget, surface this:
"This approach exceeds the draft complexity budget. Expand the budget or pick a simpler approach?"

### After Selection
**Selected Approach:** {name}
**Scope:** {BRIEF | STANDARD | COMPREHENSIVE}

What's next?
1. "start discovery" → /discovery (COMPREHENSIVE default — deep requirements)
2. "start prd" → /prd (STANDARD default — structured requirements)
3. "start plan" → /plan (BRIEF default — plan directly from brainstorm)
4. "refine" → continue iterating
5. "park" / "abandon"
```

**Step 5.2 — Refine Boundaries Against Chosen Approach:**

After the user selects an approach, check the draft boundaries from Phase 2:
- Does the chosen approach fit within the complexity budget?
- Do any anti-requirements conflict with the approach?
- Are kill criteria still appropriate?

Update boundaries if needed before saving the output.

---

### Phase 6: Output

**Save to:** `${PROJECT_ROOT}/docs/brainstorm/{feature}/brainstorm.md`

```markdown
# Brainstorm: {Feature Name}

> Problem framing and approach selection for {feature}.

## Problem Statement
### Surface Request
{What user asked for}

### Root Problem (5 Whys)
{The underlying issue discovered through 5 Whys.
If abbreviated: "Root cause analysis abbreviated — user demonstrated deep domain understanding."}

### User Journey
{How users will discover and use this}

## Research Context
{Summary of imported research findings, if /research was run. Otherwise "No prior research."}

## Boundaries
### Must Have (v1)
- {essential}

### Deferred (v2+)
- {future}

### Anti-Requirements
- Must NOT: {explicit exclusion}

### Kill Criteria
- {conditions to abandon}
- Monitored during: /technical-design, /execute

### Complexity Budget
- Effort: {Low/Medium/High}
- Max new services: {N}

## Approaches Compared
### Approach A: {Name}
{Core idea, how it works, pros/cons, complexity, biggest risk}

### Approach B: {Name}
{Core idea, how it works, pros/cons, complexity, biggest risk}

### Approach C: Do Less
{Minimal change option}

### Comparison
| Approach | Complexity | Risk | Recommendation |
|----------|-----------|------|----------------|

### Selected: {Approach Name}
{Why this approach was chosen.}

### Rejected Alternatives
- **{Approach B}:** Rejected because {specific reasoning — not just "higher complexity" but WHY that complexity is unacceptable for this problem}
- **{Do Less}:** Rejected because {specific reasoning — what makes the current state unacceptable}

## Scope Classification
**Scope:** {BRIEF | STANDARD | COMPREHENSIVE}
**Signals:** {list of detected signals}
**Override applied:** {if any, with reasoning}

## Next Step
**Recommended:** {/discovery | /prd | /plan}

---
*Brainstorm completed: {date}*
```

---

## Anti-Patterns

**Solution-First Thinking** — "I need a notification system" is a solution, not a problem. The agent should always reframe to the underlying need before generating approaches. Building the wrong solution well is still a waste.

**Premature Convergence** — Jumping to the first plausible approach without exploring alternatives. The agent should enforce a minimum of 2-3 genuinely different options before converging. Say: "That's a strong option. Let's explore two more before we decide."

**Skipping "Do Less"** — Every brainstorm must include a minimal option. Often the right answer is to use an existing library, extend an existing feature, or accept the current state. "Do Less" is not a strawman — it's a genuine option that prevents over-engineering.

**Deep-Diving the Codebase** — Brainstorm does a quick context scan for constraints and similar features. Deep investigation into codebase patterns, data models, and service interactions is /discovery's job. If brainstorm is turning into a codebase audit, stop and route to /discovery.

**Writing Detailed Requirements** — Brainstorm produces a problem statement, approach, and boundaries. Detailed functional requirements, acceptance criteria, and user stories are /prd's job. If the brainstorm document is growing past 2-3 pages, it's doing too much.

**Scope Creep During Brainstorm** — "While we're at it, we should also..." Every addition should be evaluated against the complexity budget. Related but separate problems go into "Deferred (v2+)", not "Must Have (v1)".

**Anchoring on the First Idea** — The first idea mentioned tends to dominate all subsequent thinking. When the user states their first idea, the agent should acknowledge it, then deliberately offer a contrasting approach to break the anchor.

**Rubber-Stamping the User's Choice** — When the user picks an approach, the agent's job isn't done. Stress-test the selection: what's the biggest risk? Does it fit the budget? What would make it fail? Accepting without challenge is a disservice.

---

## Exit Signals

| Signal | Next Skill | When to Recommend |
|--------|-----------|-------------------|
| "start discovery" | /discovery | COMPREHENSIVE scope (default) |
| "start prd" | /prd | STANDARD scope (default) |
| "start plan" | /plan | BRIEF scope (default) |
| "refine" | Continue brainstorm | User wants to iterate |
| "park" | Save for later | |
| "abandon" | Don't proceed | |

---

*Skill Version: 3.3*
*v3.1: Self-review gates PAUSE 2, stress-test chosen approach, merged scope/routing into single PAUSE, 5 Whys abbreviation guidance, boundaries refined after approach selection, rejection rationale in output, scope override rule, kill criteria ownership, duration target, biggest risk per approach, conditional issue tracker search*
