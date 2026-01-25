---
name: brainstorm
description: Transform rough ideas into validated designs through deep understanding, research, and documentation synthesis. Designs become permanent project documentation.
disable-model-invocation: true
argument-hint: "[feature description]"
---

# Brainstorm: Idea → Validated Design

**Philosophy:** Understand the RIGHT problem before solving it. Build on existing documentation and learnings. The best design might be smaller than expected. Designs become permanent project documentation.

## Core Principles

1. **Problem over solution** - 5 Whys to find root cause
2. **Documentation-first** - Leverage existing docs, create lasting documentation
3. **Human context management** - Hierarchical output for reviewable layers
4. **Learnings-informed** - Every decision references relevant past lessons
5. **Component-focused** - Responsibilities and patterns, not file paths

---

## Trigger Conditions

Run this skill when:
- Starting a new feature
- Beginning significant refactoring
- User describes a rough idea that needs refinement
- User says "let's brainstorm", "I want to build...", "how should we..."

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

### Phase 2: Documentation Deep Dive

**This is the foundation of good design. Systematically review project documentation.**

#### Step 2.1 - Mandatory Documentation Review

| Category | What to Check | How It Informs Design |
|----------|---------------|----------------------|
| **Reference Docs** | `docs/reference/` | Formulas, rules, constraints that MUST be followed |
| **System Docs** | `docs/systems/` | How affected systems currently work |
| **Architecture** | `docs/architecture/` | Patterns, service layer design to follow |
| **Learnings** | `docs/learnings/` | Past mistakes to avoid, patterns that worked |

**Reference Documentation Checklist:**
```
[ ] ${PROJECT_ROOT}/docs/reference/combat-formulas.md - If combat-related
[ ] ${PROJECT_ROOT}/docs/reference/characters.md - If character/stats related
[ ] ${PROJECT_ROOT}/docs/reference/spells.md - If magic-related
[ ] ${PROJECT_ROOT}/docs/reference/items.md - If equipment/inventory related
[ ] ${PROJECT_ROOT}/docs/reference/monsters.md - If monster-related
[ ] ${PROJECT_ROOT}/docs/reference/traps.md - If trap/chest related
[ ] ${PROJECT_ROOT}/docs/reference/treasure.md - If loot-related
[ ] ${PROJECT_ROOT}/docs/systems/{relevant-system}.md - For affected systems
[ ] ${PROJECT_ROOT}/docs/architecture/service-layer.md - For service design patterns
```

#### Step 2.2 - Related Designs and Plans

**Check for related prior work:**

```bash
# Find related designs (use absolute paths)
ls "${PROJECT_ROOT}/docs/designs/"

# Find related plans
ls "${PROJECT_ROOT}/docs/plans/"
```

For each related design/plan found:
- What decisions were made that affect this feature?
- What components already exist that we can leverage?
- What boundaries were set that we should respect?
- What was deferred that might now be relevant?

**Document connections:**
```markdown
### Related Prior Work

| Document | Relationship | Key Decisions to Honor |
|----------|--------------|------------------------|
| `docs/designs/{related}/design.md` | {how it relates} | {decisions that constrain us} |
| `docs/plans/{related}/overview.md` | {how it relates} | {patterns established} |
```

#### Step 2.3 - Learnings Integration

**Learnings are lessons paid for with past effort. Use them.**

```bash
# Search learnings for relevant entries (use absolute path)
grep -r "{keywords}" "${PROJECT_ROOT}/docs/learnings/"
```

For each relevant learning:
- What was the root cause?
- How does it apply to this design?
- What should we do differently?

**Document how learnings inform design:**
```markdown
### Learnings Applied

| Learning | From | How It Applies |
|----------|------|----------------|
| {lesson title} | `docs/learnings/{category}.md` | {how we'll apply it} |
| {lesson title} | `docs/learnings/{category}.md` | {what we'll avoid} |
```

#### Step 2.4 - Data Files Review

**Identify game data that's relevant:**

