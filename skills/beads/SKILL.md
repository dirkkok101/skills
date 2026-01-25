---
name: beads
description: Convert approved plans into intent-based beads with self-assessment gate. Each bead is a work package for a sub-agent that loads surgical context to implement. No source code in beads.
disable-model-invocation: true
argument-hint: "[feature-name] or path to plan"
---

# Beads: Plan → Intent-Based Work Packages

**Philosophy:** Each bead is a self-contained work package for a sub-agent. Beads contain INTENT, not implementation. The sub-agent loads surgical context, designs on-the-fly, implements, and verifies. Beads are sized by context management, not time estimates.

## Core Principles

1. **Intent over implementation** - Objectives and criteria, not source code
2. **Context references** - Point to what to read, don't duplicate it
3. **Sub-agent execution model** - Each bead is independently executable
4. **Self-assessment gate** - "Ready" vs "Needs: [specific thing]"
5. **Context-scoped sizing** - Can a sub-agent load this context and complete effectively?

---

## Trigger Conditions

Run this skill when:
- Plan has been approved (`/plan` completed)
- User says "plan approved", "create beads", "beads for..."
- Plan exists at `docs/plans/{feature}/overview.md`

## Prerequisites

Before starting, verify:
- [ ] Plan exists at `docs/plans/{feature}/overview.md`
- [ ] Plan has been approved by user
- [ ] If no plan, run `/plan` first

---

## Sub-Agent Execution Model

When a sub-agent executes a bead:

```
1. READ BEAD
   ↓ Parse objective, criteria, context references

2. LOAD CONTEXT
   ↓ Read specified files surgically
   ↓ Understand patterns from referenced code
   ↓ Check relevant docs/learnings

3. DESIGN
   ↓ Plan implementation based on loaded context
   ↓ Validate design against bead objectives
   ↓ If uncertain → ASK user, don't guess

4. IMPLEMENT
   ↓ Write code following codebase patterns
   ↓ Apply project standards (CLAUDE.md)

5. VERIFY
   ↓ Run specified tests
   ↓ Self-review against success criteria
   ↓ Check failure criteria weren't violated

6. COMPLETE
   ↓ Commit with specified message
   ↓ Close bead
```

---

## Bead Size Heuristic

**The right size is determined by context management:**

```
Can a sub-agent:
1. Load all required context into working memory?
2. Hold the full scope of change in mind?
3. Complete the work without losing track?

If NO to any → Split the bead
```

**Split signals:**
- Context list > 4-5 files → too broad
- Multiple unrelated concerns → split by concern
- "And then..." in objective → split at conjunction
- Changes span multiple services → one bead per service
- Both tests AND implementation → consider separating

**Good bead scope:**
- Single logical change
- 1-3 files to modify
- Clear "done" state
- Independent from other beads (after dependencies)

---

## Critical Sequence

### Phase 1: Load Plan Context

**Step 1.1 - Find Plan:**
```bash
ls docs/plans/{feature}/
```

**Step 1.2 - Read Plan Files:**
- Read `overview.md` for structure
- Read each sub-plan for task details
- Note dependencies between components

**Step 1.3 - Extract Tasks:**
For each task in sub-plans, capture:
- Objective
- Success criteria
- Failure criteria
- Pattern references
- Verification approach

---

### Phase 2: Create Epic

```bash
br create "Feature: {feature-name}" --type feature -p 2
```

Record epic ID for linking.

---

### Phase 3: Create Intent-Based Beads

**For each task, create a bead:**

```bash
br create "{Task title}" --type task -p 2
```

**Bead Description Format:**

```markdown
## Objective
{What to achieve - 1-2 sentences from plan}

## Success Criteria
- {Observable outcome}
- {Observable outcome}

## Failure Criteria
- ❌ {Anti-pattern from plan}
- ❌ {Common mistake to avoid}

## Context to Load
- **Read:** `{file path}` - {why: understand X}
- **Pattern:** `{file path}` - {why: follow pattern for Y}
- **Reference:** `{doc path}` - {why: formula/rule for Z}

## Approach
{Brief description or pseudocode from plan - NOT implementation code}

## Verification
- **Test:** {What behavior to test}
- **Command:** `dotnet test --filter "{TestPattern}"`
- **Commit:** `{type}({scope}): {message}`
```

