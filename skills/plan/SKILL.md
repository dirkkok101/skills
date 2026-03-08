---
name: plan
description: >
  Transform validated designs into hierarchical implementation plans with
  traceability to requirements and test cases. Plans contain intent,
  pseudocode, and diagrams — never source code. Each sub-plan references
  the FRs it implements and the BDD scenarios that verify it. Requires
  design approval.
argument-hint: "[feature-name] or path to design doc"
---

# Plan: Design → Documentation-First Implementation Plan

**Philosophy:** Plans are permanent documentation, not throwaway artifacts. They explain WHAT to build and WHY, not HOW to write the code. Agents are trusted to implement from intent by reading codebase patterns. Each sub-plan traces back to requirements and forward to tests.

## Core Principles

1. **No source code** — Plans contain intent, pseudocode, diagrams
2. **Hierarchical structure** — Overview for high-level review, sub-plans for focused detail
3. **Traceable** — Every sub-plan references FRs it implements and BDD scenarios that verify it
4. **Permanent documentation** — Plans explain rationale for future developers
5. **Agent context management** — Sub-plans loadable independently by executing agents

---

## Trigger Conditions

Run this skill when:
- Design has been approved
- User says "write the plan", "plan this", "create plan for..."
- A design document exists at `${PROJECT_ROOT}/docs/designs/{feature}/`

## Prerequisites

**Step 0: Resolve Project Root:**

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
ls "${PROJECT_ROOT}/docs/"
```

**Verify before starting:**
- [ ] PROJECT_ROOT resolved correctly

**Determine plan mode:**

| Mode | Input Required | When |
|------|---------------|------|
| **BRIEF** | Brainstorm only (no design doc) | BRIEF scope — simple changes |
| **STANDARD** | Design document | STANDARD/COMPREHENSIVE scope |

**BRIEF mode:** If brainstorm scope = BRIEF and no design doc exists, plan decomposes directly from the brainstorm output and PRD brief. Skip the work decomposition import from technical-design.

```bash
# STANDARD mode: Design document exists
ls "${PROJECT_ROOT}/docs/designs/{feature}/" 2>/dev/null && echo "STANDARD mode"

# BRIEF mode: No design doc, work from brainstorm + PRD
ls "${PROJECT_ROOT}/docs/brainstorm/{feature}/brainstorm.md" 2>/dev/null && echo "BRIEF mode"
```

**Import upstream artifacts:**

```bash
# Design docs (primary input)
ls "${PROJECT_ROOT}/docs/designs/{feature}/"

# PRD for requirement traceability
cat "${PROJECT_ROOT}/docs/prd/{feature}/prd.md" 2>/dev/null

