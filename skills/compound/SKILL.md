---
name: compound
description: >
  Capture learnings from feature development to make future work easier.
  Structured categories map to pipeline phases and domains. When a learning
  relates to a domain reference, compound suggests updating that reference.
  Called after review or at any point during development when insight is fresh.
argument-hint: "[learning-topic] or 'review' to process review findings"
---

# Compound: Feature Learning Capture

**Philosophy:** Large feature development produces valuable learnings at every phase. Capture them while context is fresh to make future features easier. One focused learning per call. When a learning improves a domain reference or shared convention, update the reference directly.

## Core Principles

1. **Phase-aware** — Learnings come from brainstorm, discovery, design, planning, execution, and review
2. **Explicit scope** — Know exactly what we're documenting
3. **Fresh context** — Compound immediately after the insight, not at end of feature
4. **Focused entries** — One learning per compound call, not batched
5. **Prevention-oriented** — How does this make future work easier?
6. **Reference-updating** — Domain learnings can update shared reference files

---

## Trigger Conditions

Run this skill when:
- After review approval (standard end-of-feature)
- During any phase when an important insight surfaces
- User says "capture learning", "compound", "document what we learned"
- After discovering a pattern, gotcha, or best practice

---

## Learning Categories

### Phase-Specific Learnings

| Category | Captures | Example |
|----------|----------|---------|
| `brainstorm` | Problem framing insights, scope classification accuracy | "5 Whys revealed the real problem was X not Y" |
| `discovery` | Domain insights, checklist gaps, workflow patterns | "OpenIddict requires X when configuring Y" |
| `prd` | Requirements patterns, acceptance criteria that worked | "Security criteria on FRs caught issue during review" |
| `design` | Architecture decisions, pattern discoveries | "Cursor pagination was better than offset for this use case" |
| `plan` | Decomposition insights, sizing accuracy | "Sub-plan 03 should have been split — too large for one bead" |
| `execution` | Implementation patterns, codebase gotchas | "EF Core query filter for TenantId must be added to EVERY entity" |
| `review` | Common issues found, review process improvements | "Upstream compliance check caught missing index from design" |
| `testing` | Test patterns, edge cases discovered | "BDD scenario for concurrent secret rotation uncovered race condition" |

### Cross-Phase Learnings

| Category | Captures | Example |
|----------|----------|---------|
| `estimation` | How actual effort compared to estimates | "L complexity components consistently take 2x estimated beads" |
| `traceability` | Where the traceability chain broke | "FR-005 had no corresponding BDD scenario — caught in review" |
| `tooling` | br CLI, agent patterns, workflow improvements | "Using --tag on beads made filtering by FR much easier" |
| `process` | Pipeline improvements, phase ordering | "Discovery should always run for features touching 3+ systems" |

### Domain-Specific Learnings

| Category | Captures | Reference File |
|----------|----------|---------------|
| `domain:identity` | OpenIddict gotchas, auth flow nuances | `_shared/references/identity-auth.md` |
| `domain:capstone-data` | Data model patterns, MCP interactions | `_shared/references/capstone-data.md` |
| `domain:guardian` | Mobile/offline patterns, sync edge cases | `_shared/references/guardian-mobile.md` |
| `domain:saas` | Multi-tenancy patterns, admin patterns | `_shared/references/general-saas.md` |

---

## Execution

### Step 1: Identify the Learning

Ask: **"What did you learn? Which phase or category does this relate to?"**

If processing review findings, read the review output and extract learnings.

### Step 2: Classify

Determine:
- **Category** from the tables above
- **Phase** where the learning originated
- **Feature** it was discovered during
- **Domain reference** (if applicable)

### Step 3: Document

**Learning Format:**

```markdown
## {Learning Title}

**Category:** {category from tables}
**Phase:** {brainstorm | discovery | prd | design | plan | execution | review | testing}
**Feature:** {feature name}
**Date:** {today}

### Context
{What were we doing when we discovered this?}

### Learning
{What did we learn? Be specific and actionable.}

### Prevention
{How does this make future work easier? What should we do differently?}

### Impact
{What would have happened if we hadn't learned this?}
```

### Step 4: Save

Append to: `${PROJECT_ROOT}/docs/learnings/{category}.md`

If the file doesn't exist, create it with a header:

```markdown
# Learnings: {Category}

Accumulated learnings from feature development.
Referenced by brainstorm (Phase 2) and discovery (Phase 2).
```

### Step 5: Update Domain Reference (if applicable)

If the learning relates to a domain reference file:

```
"This learning about {topic} should update the {domain} reference file.

Suggested addition to _shared/references/{domain}.md:

  ## {Section}
  - {New pattern, gotcha, or best practice}

Update the reference? [yes / no]"
```

If user approves, update the reference file directly. This ensures future features benefit from the learning during discovery and design phases.

### Step 6: Update ASCII Conventions (if applicable)

If the learning relates to diagram conventions:

```
"This learning about {diagram type} should update ascii-conventions.md.

Suggested addition:
  {New convention or clarification}

Update conventions? [yes / no]"
```

---

## Bulk Processing (Review Findings)

When called with "review" argument, process the review output:

```bash
# Read the most recent review summary
ls "${PROJECT_ROOT}/docs/reviews/" 2>/dev/null | sort | tail -1
# Read that file's executive summary (first 50 lines)
```

If no review file exists in `docs/reviews/`, ask the user to describe the review findings or run /review first.

For each finding category, extract potential learnings:
- **correctness** findings → `execution` learnings
- **security** findings → `domain:{relevant}` learnings
- **performance** findings → `design` or `execution` learnings
- **upstream-compliance** findings → `traceability` or `process` learnings
- **patterns** findings → `execution` learnings

Present extracted learnings to user for confirmation before saving.

---

## Exit Signals

| Signal | Meaning |
|--------|--------|
| "done" | Learning captured |
| "more" | Capture another learning |
| "update reference" | Update a domain reference file |

---

## Quality Standards

- **Specific, not vague** — "EF Core requires X when Y" not "watch out for EF Core issues"
- **Actionable** — Prevention section tells you what to DO differently
- **Categorised** — Correct category enables future discovery by brainstorm and discovery skills
- **Domain-connected** — If it's a domain insight, it updates the reference file

---

*Skill Version: 2.0*
*Added in v2: Structured categories by phase/domain, domain reference updates, review file integration*