| Data Type | Location | When to Check |
|-----------|----------|---------------|
| Game content | `Data/*.json` | Feature affects monsters, spells, items |
| Configuration | `Data/config/*.json` | Feature has configurable behavior |
| Maps | `Data/maps/*.json` | Feature affects dungeon behavior |

---

### Phase 3: Codebase Research (Parallel Agents)

**Launch research tracks in parallel:**

| Agent | Research Focus |
|-------|----------------|
| `Explore` | **Existing patterns:** "How does {similar feature} work in this codebase?" |
| `Explore` | **Affected services:** "What services would be affected by {feature}?" |
| `Explore` | **Test patterns:** "How are similar features tested?" |

**Also research external sources:**

| Source | What to Check |
|--------|---------------|
| Original Wizardry | How did the original game handle this? |
| Similar games | How do other dungeon crawlers solve this? |
| Godot docs | Framework patterns for this type of feature |

---

### Phase 4: Synthesize Research

**Consolidate all research into a coherent picture:**

```markdown
## Research Synthesis

### Documentation Foundation
**Reference docs consulted:** {list}
**Key rules/formulas that apply:**
- {rule from docs/reference/}
- {constraint from docs/systems/}

**Related designs/plans reviewed:** {list}
**Decisions we must honor:**
- {decision from prior design}
- {pattern from prior plan}

### Learnings Informing This Design
| Learning | Application |
|----------|-------------|
| {from docs/learnings/} | {how we'll use it} |

### Codebase Patterns to Follow
**Similar features:** {list with service names}
**Pattern to follow:** {which service/approach}
**Why this pattern:** {reasoning}

### Data Impact
**Data files affected:** {list}
**Config changes needed:** {list}

### External Research
**Original Wizardry:** {how it worked}
**Other insights:** {what we learned}

### Open Questions
- {questions that emerged from research}
```

---

### Phase 5: Define Boundaries

**Step 5.1 - Minimum Viable Version:**
Ask: **"What's the smallest version that would be useful?"**

Strip away everything that's not essential:
- What can we defer to v2?
- What's nice-to-have vs. must-have?
- What would a 1-day version look like?

**Step 5.2 - Complexity Budget:**
Ask: **"How much complexity is this problem worth?"**

```markdown
## Complexity Budget
- Maximum new services: {0-2 typically}
- Maximum components: {estimate}
- Acceptable test complexity: {unit only / integration needed}
- Maintenance cost we accept: {Low/Medium/High}
```

**If solution exceeds budget, simplify or defer.**

**Step 5.3 - Anti-Requirements:**
Explicitly define what this feature must NOT do:

```markdown
## Anti-Requirements (Explicit Exclusions)
- Must NOT: {thing we're explicitly not building}
- Must NOT: {scope we're excluding}
- Deferred to later: {future enhancements}
```

**Step 5.4 - Kill Criteria:**
Define when to abandon this approach:

```markdown
## Kill Criteria
Abandon this design if:
- {condition that would invalidate approach}
- {technical blocker we might discover}
- {user feedback that would change direction}
- Complexity exceeds budget by more than 50%
```

---

### Phase 6: Generate Approaches

**Step 6.1 - Create 2-3 Distinct Options:**

Each approach should be genuinely different, not variations:

```markdown
### Approach A: {Name} - {Philosophy}
**Core idea:** {1 sentence}
**How it works:** {2-3 sentences, conceptual}
**Builds on:** {which existing patterns/services}
**Pros:**
- {benefit}
**Cons:**
- {drawback}
**Complexity:** Low/Medium/High
**Within budget:** Yes/No/Borderline
**Reversibility:** Easy/Medium/Hard to undo
**Risk:** {main uncertainty}

### Approach B: {Name} - {Philosophy}
...

### Approach C: Do Less / Do Nothing
**Core idea:** {minimal or no change}
**When this is right:** {conditions}
```

**Always include a "do less" option** - sometimes the best design is smaller.

