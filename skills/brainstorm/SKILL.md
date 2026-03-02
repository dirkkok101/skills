---
name: brainstorm
description: Ideation and problem exploration phase. Uses 5 Whys to find root problems, reviews documentation and research, generates 2-3 distinct approaches, and routes to the appropriate next skill (PRD, technical-design, or plan). Use when starting any new feature, refactoring, or when user says 'brainstorm', 'let's explore', 'how should we approach'.
argument-hint: "[feature description]"
---

# Brainstorm: Problem → Validated Approach

**Philosophy:** Understand the RIGHT problem before solving it. Build on existing documentation and learnings. The best approach might be smaller than expected. Output becomes permanent project documentation.

## Core Principles

1. **Problem over solution** - 5 Whys to find root cause
2. **Documentation-first** - Leverage existing docs, create lasting reference
3. **Learnings-informed** - Every decision references relevant past lessons
4. **Component-focused** - Responsibilities and patterns, not file paths
5. **Scope discipline** - Define boundaries before generating approaches

---

## Trigger Conditions

Run this skill when:
- Starting a new feature or significant refactoring
- User describes a rough idea needing refinement
- User says "brainstorm", "let's explore", "how should we approach"
- You need to validate problem before moving to design or planning

---

## Critical Sequence

### Phase 0: Prerequisites Check

**Step 0.1 - Resolve Project Root:**

**CRITICAL:** All documentation must be created in the project root `docs/` folder, not in subdirectories like `tools/*/docs/`.

```bash
# Resolve project root (works in worktrees too)
PROJECT_ROOT=$(git rev-parse --show-toplevel)
echo "Project root: ${PROJECT_ROOT}"

# Verify docs folder exists at project root
ls "${PROJECT_ROOT}/docs/"
```

All subsequent paths in this skill use `${PROJECT_ROOT}/docs/` to ensure documentation lands in the correct location regardless of current working directory.

**Step 0.2 - Check for Existing Work:**

```bash
# Check for existing beads related to this feature
br search "{feature keywords}"
br list --status open

# Check for existing designs and plans (use absolute paths)
ls "${PROJECT_ROOT}/docs/designs/"
ls "${PROJECT_ROOT}/docs/plans/"

# Check for related learnings
ls "${PROJECT_ROOT}/docs/learnings/"
```

**Verify:**
```
[ ] PROJECT_ROOT resolved correctly (shows project root path)
[ ] No existing beads for this feature (or they're closed/abandoned)
[ ] No existing design document (or it's outdated)
[ ] Checked learnings for related past work
```

**If existing work found:**
- Review it first
- Ask user: "Found existing {beads/design/plan}. Should we build on this or start fresh?"

---

### Phase 1: Understand the Problem (Not the Solution)

**Step 1.1 - The 5 Whys:**
Before accepting the problem statement, dig deeper:

```
User: "I want to add a minimap to the dungeon view"
Why? → "So players can see where they've been"
Why does that matter? → "They get lost and frustrated"
Why do they get lost? → "Dungeon layouts are confusing"
Why are they confusing? → "No landmarks, all corridors look the same"
Root Problem: Navigation feedback, not necessarily a minimap
```

Ask: **"What's the pain point you're trying to solve?"** then follow up with "Why?" until you reach the root.

**Step 1.2 - Validate It's Worth Solving:**
```
[ ] What happens if we DON'T solve this?
[ ] Is this solving a symptom or root cause?
[ ] Is this the right time to solve it?
[ ] Who is asking for this and why?
```

**Step 1.3 - Understand the User Journey:**
- Who uses this feature?
- What's their current workflow?
- How will they discover this feature?
- What triggers them to use it?
- What does success look like for them?

Ask: **"Walk me through how a player would use this"**

---

### Phase 2: Documentation & Research Review

**Systematically review project documentation and research patterns.**

#### Step 2.1 - Documentation Review

**Reference & System Documentation:**
```bash
# Check reference docs (use absolute path)
ls "${PROJECT_ROOT}/docs/reference/"
ls "${PROJECT_ROOT}/docs/systems/"
ls "${PROJECT_ROOT}/docs/architecture/"

# Check for research brief
ls "${PROJECT_ROOT}/docs/research/{feature}/" 2>/dev/null || echo "No research brief found"
```

For each relevant doc:
- What rules/constraints must we follow?
- What patterns are already established?
- What decisions constrain this feature?

