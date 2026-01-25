---
name: compound
description: Capture learnings from feature development to make future work easier. Called after review cycles during execute phase. Each call captures one focused learning.
argument-hint: "[learning-topic] or 'review' to process review findings"
---

# Compound: Feature Learning Capture

**Philosophy:** Large feature development produces valuable learnings at every phase. Capture them while context is fresh to make future features easier. One focused learning per call.

## Core Principles

1. **Phase-aware** - Learnings come from design, planning, execution, and review
2. **Explicit scope** - Know exactly what we're documenting
3. **Fresh context** - Compound immediately after the insight, not at end of feature
4. **Focused entries** - One learning per compound call, not batched
5. **Prevention-oriented** - How does this make future work easier?

---

## Trigger Conditions

**Agent-Initiated (Primary):**
The agent identifies learnings after fixing review issues and invokes compound with specific context. The user approves which learnings to capture, but the agent knows WHAT is worth capturing.

```
execute → review → fix → agent identifies learnings → user approves → agent compounds
```

**User-Initiated (Secondary):**
User can also invoke directly if they spot something the agent missed:
- "compound the null check pattern"
- "document this approach"

---

## Agent Invocation Protocol

**After fixing review issues, the agent should:**

1. **Evaluate each fix** against the "Future Pain" test:
   - Non-obvious? (took investigation)
   - Would recur in similar features?
   - Reveals process/skill/bead gap?

2. **Present identified learnings** to user:
   ```
   I identified 2 learnings from this review cycle:

   1. **Null safety in party iteration** (Gotcha_Pitfall)
      Party members can be null after death - need defensive checks

   2. **KnownCursed flag pattern** (Pattern_Discovery)
      Dual-flag pattern for player knowledge vs actual state

   Options: "compound all", "compound 1", "skip"
   ```

3. **On approval**, invoke compound with full context:
   - Agent provides topic, learning type, affected files
   - User doesn't need to specify anything

**Threshold for identification:**
- Would save >15 min in a future feature? → Identify
- Trivial fix, obvious mistake, one-off? → Skip

---

## Learning Sources by Phase

| Phase | What Produces Learnings | Examples |
|-------|------------------------|----------|
| **Design** | Research that revealed constraints | "Godot signals can't pass complex objects" |
| **Plan** | Task decomposition issues | "Bead was too large, needed splitting" |
| **Execute** | Missing context, pattern discovery | "Should have referenced XService pattern" |
| **Review** | Common issues found | "Null checks missing in party iteration" |

---

## Critical Sequence

### Phase 0: Determine Scope

**Agent-invoked (typical):**
Agent already identified the learning during post-review analysis. Context is known:
- Topic and learning type from identification step
- Files modified during the fix
- Why it's worth compounding

Proceed directly to Phase 1 with known context.

**User-invoked with argument:**
- Use argument as learning topic
- Example: `/compound null safety in party loops`
- Agent has recent context from conversation

**User-invoked without argument:**
Ask user to specify:
```
What learning would you like to capture?

Recent context:
- Git: {recent commits}
- Review: {if review ran recently, show findings}

Options:
1. Specific topic: "/compound [topic]"
2. From review: "/compound review"
3. Describe the learning you want to capture
```

---

### Phase 1: Gather Context

**Step 1.1 - Check Recent Activity:**
```bash
# Recent commits (what changed)
git log --oneline -10

# Files changed in current feature
git diff main --name-only

# Current bead context (if in execute phase)
br list --status in_progress
```

**Step 1.2 - Identify Learning Source:**

| Source | How to Find |
|--------|-------------|
| **Review finding** | User references specific issue from review |
| **Git commit** | Commit message describes what was fixed |
| **Bead execution** | Difficulty or insight during bead implementation |
| **Design evolution** | Approach changed from original design |

**Step 1.3 - Load Relevant Context:**
- Read files that were modified
- Check if related learnings already exist
- Review the design/plan if learning relates to them

---

### Phase 2: Classify Learning Type

| Type | When to Use | Focus |
|------|-------------|-------|
| **Pattern Discovery** | Found reusable code pattern | How to apply pattern |
| **Gotcha/Pitfall** | Hit a non-obvious issue | How to avoid it |
| **Design Validation** | Design decision proved correct/incorrect | Why it worked/didn't |
| **Process Improvement** | Workflow could be better | What to change |
| **Documentation Gap** | Missing docs caused confusion | What to document |
| **Context Gap** | Bead/plan missing needed context | What to include next time |

---

### Phase 3: Validate Against Schema