---

### What Beads Do NOT Contain

❌ **Source code**
```csharp
// DON'T include implementation
public bool KnownCursed { get; init; }
```

❌ **Test code**
```csharp
// DON'T include test implementation
[Fact]
public void Test() { ... }
```

❌ **Copy-paste snippets**
- Agent writes code by understanding patterns

❌ **Duplicated plan content**
- Reference the plan file if needed

---

### What Beads DO Contain

✅ **Clear objective**
```
Add KnownCursed boolean property to Item record to track curse discovery
```

✅ **Observable criteria**
```
- Property exists on Item record
- Defaults to false
- Serializes correctly
```

✅ **Context references**
```
- Read: Src/Models/Item.cs - understand existing curse flags
- Pattern: CursedForOwner property - follow same pattern
```

✅ **Approach guidance**
```
Follow existing boolean property pattern.
Property should use same serialization as other flags.
```

---

### Phase 4: Add Labels

```bash
br label add bd-{id} model          # Data structure changes
br label add bd-{id} service        # Business logic
br label add bd-{id} test           # Test-focused task
br label add bd-{id} integration    # Cross-component wiring
br label add bd-{id} config         # Configuration changes
```

---

### Phase 5: Set Dependencies

**Link beads based on plan dependencies:**

```bash
# Task 2 depends on Task 1
br dep add bd-{task2} bd-{task1}

# All tasks link to epic
br dep add bd-{task1} bd-{epic}
```

**Verify:**
```bash
br dep cycles    # Should be empty
br dep tree bd-{epic}
br ready         # Should show first task(s)
```

---

### Phase 6: Self-Assessment Gate

**Critical: Evaluate each bead's readiness before presenting.**

For each bead, answer: **"Can I execute this bead with 100% confidence to the code quality, design, and performance this project demands?"**

**Pre-Assessment Checks:**
```bash
# Check learnings for relevant lessons
grep -r "{keywords}" docs/learnings/

# Verify pattern references exist
ls {pattern file paths from beads}
```

**Assessment Categories:**

| Status | Meaning | Action |
|--------|---------|--------|
| ✓ Ready | Clear objective, known pattern, manageable context | Proceed |
| ⚠ Needs: [X] | Missing specific information | Add to bead |
| ✗ Too Large | Context exceeds working memory | Split into sub-beads |