**Related Prior Work:**
```bash
# Find related designs and plans (absolute paths)
ls "${PROJECT_ROOT}/docs/designs/" 2>/dev/null
ls "${PROJECT_ROOT}/docs/plans/" 2>/dev/null
```

Document findings:
```markdown
### Documentation Foundation
| Document | Key Constraint or Pattern |
|----------|---------------------------|
| `docs/reference/{file}` | {rule we must follow} |
| `docs/systems/{file}` | {existing pattern} |
| `docs/research/{feature}/research-brief.md` | {if exists, key findings} |
```

#### Step 2.2 - Learnings & Codebase Patterns

**Learnings Integration:**
```bash
# Search for relevant learnings (absolute path)
grep -r "{keywords}" "${PROJECT_ROOT}/docs/learnings/" 2>/dev/null
```

**Codebase Research (Parallel Agents):**

Launch research tracks:
```
[ ] "How does {similar feature} work in this codebase?"
[ ] "What services would be affected by {feature}?"
[ ] "How are similar features tested?"
```

Also check: Original Wizardry approach, similar dungeon crawlers, Godot framework patterns.

Document what you learn:
```markdown
### Research Foundation
**Codebase patterns:** {similar features and services to follow}
**Learnings applied:** {past lessons that inform this}
**External insights:** {original Wizardry or game design patterns}
**Research brief findings:** {if exists at docs/research/{feature}/research-brief.md}
```

---

### Phase 3: Synthesize & Define Boundaries

**Step 3.1 - Minimum Viable Version:**
Ask: **"What's the smallest version that would be useful?"**

Strip away non-essential:
- What can we defer to v2?
- Nice-to-have vs. must-have?
- What would a 1-day version look like?

**Step 3.2 - Complexity Budget:**
Ask: **"How much complexity is this problem worth?"**

```markdown
## Complexity Budget
- Maximum new services: {0-2 typically}
- Maximum components: {estimate}
- Maintenance cost we accept: {Low/Medium/High}
```

**Step 3.3 - Anti-Requirements & Kill Criteria:**

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
- {technical blocker discovered}
- {user feedback that changes direction}
- Complexity exceeds budget by 50%+
```

---

### Phase 4: Generate & Compare Approaches

**Step 4.1 - Create 2-3 Distinct Options:**

Each approach should be genuinely different, not variations:

```markdown
### Approach A: {Name}
**Core idea:** {1 sentence}
**How it works:** {2-3 sentences, conceptual}
**Pros:**
- {benefit}
**Cons:**
- {drawback}
**Complexity:** Low/Medium/High
**Within budget:** Yes/No

### Approach B: {Name}
...

### Approach C: Do Less
**Core idea:** {minimal or no change}
**When this is right:** {conditions}
```

**Always include "Do Less" option.**

**Step 4.2 - Comparison Matrix:**

| Approach | Complexity | Risk | Builds On | Recommendation |
|----------|-----------|------|-----------|----------------|
| A | Medium | Low | Existing patterns | ✅ Preferred |
| B | High | Medium | New design | Fallback |
| C | Low | Low | Minimal change | Simpler path |

**Step 4.3 - Present to User:**
Ask: **"Which approach resonates?"**

After feedback, synthesize if needed. Iterate until user aligns on direction.

---

### Phase 5: Self-Review & Route

**Two review rounds minimum. Exit criteria: zero issues in a round after fixing all issues in the prior round.**

#### Review Themes (5 themes, apply all each round)

**Theme 1: Problem Clarity**
- Root problem identified (not symptom)
- 5 Whys completed
- User journey is clear and realistic

**Theme 2: Research Grounding**
- Reference docs consulted and applied
- Related work reviewed
- Learnings inform decisions
- Research brief integrated (if exists)

**Theme 3: Boundary Discipline**
- Must-haves truly essential
- Deferred items explicit
- Anti-requirements prevent scope creep
- Complexity budget is explicit

**Theme 4: Approach Differentiation**
- 2-3 genuinely different options
- "Do less" option included
- Each builds on existing patterns
- At least one within budget

**Theme 5: Feasibility**
- No technical blockers identified
- Timeline reasonable
- Team has required skills/knowledge
- Clear next steps to detailed design

---

#### Self-Review Log Format

```markdown
## Self-Review Log

### Round 1 (fresh read)
**Issues Found:** 2
- [Boundaries] Anti-requirements unclear
  → Fix: Clarified what we're NOT building