Read `.claude/skills/compound/schema.yaml` and validate:

```yaml
# Required fields
module: [Combat|Dungeon|Town|UI|Character|Party|Data|Services|Testing|Godot|Architecture|Performance]
date: YYYY-MM-DD
learning_type: [Pattern_Discovery|Gotcha_Pitfall|Design_Validation|Process_Improvement|Documentation_Gap|Context_Gap]
component: [specific component]
phase_discovered: [Design|Planning|Execution|Review]
severity: [Critical|High|Medium|Low]
```

---

### Phase 4: Determine Category File

Categories map to files in `docs/learnings/`:

| Category | Use When | File |
|----------|----------|------|
| `architecture` | Service patterns, state management, data flow | `architecture.md` |
| `testing` | Test patterns, mocking, assertions | `testing.md` |
| `godot` | Godot-specific issues, scenes, signals | `godot.md` |
| `combat` | Combat mechanics, formulas, balance | `combat.md` |
| `ui` | UI components, overlays, input | `ui.md` |
| `data` | JSON data files, loaders, registry | `data.md` |
| `performance` | Optimization, profiling, memory | `performance.md` |
| `workflow` | Process improvements, skill updates | `workflow.md` |

---

### Phase 5: Check Existing Documentation

```bash
# Check for related entries
grep -l "{keywords}" docs/learnings/*.md

# Read target file
cat docs/learnings/{category}.md
```