**Common "Needs" items:**
- Needs: pattern reference (don't know which service to follow)
- Needs: clarification (objective is ambiguous)
- Needs: context file (missing key dependency)
- Needs: formula reference (calculation not specified)
- Needs: learning applied (relevant lesson not referenced)

**Run Assessment:**

```markdown
## Bead Readiness Assessment

| Bead | Status | Notes |
|------|--------|-------|
| bd-001: Add KnownCursed property | ✓ Ready | Pattern clear from Item.cs |
| bd-002: Set flag on equip | ✓ Ready | EquipmentService pattern known |
| bd-003: Shop identify detection | ⚠ Needs: pattern | Which method handles shop identify? |
| bd-004: Block cursed item sale | ✓ Ready | ShopService.SellItem clear |
| bd-005: Full integration test | ✗ Too Large | Covers 3 different flows |
```

**Resolution:**

For "Needs" items:
- Research and add missing context reference
- Clarify objective with more specific language
- Add pattern reference from codebase

For "Too Large" items:
- Split into focused sub-beads
- Each sub-bead gets own assessment

```markdown
### Resolutions Applied

**bd-003:** Added context reference to ShopService.IdentifyItem pattern

**bd-005:** Split into:
- bd-005a: Integration test - equip curse detection flow
- bd-005b: Integration test - shop identify curse flow
- bd-005c: Integration test - sell blocking flow
```

**Re-assess until ALL beads show "✓ Ready"**

---

### Phase 7: Verify Structure

```bash
# List all beads
br list --status open

# Check dependencies
br dep tree bd-{epic}

# Verify no cycles
br dep cycles

# Check what's ready to start
br ready
```

---

### Phase 8: Present to User

```markdown
## Beads Summary

**Feature:** {name}
**Epic:** bd-{epic-id}
**Beads:** {N} intent-based work packages

### Beads Created

| ID | Title | Status | Labels |
|----|-------|--------|--------|
| bd-{epic} | Feature: {name} | Epic | - |
| bd-001 | {title} | ✓ Ready | model |
| bd-002 | {title} | ✓ Ready | service |
| bd-003 | {title} | ✓ Ready | service |
| ... | ... | ... | ... |

### Sample Bead

```
{Show br show bd-{first-task} to demonstrate format}
```

### Dependency Tree

```
{Output from br dep tree bd-{epic}}
```

### Ready to Start

```
{Output from br ready}
```

### Self-Assessment Summary

| Category | Count |
|----------|-------|
| ✓ Ready | {N} |
| ⚠ Resolved | {N} (details below) |
| ✗ Split | {N} into {M} sub-beads |

**Resolutions Applied:**
- bd-003: Added ShopService.IdentifyItem pattern reference
- bd-005: Split into 3 focused integration test beads

---

All beads assessed as Ready.

Options:
1. "beads approved" → Proceed to /execute
2. Request changes to specific beads
3. "assess bd-XXX" → Re-evaluate specific bead
4. "back to plan" → Revise plan first
```

---

## Quality Standards

### Bead Content
- Intent-based (no source code)
- Context references (not duplicated content)
- Observable success criteria
- Specific pattern references
- Clear verification approach

### Self-Assessment
- Every bead evaluated
- "Ready" vs "Needs: [X]" determination
- Unready beads resolved before presenting
- Large beads split
- All beads Ready before approval

### Context Management
- Beads sized by context load
- 1-3 files to modify typical
- References point to patterns, don't copy them
- Sub-agent can hold full scope in working memory

---

## Bead Examples

### Good Example ✅

```markdown
## Objective
Add KnownCursed boolean property to Item record to track when player discovers an item is cursed.

## Success Criteria
- Property exists on Item record
- Defaults to false
- Follows same pattern as existing curse flags
- Serializes/deserializes correctly

## Failure Criteria
- ❌ Don't add redundant properties
- ❌ Don't break existing serialization

## Context to Load
- **Read:** `Src/Models/Item.cs` - understand existing curse flag pattern
- **Pattern:** `CursedForOwner` property - follow same structure
- **Reference:** `docs/plans/curse-awareness/01-models.md` - design rationale

## Approach
Add boolean property following existing pattern. Use same default and serialization approach as CursedForOwner.

## Verification
- **Test:** Property exists and defaults correctly
- **Command:** `dotnet test --filter "Item_KnownCursed"`
- **Commit:** `feat(models): add KnownCursed property to Item`
```

### Bad Example ❌

```markdown
## Task 2

Add the KnownCursed property:

```csharp
public bool KnownCursed { get; init; }
```

Then add this test:

```csharp
[Fact]
public void Item_HasKnownCursedProperty()
{
    var item = new Item { KnownCursed = true };
    item.KnownCursed.Should().BeTrue();
}
```

See plan for details.
```

**Why bad:**
- Contains source code (agent should write this)
- Contains test code (agent should design this)
- Vague "see plan" reference
- No context references
- No success/failure criteria

---

## Handling Execution Uncertainty

When a sub-agent starts a bead and becomes uncertain:

**DO:**
- Ask user for clarification
- Request additional context
- Pause and explain what's unclear

**DON'T:**
- Guess at implementation
- Deviate from objective
- Skip verification

**The bead should be written well enough that asking is rare.** If agents frequently need to ask during execution, improve bead quality at creation time.

---

## Exit Signals

| Signal | Meaning |
|--------|---------|
| "beads approved" | Proceed to /execute |
| "adjust beads" | Modify specific beads |
| "reassess" | Re-run self-assessment |
| "back to plan" | Return to /plan |

When approved: **"Beads approved. Run /execute to start implementation."**