- [Approaches] Missing "do less" option
  → Fix: Added minimal approach C

### Round 2 (fresh read)
**Issues Found:** 0
- All 5 themes pass ✅
```

---

### Phase 6: Output & Route

**Create brainstorm document:**

```markdown
# Brainstorm: {Feature Name}

> Exploration and approach comparison for {feature}.

## Problem Statement
### Surface Request
{What user asked for}

### Root Problem (5 Whys)
{The underlying issue discovered}

### User Journey
{How users will discover/use this}

## Research Foundation
### Documentation Consulted
{Reference docs, systems, architecture reviewed}

### Learnings Applied
{Past lessons that inform this}

### Research Brief Findings
{If exists at docs/research/{feature}/research-brief.md}

### Codebase Patterns
{Existing patterns to follow}

## Boundaries
### Must Have (v1)
- {essential}

### Deferred (v2+)
- {future}

### Anti-Requirements
- Must NOT: {explicit exclusion}

### Kill Criteria
- Abandon if: {invalidating condition}

### Complexity Budget
- Services: {number}
- Estimated effort: {Low/Medium/High}

## Approaches Compared
### Approach A: {Name}
{Core idea, how it works, pros/cons, complexity, recommendation}

### Approach B: {Name}
{Core idea, how it works, pros/cons, complexity, recommendation}

### Approach C: Do Less
{Minimal change option}

### Comparison Matrix
{Risk, complexity, alignment with patterns}

### Recommendation
{Suggested direction with reasoning}

## Self-Review Log
{Review rounds with issues and fixes}

## Open Questions
- {unresolved items for user}

---
*Brainstorm completed: {date}*
*Next step: /prd or /technical-design or /plan*
```

Save to: `${PROJECT_ROOT}/docs/brainstorm/{feature}/brainstorm.md`

**Exit Signals & Routing:**

Present summary to user:
```markdown
## Brainstorm Summary

**Feature:** {name}
**Root Problem:** {1 sentence}
**Recommended Approach:** {name}
**Complexity:** {Low/Medium/High}

What's next?
1. "start prd" → Proceed to /prd (business feature, needs PRD first)
2. "start technical-design" → Proceed to /technical-design (technical improvement)
3. "start plan" → Proceed to /plan (simple change, skip PRD/design)
4. "refine" → Continue iterating here
5. "park" → Save for later
6. "abandon" → Don't build this
```

---

## Quality Standards

### Problem Understanding
- 5 Whys to find root cause (not symptom)
- User journey mapped and realistic
- Worth solving validated

### Research Grounding
- Reference docs consulted and applied
- Related work reviewed
- Learnings explicitly inform choices
- Research brief integrated (if exists)

### Boundaries
- Minimum viable clearly defined
- Complexity budget explicit
- Anti-requirements prevent scope creep
- Kill criteria clear

### Approaches
- 2-3 genuinely different options
- "Do less" option included
- Each builds on existing patterns
- At least one within complexity budget

### Brainstorm Output
- Component-level thinking (not file-level)
- Permanent project documentation
- Rationale captured for future developers
- Trade-offs explicit

### Self-Review
- Minimum 2 rounds
- All 5 themes applied each round
- Issues fixed before next round
- Exit: zero issues in consecutive round

---

## Anti-Patterns

❌ **File-level thinking**
"Update CombatService.cs and Monster.cs"

✅ **Component-level thinking**
"Combat resolution component determines outcomes. Builds on AttackService pattern."

❌ **Implementation details**
"Add public bool CanFlee(Party, Encounter)"

✅ **Conceptual design**
"Combat system determines escape viability based on encounter type and dungeon level."

❌ **Ignoring documentation**
"I think the formula should be..."

✅ **Building on documented constraints**
"Per docs/reference/combat-formulas.md, hit chance uses [formula]. This approach honors that."

---

## Exit Signals & Next Skills

| Signal | Next Skill |
|--------|----------|
| "start prd" | /prd (user-facing feature needing business context) |
| "start technical-design" | /technical-design (technical improvement needing detailed design) |
| "start plan" | /plan (simple change, skip PRD & design) |
| "refine" | Continue iterating brainstorm |
| "park" | Save brainstorm for later |
| "abandon" | Don't proceed with this idea |

**Exit message:** Provide clear routing based on feature type and next skill invocation.