# Work decomposition from design Phase 11
grep -A 50 "Work Decomposition" "${PROJECT_ROOT}/docs/designs/{feature}/design.md" 2>/dev/null
```

---

## Critical Sequence

### Phase 1: Decomposition

**Step 1.1 — Import Work Decomposition:**

**STANDARD mode:** If the technical design includes a Work Decomposition section (Phase 11), import it as the starting point. Don't redo this work.

**BRIEF mode:** No design doc exists. Decompose directly from brainstorm boundaries and PRD brief:
- Each Must-Have requirement becomes a component
- Group related requirements into logical components
- Estimate complexity from the brainstorm's complexity budget
- Create a simple dependency order (data → logic → API → UI)

If no decomposition exists (STANDARD mode without Phase 11), create one from the design docs:

```markdown
| Component | Scope | Complexity | Risk | Implements FRs |
|-----------|-------|------------|------|---------------|
| {component} | {what's in scope} | S/M/L/XL | Low/Med/High | FR-{NNN}, FR-{NNN} |
```

**Step 1.2 — Map FRs to Components:**

Every FR from the PRD must appear in at least one component. Verify:

```markdown
### FR Coverage
| FR | Component | Status |
|----|-----------|--------|
| FR-{MODULE}-{NAME} | Data Model, Commands | ✅ Covered |
| FR-{MODULE}-{NAME} | Commands, API | ✅ Covered |
| FR-{MODULE}-{NAME} | UI | ✅ Covered |
| FR-{MODULE}-{NAME} | — | ⚠ Not covered (deferred?) |
```

Flag any uncovered Must-Have FRs as blocking issues.

**Step 1.3 — Dependency Ordering:**

Create dependency graph from design's suggested execution order:

```
Data Model ──> Commands ──> API ──> UI
    |              |
    +──> Queries ──+
    |
    +──> Integration
```

---

### Phase 2: Overview Document

Create `${PROJECT_ROOT}/docs/plans/{feature}/overview.md`:

```markdown
# Implementation Plan: {Feature Name}

> Plan for implementing {feature} based on the approved technical design.

## Design Reference
- Design: `docs/designs/{feature}/design.md`
- PRD: `docs/prd/{feature}/prd.md`
- Discovery: `docs/discovery/{feature}/discovery-brief.md`

## Component Breakdown
{Table from Phase 1.1}

## FR Coverage
{Table from Phase 1.2}

## Execution Order
{Dependency graph from Phase 1.3}

## Sub-Plans
| # | Component | File | Complexity | Depends On |
|---|-----------|------|------------|-----------|
| 01 | Data Model | 01-data-model.md | M | — |
| 02 | Commands | 02-commands.md | L | 01 |
| 03 | Queries | 03-queries.md | S | 01 |
| 04 | API | 04-api.md | M | 02, 03 |
| 05 | UI | 05-ui.md | L | 04 |
| 06 | Integration | 06-integration.md | M | 01 |

## Testing Summary
| Sub-Plan | BDD Scenarios | Unit Tests | Integration Tests |
|----------|--------------|------------|------------------|
| 01-data-model | — | Entity validation | Migration up/down |
| 02-commands | @UC-{MODULE}-001 | Handler logic | — |
| 04-api | @smoke | — | Contract tests |
| 05-ui | @e2e | — | — |

---
*Plan created: {date}*
*Based on approved design: {date}*
```

---

### Phase 3: Sub-Plan Documents

For each component, create `NN-{component}.md`:

```markdown
# Sub-Plan: {Component Name}

## Traceability
- **Implements:** FR-{MODULE}-{NAME}, FR-{MODULE}-{NAME}, FR-{MODULE}-{NAME}
- **Use Cases:** UC-{MODULE}-001, UC-{MODULE}-002
- **Design Reference:** docs/designs/{feature}/{relevant-file}.md
- **Validates Against:** BDD scenarios tagged @UC-{MODULE}-001

## Prerequisites
- [ ] {Previous sub-plan} completed
- [ ] {Required infrastructure in place}

## Intent

### What to Build
{High-level description of what this component does and why.
 Reference the design doc for detailed specs.}

### Key Design Decisions
{Summarise relevant decisions from the design's Alternatives section.
 "We chose X over Y because Z — see design.md for full analysis."}

### Patterns to Follow
{Which existing codebase patterns to follow.
 "Follow the pattern established in {ExistingService} for CQRS handlers."}

## Context to Load
{Specific files the executing agent should read:}
- `docs/designs/{feature}/data-model.md` — entity definitions
- `src/{project}/{folder}/` — existing patterns to follow
- `docs/designs/{feature}/api-spec.md` — endpoint specs

## Steps (Intent, Not Code)

### Step 1: {What, Not How}
{Describe the objective and constraints.
 Reference specific sections of the design doc.
 Include pseudocode if logic is complex.}

Pseudocode (if complex):
```
FOR each entity in design.data-model
  Create entity class following BaseEntity pattern
  Add EF configuration with indexes from design
  Create migration
```

### Step 2: {What, Not How}
...

## Verification

### Automated
- [ ] BDD scenarios tagged @UC-{MODULE}-001 pass
- [ ] Unit tests for {key logic} pass
- [ ] Migration runs up and down cleanly

### Manual
- [ ] {Specific check that can't be automated}

## Acceptance Criteria (from PRD)
{Copy the relevant Given/When/Then criteria from the PRD's FR definitions.
 These are what the executing agent must satisfy.}
```

---

### Phase 4: Self-Review

**2 rounds, 4 themes:**

**Theme 1: Completeness**
- [ ] Every Must-Have FR covered by at least one sub-plan?
- [ ] Every sub-plan has context references?
- [ ] Dependencies between sub-plans are clear?

**Theme 2: Independence**
- [ ] Each sub-plan independently loadable by an agent?
- [ ] No circular dependencies?
- [ ] Context references point to actual files?

**Theme 3: Traceability**
- [ ] Every sub-plan lists FRs it implements?
- [ ] Every sub-plan references BDD scenarios for verification?
- [ ] FR coverage table has no gaps for Must-Haves?

**Theme 4: Clarity**
- [ ] Intent is clear without being implementation-specific?
- [ ] Key design decisions summarised (not duplicated)?
- [ ] Steps are at the right level (not too vague, not code)?

---

## Exit Signals

| Signal | Meaning |
|--------|--------|
| "plan approved" | Proceed to /beads |
| "refine" | Continue iterating |
| "park" / "abandon" | Save or cancel |

---

## Output Structure

```
${PROJECT_ROOT}/docs/plans/{feature}/
├── overview.md
├── 01-data-model.md
├── 02-commands.md
├── 03-queries.md
├── 04-api.md
├── 05-ui.md
└── 06-integration.md
```

---

*Skill Version: 2.0*
*Added in v2: BRIEF mode (works without design doc), FR traceability, BDD scenario references*
