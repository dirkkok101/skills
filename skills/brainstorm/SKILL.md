---
name: brainstorm
description: >
  Problem framing and approach selection. Uses 5 Whys to find root problems,
  quick-scans existing docs, generates 2-3 approaches with a "Do Less" option,
  classifies feature scope, and routes to the appropriate next skill. Use when
  starting any new feature, refactoring, or when user says 'brainstorm',
  'let's explore', 'how should we approach'.
argument-hint: "[feature description]"
---

# Brainstorm: Problem → Approach → Route

**Philosophy:** Understand the RIGHT problem before solving it. Pick the right approach. Define boundaries. Then route to the right depth of pipeline. Brainstorm is lean — deep research moves to /discovery, detailed requirements move to /prd.

## Core Principles

1. **Problem over solution** — 5 Whys to find root cause
2. **Lean context scan** — check what exists, don't deep-dive
3. **Scope discipline** — define boundaries before generating approaches
4. **Always include "Do Less"** — the minimal option is always on the table
5. **Classify and route** — match pipeline depth to feature complexity

---

## Trigger Conditions

Run this skill when:
- Starting a new feature or significant refactoring
- User describes a rough idea needing refinement
- User says "brainstorm", "let's explore", "how should we approach"
- You need to validate a problem before moving to design or planning

---

## Critical Sequence

### Phase 0: Prerequisites

**Step 0.1 — Resolve Project Root:**

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
echo "Project root: ${PROJECT_ROOT}"
ls "${PROJECT_ROOT}/docs/"
```

All paths use `${PROJECT_ROOT}/docs/` to ensure correct location.

**Step 0.2 — Check for Existing Work:**

```bash
br search "{feature keywords}" 2>/dev/null
ls "${PROJECT_ROOT}/docs/brainstorm/" 2>/dev/null
ls "${PROJECT_ROOT}/docs/designs/" 2>/dev/null
ls "${PROJECT_ROOT}/docs/plans/" 2>/dev/null
ls "${PROJECT_ROOT}/docs/learnings/" 2>/dev/null
ls "${PROJECT_ROOT}/docs/research/{feature}/" 2>/dev/null
```

If existing work found, ask: "Found existing {artifact}. Build on this or start fresh?"

---

### Phase 1: Understand the Problem

**Step 1.1 — The 5 Whys:**

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

**Step 1.2 — Validate Worth Solving:**

```
[ ] What happens if we DON'T solve this?
[ ] Is this solving a symptom or root cause?
[ ] Is this the right time to solve it?
[ ] Who is asking for this and why?
```

**Step 1.3 — Understand the User Journey:**

Ask: **"Walk me through how someone would use this."**

- Who uses this feature?
- What's their current workflow?
- How will they discover this feature?
- What does success look like for them?

---

### Phase 2: Quick Context Scan

**This is a QUICK scan, not a deep dive. Deep investigation is discovery's job.**

**Step 2.1 — Doc Scan (5 minutes max):**

**Reference & System Documentation:**
```bash
# Key constraints from reference docs
ls "${PROJECT_ROOT}/docs/reference/" 2>/dev/null
ls "${PROJECT_ROOT}/docs/systems/" 2>/dev/null

# Past learnings
grep -rl "{keywords}" "${PROJECT_ROOT}/docs/learnings/" 2>/dev/null

# Research brief (if research skill was run)
cat "${PROJECT_ROOT}/docs/research/{feature}/research-brief.md" 2>/dev/null
```

Note: key constraints, established patterns, relevant learnings. Do NOT deep-dive.

**Step 2.2 — Surface Pattern Check:**

- What similar features exist in this codebase? (names and relevance only)
- Any obvious technical constraints from the stack?
- Any blockers already known?

---

### Phase 3: Define Boundaries

**Step 3.1 — Minimum Viable Version:**

Ask: **"What's the smallest version that would be useful?"**

- What can we defer to v2?
- Nice-to-have vs. must-have?
- What would a 1-day version look like?

**Step 3.2 — Complexity Budget:**

Ask: **"How much complexity is this problem worth?"**

```markdown
## Complexity Budget
- Maximum new services: {0-2 typically}
- Maximum new screens: {estimate}
- Estimated effort: {Low/Medium/High}
- Maintenance cost we accept: {Low/Medium/High}
```

**Step 3.3 — Anti-Requirements & Kill Criteria:**

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
```

---

### Phase 4: Generate & Compare Approaches

**Step 4.1 — Create 2-3 Distinct Options:**

Each approach should be genuinely different, not variations:

Present summary to user:
```markdown
### Approach A: {Name}
**Core idea:** {1 sentence}
**How it works:** {2-3 sentences, conceptual}
**Pros:** {benefits}
**Cons:** {drawbacks}
**Complexity:** Low/Medium/High
**Within budget:** Yes/No

### Approach B: {Name}
...

### Approach C: Do Less
**Core idea:** {minimal or no change}
**When this is right:** {conditions}
```

**Always include "Do Less" option.**

**Step 4.2 — Comparison Matrix:**

| Approach | Complexity | Risk | Builds On Existing | Recommendation |
|----------|-----------|------|-------------------|----------------|
| A | Medium | Low | Yes — existing patterns | ✅ Preferred |
| B | High | Medium | No — new design | Fallback |
| C: Do Less | Low | Low | N/A | If budget is tight |