**Check for:**
- Duplicate entries (don't repeat)
- Related learnings (cross-reference)
- Existing patterns to extend

---

### Phase 6: Generate Entry

**Entry Format:**

```markdown
---

## {YYYY-MM-DD} - {Learning Title}

### Metadata
- **Module:** {module}
- **Component:** {component}
- **Type:** {learning_type}
- **Phase:** {phase_discovered}
- **Severity:** {severity}
- **Feature:** {feature name if applicable}

### Context
{1-2 sentences: What were you doing when this was discovered?}

### The Learning

**What Happened:**
{Observable situation - what you encountered}

**Why It Matters:**
{Impact - what goes wrong without this knowledge}

**The Insight:**
{Core learning - the reusable knowledge}

### Application

**Pattern/Solution:**
```{language}
// Focused code example (5-15 lines max)
```

**When to Apply:**
- {Trigger condition 1}
- {Trigger condition 2}

### Prevention

**In Future Features:**
- [ ] {Checklist item for design phase}
- [ ] {Checklist item for planning phase}
- [ ] {Checklist item for execution phase}

**Bead Context to Include:**
- {Context reference that should be in future beads}

### Cross-References
- Related: `docs/learnings/{related}.md#{section}`
- Pattern: `Src/{path}` - {what to look at}
```

---

### Phase 7: Write Documentation

**If file doesn't exist:**
```markdown
# {Category} Learnings

Compound learnings from {category} features and development.

---

{entry}
```

**If file exists:**
Append entry at bottom, separated by `---`.

---

### Phase 8: Suggest Follow-ups

| Follow-up | When to Suggest |
|-----------|-----------------|
| **Skill update** | Process improvement should change a skill |
| **CLAUDE.md update** | Pattern should be enforced project-wide |
| **Bead template update** | Context gaps should inform bead creation |
| **Documentation update** | Reference docs need additions |
| **Another compound** | Multiple learnings from this review cycle |

```markdown
## Learning Captured ✅

**Entry:** {title}
**File:** docs/learnings/{category}.md
**Type:** {learning_type}

### Suggested Follow-ups
- [ ] {specific follow-up action}

### More to Capture?
If review found other issues worth documenting:
- Run `/compound [next-topic]`
- Or say "done" to continue with review cycle
```

---

## Integration with Feature Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         COMPOUND IN WORKFLOW                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  /brainstorm ──► /plan ──► /beads ──► /execute ──► /review ◄──► /compound  │
│       │            │          │           │            │            │        │
│       ▼            ▼          ▼           ▼            ▼            ▼        │
│   Design       Planning    Beads      Execute      Review      Compound     │
│   learnings    learnings   learnings  learnings    learnings    ◄─────┐     │
│       │            │          │           │            │              │      │
│       └────────────┴──────────┴───────────┴────────────┴──────────────┘      │
│                                                                              │
│   Each phase can produce learnings. Compound captures them immediately.      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Iterative Pattern:**
```
execute bead 1 → execute bead 2 → execute bead 3 → ...
                                         ↓
                                      /review
                                         ↓
                              findings: A, B, C
                                         ↓
                                    fix issue A
                                         ↓
                              /compound "issue A learning"
                                         ↓
                                    fix issue B
                                         ↓
                              /compound "issue B learning"
                                         ↓
                                      /review
                                         ↓
                              findings: D (A,B,C resolved)
                                         ↓
                                       ...
```

---

## Learning Types Deep Dive

### Pattern Discovery
**Trigger:** Found a code pattern worth reusing
**Focus:** How to apply the pattern correctly
**Example:** "Service functions should return Result types for error handling"

### Gotcha/Pitfall
**Trigger:** Hit a non-obvious issue that wasted time
**Focus:** Warning signs and how to avoid
**Example:** "Godot signals disconnect when node is freed - check IsInstanceValid"

### Design Validation
**Trigger:** Design decision proved correct or incorrect during implementation
**Focus:** Evidence for/against the approach
**Example:** "Separating curse flags (cursed vs knownCursed) was correct - simplified shop logic"

### Process Improvement
**Trigger:** Workflow friction discovered
**Focus:** How to improve the process
**Example:** "Beads should include test file path, not just test command"

### Documentation Gap
**Trigger:** Missing or outdated docs caused confusion
**Focus:** What needs documenting
**Example:** "Combat formula doc missing monster group size limits"

### Context Gap
**Trigger:** Bead or plan was missing needed context
**Focus:** What context should have been included
**Example:** "Bead should have referenced ShopService.SellItem pattern for curse checking"

---

## Quality Standards

### Be Specific
- Exact file paths and component names
- Specific error messages or symptoms
- Concrete examples, not abstract descriptions

### Focus on Prevention
- How to avoid this in future features
- What to add to beads/plans
- Checklist items for review

### One Learning Per Call
- Don't batch multiple learnings
- Each entry should be focused
- Call compound multiple times if needed

### Connect to Workflow
- Which phase discovered this?
- What skill/artifact should change?
- How does this improve future features?

---

## Decision Menu

If scope is unclear:

```
What learning would you like to capture?

1. **From Review** - Document a finding from the recent review
2. **Pattern Discovery** - A reusable code pattern you found
3. **Gotcha/Pitfall** - A non-obvious issue to warn about
4. **Design Insight** - A design decision validated/invalidated
5. **Process Improvement** - Workflow friction to address
6. **Describe** - Tell me what you learned
```

---

## Example Entry

```markdown
---

## 2026-01-24 - Curse Awareness State Tracking

### Metadata
- **Module:** Combat
- **Component:** Item, ShopService, EquipmentService
- **Type:** Pattern_Discovery
- **Phase:** Review
- **Severity:** Medium
- **Feature:** Curse Awareness

### Context
During review of the curse awareness feature, discovered that curse state needs tracking at multiple levels (item.Cursed, item.KnownCursed, character awareness).

### The Learning

**What Happened:**
Review found that shop could sell cursed items because it only checked `item.Cursed`, not `item.KnownCursed`. The player knew the item was cursed (had equipped it), but the shop code didn't reflect this.

**Why It Matters:**
State that represents "player knowledge" vs "actual state" requires careful tracking. Missing this creates exploits or confusing UX.

**The Insight:**
When modeling player knowledge, use separate flags (`KnownX`) rather than inferring from behavior. Check both flags at decision points.

### Application

**Pattern/Solution:**
```csharp
// Pattern: Check both actual state AND player knowledge
if (item.Cursed && item.KnownCursed)
{
    // Player knows it's cursed - block sale, show warning
}
else if (item.Cursed && !item.KnownCursed)
{
    // Player doesn't know - allow sale (caveat emptor)
}
```

**When to Apply:**
- Any feature tracking "what player knows" vs "what is true"
- Identification mechanics (items, monsters, traps)
- Fog of war / discovery systems

### Prevention

**In Future Features:**
- [ ] Design: Identify if feature has "known vs actual" state
- [ ] Plan: Create separate flags for each, not derived state
- [ ] Bead: Reference this pattern when touching knowledge flags

**Bead Context to Include:**
- Read: `Src/Models/Item.cs` - KnownCursed pattern
- Pattern: Dual-flag for player knowledge vs actual state

### Cross-References
- Related: `docs/learnings/architecture.md#state-management`
- Pattern: `Src/Models/Item.cs` - Cursed/KnownCursed flags
```

---

## Exit Signals

| Signal | Meaning |
|--------|---------|
| Entry written | Suggest follow-ups, ask if more to compound |
| "done" | Return to review cycle or feature work |
| "another" | Capture another learning from same review cycle |
| "update skill" | Modify a skill based on process learning |