**Step 6.2 - Risk/Uncertainty Matrix:**

| Approach | Technical Risk | Design Risk | Complexity | Reversibility |
|----------|---------------|-------------|------------|---------------|
| A | Low | Medium | Medium | Easy |
| B | High | Low | High | Hard |
| C | None | High | Low | Easy |

---

### Phase 7: Self-Review Approaches

```
[ ] Are approaches genuinely different (not variations)?
[ ] Did I include a "do less" option?
[ ] Does each approach build on existing patterns?
[ ] Are risks and reversibility clear?
[ ] Is at least one option within complexity budget?
[ ] Is there a clear recommendation with reasoning?
```

---

### Phase 8: Synthesize with User

**Step 8.1 - Present Initial Options:**
Present approaches with clear recommendation.
Ask: **"Which approach resonates, or should we explore others?"**

**Step 8.2 - Synthesis Round:**
After user feedback, consider:
- Can we combine best parts of multiple approaches?
- Did feedback reveal new constraints?
- Should we adjust scope (bigger or smaller)?

**Step 8.3 - Iterate Until Aligned:**
Repeat until user says "that's the direction" or "design approved"

---

### Phase 9: Deep Dive Design

**Present in logical groups. After each group, ask: "Does this match your expectations?"**

**Group 1: Philosophy & Patterns**
- How this fits the codebase philosophy
- Which existing services/patterns to follow
- Key responsibilities and boundaries
- What this component owns vs. delegates

**Group 2: Component Responsibilities**
```markdown
| Component | Responsibility | Pattern Reference |
|-----------|----------------|-------------------|
| {name} | {what it owns} | {existing service to follow} |
```

**Group 3: Interfaces & Data Flow**
- How components communicate
- What data moves between them
- Key events/signals (conceptual, not implementation)

**Group 4: Error Handling Philosophy**
- What can go wrong (categories, not exhaustive)
- General approach to errors
- Graceful degradation strategy

**Group 5: Testing Philosophy**
```markdown
## Testing Philosophy

**What needs certainty:** {core behaviors that MUST be tested}
**Risk areas:** {where edge cases matter}
**Integration points:** {cross-service behaviors to verify}
**Approach:** Unit tests / Integration tests / Manual verification
```

**Group 6: Work Decomposition Preview**

This connects design to plan/bead structure:

```markdown
## Work Decomposition Preview

### Logical Components
| Component | Scope | Likely Sub-Plan |
|-----------|-------|-----------------|
| {name} | {what it covers} | {becomes a sub-plan} |

### Context Considerations
- Independent components: {can be worked separately}
- Coupled components: {need to be worked together}
- Large context areas: {may need splitting}

### Suggested Execution Order
1. {component} - foundation
2. {component} - builds on #1
3. {component} - integration
```

---

### Phase 10: Self-Review (Minimum 2 Rounds)

**Exit criteria:** Two consecutive rounds with zero issues found.
**Typical:** 2-3 rounds total.

**Review Process for EACH Round:**
1. Clear your mental context
2. Re-read the problem statement and user journey fresh
3. Re-read the design document fresh
4. Apply ALL review themes below
5. Fix any issues found
6. If issues found, proceed to next round
7. If no issues, check if previous round was also clean → exit

---

#### Review Themes (Apply ALL Each Round)

**Theme 1: Problem Understanding**
- Root problem identified (not just symptom)
- 5 Whys completed and documented
- User journey is clear and realistic

**Theme 2: Documentation Integration**
- Reference docs consulted and applied
- Related designs/plans reviewed
- Learnings explicitly inform decisions
- No contradictions with existing documentation

**Theme 3: Boundary Clarity**
- Must-haves are truly essential
- Deferred items are explicitly listed
- Anti-requirements prevent scope creep
- Complexity budget is explicit

**Theme 4: Approach Quality**
- 2-3 genuinely different options
- "Do less" option included
- Builds on existing patterns
- At least one option within budget