**Step 4.3 — Present and Iterate:**

Ask: **"Which approach resonates?"**

Iterate until user aligns on direction.

---

### Phase 5: Scope Classification

**After approach is selected, classify the feature to determine pipeline depth.**

Scan for complexity signals:

```markdown
## Scope Classification

Signals detected (weighted):
- [ ] (×2) Auth/identity/security involvement
- [ ] (×2) Regulatory or compliance requirements (POPIA, SOC 2)
- [ ] (×1) Multiple user roles or personas
- [ ] (×1) External system integrations
- [ ] (×1) New data model with 5+ entities
- [ ] (×1) UI-heavy with multiple screens (3+)
- [ ] (×1) Cross-system data flows
- [ ] (×1) Background processing / async workflows

Weighted score:
- 0-2 points: BRIEF
- 3-4 points: STANDARD
- 5+ points: COMPREHENSIVE
```

| Scope | Pipeline Depth | What Gets Generated |
|-------|---------------|---------------------|
| BRIEF | brainstorm → plan → beads | Lightweight — skip PRD, discovery, and full design |
| STANDARD | brainstorm → prd (standard) → technical-design → plan → beads | Normal — skip discovery |
| COMPREHENSIVE | brainstorm → discovery → prd (full) → technical-design → plan → beads | Full depth — all phases |

---

### Phase 6: Self-Review

**1 round, 3 themes. Brainstorm is lean — don't over-review.**

**Theme 1: Problem Clarity**
- [ ] Root problem identified (not symptom)?
- [ ] 5 Whys completed?
- [ ] User journey clear and realistic?

**Theme 2: Boundary Discipline**
- [ ] Must-haves truly essential?
- [ ] Anti-requirements prevent scope creep?
- [ ] Complexity budget explicit?

**Theme 3: Approach Differentiation**
- [ ] 2-3 genuinely different options (not variations)?
- [ ] "Do Less" included?
- [ ] At least one within complexity budget?

---

### Phase 7: Output & Route

**Create brainstorm document:**

Save to: `${PROJECT_ROOT}/docs/brainstorm/{feature}/brainstorm.md`

```markdown
# Brainstorm: {Feature Name}

> Problem framing and approach selection for {feature}.

## Problem Statement
### Surface Request
{What user asked for}

### Root Problem (5 Whys)
{The underlying issue discovered through 5 Whys}

### User Journey
{How users will discover and use this}

## Context
### Key Constraints
{From docs/reference/ and docs/learnings/}

### Similar Features
{Names and brief relevance — surface level only}

## Boundaries
### Must Have (v1)
- {essential}

### Deferred (v2+)
- {future}

### Anti-Requirements
- Must NOT: {explicit exclusion}

### Complexity Budget
- Effort: {Low/Medium/High}
- Max new services: {N}

## Approaches Compared
### Approach A: {Name}
{Core idea, how it works, pros/cons, complexity}

### Approach B: {Name}
{Core idea, how it works, pros/cons, complexity}

### Approach C: Do Less
{Minimal change option}

### Comparison
| Approach | Complexity | Risk | Recommendation |
|----------|-----------|------|----------------|

### Selected: {Approach Name}
{Why this approach was chosen}

## Scope Classification
**Scope:** {BRIEF | STANDARD | COMPREHENSIVE}
**Signals:** {list of detected signals}

## Self-Review
{Theme results — pass/fail}

## Next Step
**Recommended:** {/discovery | /prd | /technical-design | /plan}

---
*Brainstorm completed: {date}*
```

**Present routing to user:**

```markdown
## Brainstorm Complete

**Feature:** {name}
**Root Problem:** {1 sentence}
**Selected Approach:** {name}
**Scope:** {BRIEF | STANDARD | COMPREHENSIVE}

What's next?
1. "start discovery" → /discovery (COMPREHENSIVE features — deep requirements elicitation)
2. "start prd" → /prd (STANDARD features or known requirements)
3. "start technical-design" → /technical-design (technical improvement, skip PRD)
4. "start plan" → /plan (BRIEF features, simple changes)
5. "refine" → continue iterating
6. "park" / "abandon"
```

---

## Exit Signals

| Signal | Next Skill | When to Recommend |
|--------|-----------|-------------------|
| "start discovery" | /discovery | COMPREHENSIVE scope, complex domain |
| "start prd" | /prd | STANDARD scope, or requirements already clear |
| "start technical-design" | /technical-design | Technical improvement, no business requirements needed |
| "start plan" | /plan | BRIEF scope — plan works from brainstorm directly, no design doc needed |
| "refine" | Continue brainstorm | User wants to iterate |
| "park" | Save for later | |
| "abandon" | Don't proceed | |

---

## Anti-Patterns

❌ **Deep-diving into codebase patterns** — that's discovery's job
✅ **Quick scan for constraints and similar features**

❌ **Writing detailed requirements** — that's PRD's job
✅ **Defining boundaries and approaches**

❌ **File-level thinking** — "Update CombatService.cs"
✅ **Component-level thinking** — "Combat resolution determines outcomes"

❌ **Skipping "Do Less"** — always include minimal option
✅ **Genuine alternatives** — different approaches, not variations

---

*Skill Version: 2.0*