**Theme 5: Architecture Alignment**
- Follows patterns in docs/architecture/
- Consistent with docs/reference/ rules
- Reuses existing services where possible
- No unnecessary new abstractions

**Theme 6: Component Focus**
- Responsibilities are clear
- Patterns to follow are identified
- No file-level implementation details
- Interfaces are conceptual

**Theme 7: Testability**
- Testing philosophy is clear
- Core behaviors identified for testing
- Uses project test standards

**Theme 8: Work Decomposition**
- Components map to potential sub-plans
- Context requirements are considered
- Execution order is logical

**Theme 9: Documentation Value**
- Design reads as permanent documentation
- Rationale is captured for future developers
- Decisions and trade-offs are explicit

---

#### Review Log Format

```markdown
## Self-Review Log

### Round 1
**Issues Found:** 2
- [Documentation] Didn't check related combat design
  → Fix: Reviewed docs/designs/combat-rebalance/, updated constraints
- [Work Decomposition] Missing component breakdown
  → Fix: Added logical components table

### Round 2 (fresh read)
**Issues Found:** 1
- [Boundary] Nice-to-have crept into must-haves
  → Fix: Moved to deferred section

### Round 3 (fresh read)
**Issues Found:** 0
- All themes pass ✅
```

**Exit criteria:** Two consecutive rounds with zero issues found.

---

### Phase 11: Write Design Document

**Structure depends on complexity:**

#### Simple Features (Single File)
```
${PROJECT_ROOT}/docs/designs/{feature}/
└── design.md           # Complete design (~150-200 lines)
```

#### Complex Features (Hierarchical)
```
${PROJECT_ROOT}/docs/designs/{feature}/
├── design.md           # Overview (~100-150 lines)
├── architecture.md     # Deep dive on structure (optional)
├── data-flow.md        # How data moves (optional)
└── diagrams/           # Visual documentation
    └── {name}.md       # Mermaid diagrams
```

**IMPORTANT:** Always use the `${PROJECT_ROOT}` variable resolved in Phase 0 to ensure documentation is created in the project root, not in subdirectories.

---

#### Design Document Template

```markdown
# Design: {Feature Name}

> Validated design for {feature}. This document serves as permanent project documentation.

## Problem Statement

### Surface Request
{What the user initially asked for}

### Root Problem (5 Whys)
{The underlying issue discovered}

### User Journey
{How users will discover and use this feature}

---

## Documentation Foundation

### Reference Documentation Applied
| Document | Key Rules/Constraints |
|----------|----------------------|
| `docs/reference/{file}` | {what we must follow} |

### Related Designs & Plans
| Document | Decisions We Honor |
|----------|-------------------|
| `docs/designs/{related}/` | {constraints from prior work} |
| `docs/plans/{related}/` | {patterns established} |

### Learnings Applied
| Learning | From | How Applied |
|----------|------|-------------|
| {lesson} | `docs/learnings/{category}.md` | {application} |

---

## Boundaries

### Must Have (v1)
- {essential requirement}

### Deferred (v2+)
- {future enhancement}

### Anti-Requirements
- Must NOT: {explicit exclusion}

### Kill Criteria
- Abandon if: {invalidating condition}

### Complexity Budget
- Max new services: {number}
- Max components: {number}

---

## Chosen Approach

### Summary
{2-3 sentence description - conceptual, not implementation}

### Why This Approach
{Reasoning for selection over alternatives}

### Trade-offs Accepted
{What we're giving up}

### Alternatives Considered
| Approach | Why Not Chosen |
|----------|----------------|
| {name} | {reason} |

---

## Architecture

### Philosophy
{How this fits the codebase philosophy}

### Component Responsibilities
| Component | Responsibility | Pattern Reference |
|-----------|----------------|-------------------|
| {name} | {what it owns} | {existing service to follow} |

### Interfaces
{How components communicate - conceptual}

### Data Flow
{How data moves through the system}

```mermaid
{Optional: flow diagram}
```

---

## Error Handling

### Error Categories
| Category | Approach |
|----------|----------|
| {type of error} | {how handled} |

### Graceful Degradation
{What happens when things go wrong}

---

## Testing Philosophy

**Core behaviors requiring certainty:**
- {behavior}

**Risk areas for edge cases:**
- {area}

**Integration points:**
- {cross-service behavior}

---

## Work Decomposition Preview

### Logical Components
| Component | Scope | Likely Sub-Plan |
|-----------|-------|-----------------|
| {name} | {coverage} | {sub-plan name} |

### Context Considerations
{Notes on context management for execution}

### Suggested Execution Order
1. {component} - {why first}
2. {component} - {depends on #1}

---

## Open Questions
- {unresolved items for user}

## Rollback Plan
If this approach fails:
- {how to undo}
- {what to preserve}

---

*Design created: {date}*
*Documentation foundation: {list of docs consulted}*
```

---

### Phase 12: Present to User

```markdown
## Design Summary

**Feature:** {name}
**Root Problem:** {1 sentence}
**Chosen Approach:** {approach name}
**Complexity Budget:** {services}, {components}

### Documentation Foundation
- Reference docs: {count} consulted
- Related designs: {count} reviewed
- Learnings applied: {count}

### Self-Review Summary

| Round | Issues | Key Fixes |
|-------|--------|-----------|
| 1 | {n} | {summary} |
| 2 | {n} | {summary} |
| 3 | 0 | ✅ Exit criteria met |

### Design Document
Saved to: `${PROJECT_ROOT}/docs/designs/{feature}/design.md`

---

Ready for review. Options:
1. "design approved" → Proceed to /plan
2. "refine" → Continue iterating
3. "park" → Save for later
4. "abandon" → Don't build this
```

---

## Quality Standards

### Documentation Integration
- Reference docs consulted and applied
- Related designs/plans reviewed
- Learnings explicitly inform decisions
- No file-level implementation details

### Problem Understanding
- 5 Whys to find root cause
- User journey mapped
- Worth solving validated

### Boundaries
- Minimum viable defined
- Complexity budget set
- Anti-requirements explicit
- Kill criteria established

### Approaches
- 2-3 genuinely different options
- "Do less" option included
- Builds on existing patterns
- YAGNI applied ruthlessly

### Design Content
- Component responsibilities (not file paths)
- Pattern references (not implementation code)
- Conceptual interfaces (not method signatures)
- Testing philosophy (not test code)

### Self-Review
- Minimum 2 review rounds
- All 9 themes each round
- Issues fixed before next round
- Exit: 2 consecutive clean rounds

### Documentation Value
- Design is permanent project documentation
- Rationale captured for future developers
- Trade-offs explicit

---

## Anti-Patterns

❌ **File-level thinking in design**
```markdown
### Files to Change
- Src/Services/CombatService.cs
- Src/Models/Monster.cs
```

✅ **Component-level thinking**
```markdown
### Components
| Component | Responsibility | Pattern |
|-----------|----------------|---------|
| Combat resolution | Calculate outcomes | Follow AttackService |
| Monster behavior | AI decisions | Follow MonsterAIService |
```

❌ **Implementation details**
```markdown
Add method: `public bool CanFlee(Party party, Encounter encounter)`
```

✅ **Conceptual interface**
```markdown
Combat service needs to determine if party can flee based on
encounter type and dungeon level. Follow pattern in existing
escape-related logic.
```

❌ **Ignoring existing documentation**
"I think the formula should be..."

✅ **Building on documentation**
"Per docs/reference/combat-formulas.md, the hit chance formula is...
This design follows that constraint."

---

## Exit Signals

| Signal | Meaning |
|--------|---------|
| "design approved" | Proceed to /plan |
| "write the plan" | Proceed to /plan |
| "refine" | Continue iterating |
| "park" | Save, don't proceed |
| "abandon" | Don't build this |

When approved: **"Design approved. Run /plan to create implementation plan."**
