# Sub-Plan: docs:adr SKILL.md

> Part of [Documentation Skills Plan](overview.md)

## Objective

Create the `adr/SKILL.md` — the skill for recording architectural decisions using MADR templates. This skill has the most structured workflow of the three: determine next number → select variant → gather context → generate ADR → validate → write.

## Context

Depends on [02-reference-files](02-reference-files.md) for the 3 MADR template variants in `adr/references/adr/`. Can be implemented in parallel with docs:audit and docs:write. ADRs have a distinct lifecycle (Proposed → Accepted → Deprecated → Superseded) that requires careful status management.

## Tasks

### Task 1: Write Frontmatter

**Objective:** Define YAML frontmatter that triggers for architectural decision recording.

**Approach:**
Use the frontmatter draft from the design. Description must convey MADR format, lifecycle support, and template variants.

**Pseudocode:**
```
frontmatter:
  name: docs-adr
  description: (from design Frontmatter Drafts section)
    - Include: MADR, architectural decisions, decision records
    - Include: lifecycle (Proposed, Accepted, Deprecated)
    - Include: template variants (full, minimal, bare)
    - Include trigger phrases: "record decision", "create ADR", "why we chose"
  argument-hint: "[decision title] e.g. 'use PostgreSQL for persistence'"
```

**Pattern Reference:**
- Design: Frontmatter Drafts section

**Success Criteria:**
- Triggers on decision-related phrases ("record decision", "create ADR", "why we chose")
- Does NOT trigger on general doc writing or audit requests
- argument-hint shows decision title pattern

**Failure Criteria:**
- ❌ Description overlaps with docs:write triggers (e.g., "document" is ambiguous)
- ❌ Missing MADR or lifecycle mention in description

**Verification:**
- Test: Mentally walk through trigger phrases — "record this decision" triggers? "write a tutorial" does NOT?
- Manual: Compare description against docs:write to confirm no overlap on "document" keyword

---

### Task 2: Write Numbering and Template Selection (Phases 0-2)

**Objective:** Define the prerequisite and selection phases.

**Approach:**
Phase 0 resolves project root and ensures `docs/adr/` exists. Phase 1 determines the next sequential ADR number. Phase 2 selects the appropriate MADR variant based on decision complexity.

**Pseudocode:**
```
Phase 0: Prerequisites
  Resolve PROJECT_ROOT
  Ensure docs/adr/ exists
  List existing ADRs to find highest number

Phase 1: Determine next ADR number
  SCAN docs/adr/ for pattern NNNN-*.md
  NEXT_NUMBER = highest found + 1
  IF no existing ADRs: NEXT_NUMBER = 0001
  CHECK for collision (file already exists)

Phase 2: Select template variant
  IF complex decision (many options, significant consequences)
    → LOAD references/adr/madr-full.md
  IF standard decision (clear options, moderate impact)
    → LOAD references/adr/madr-minimal.md
  IF quick capture (decision already made, just recording)
    → LOAD references/adr/madr-bare.md
  IF uncertain
    → DEFAULT to minimal, suggest full if needed
```

**Pattern Reference:**
- MADR 4.0.0 numbering: https://adr.github.io/madr/
- Conditional workflow: skill-creator `references/workflows.md`

**Success Criteria:**
- Sequential numbering with zero-padded 4-digit format (0001, 0002, ...)
- Collision detection prevents duplicate numbers
- Template selection has clear criteria and sensible default (minimal)

**Failure Criteria:**
- ❌ Gaps in numbering sequence
- ❌ Loading all 3 variants when only 1 is needed

**Verification:**
- Test: Walk through numbering with existing ADRs 0001-0003 — does it produce 0004?
- Test: Walk through numbering with empty docs/adr/ — does it produce 0001?
- Manual: Confirm only one MADR variant is loaded per invocation

---

### Task 3: Write Context Gathering and Generation (Phases 3-6)

**Objective:** Define the phases from decision context gathering through file creation.

**Approach:**
Phase 3 gathers the decision context (drivers, options, consequences). Phase 4 generates the ADR content using the selected template. Phase 5 validates format. Phase 6 writes the file.

**Pseudocode:**
```
Phase 3: Gather context
  - What decision was made (or needs to be made)?
  - What problem does it solve?
  - Decision drivers (requirements, constraints)
  - Options considered with pros/cons
  - Consequences (positive and negative)
  - Related ADRs or prior decisions

Phase 4: Generate ADR
  FILENAME = {NNNN}-{kebab-case-title}.md
  FILL selected template with gathered context
  SET status (default: Proposed, or Accepted if already decided)

Phase 5: Validate
  - Status field present and valid
  - Decision drivers documented
  - At least 2 options considered (for full/minimal)
  - Related ADRs linked if applicable
  - Filename matches NNNN-kebab-case pattern

Phase 6: Write file
  WRITE to docs/adr/{filename}
  CONFIRM creation with file path and summary
```

**Pattern Reference:**
- ADR anti-pattern: Design's "ADRs without context" anti-pattern
- Status lifecycle: Proposed → Accepted → Deprecated → Superseded

**Success Criteria:**
- Generated ADRs include decision drivers and considered options
- Status defaults are sensible (Proposed for new, Accepted for retrospective)
- Filename follows MADR convention exactly

**Failure Criteria:**
- ❌ ADR created without decision drivers or considered options
- ❌ Status field missing or set to invalid value

**Verification:**
- Test: Walk through ADR generation for "use PostgreSQL" — does the output include drivers, options, consequences?
- Manual: Confirm filename format matches `NNNN-kebab-case-title.md` pattern

---

### Task 4: Write Quality Standards, Anti-Patterns, Exit Signals

**Objective:** Standard skill sections for consistent ADR behavior.

**Approach:**
Anti-patterns from design: ADRs without context, missing status. Exit signals: "adr created", "refine", "abort". Include status update workflow for existing ADRs.

**Pseudocode:**
```
Quality Standards:
  - Sequential number assigned (no gaps, no collisions)
  - Status lifecycle followed
  - Decision drivers documented
  - Options considered with pros/cons
  - Consequences noted (positive and negative)
  - Related ADRs linked

Anti-Patterns:
  ❌ ADR without context → ✅ Full decision context
  ❌ Missing status → ✅ Status lifecycle
  ❌ No options considered → ✅ At least 2 options

Exit Signals:
  "adr created" → Decision recorded
  "refine" → Continue iterating
  "abort" → Cancel
  Negative: "write docs" → redirect to docs:write
  Negative: "audit docs" → redirect to docs:audit
```

**Pattern Reference:**
- Anti-Patterns: Design's ADR Anti-Patterns section
- Exit Signals: Design's Exit Signals section

**Success Criteria:**
- Anti-patterns warn against context-free ADRs
- Exit signals clearly indicate ADR completion
- Negative triggers redirect to docs:write and docs:audit

**Failure Criteria:**
- ❌ Missing the "ADR without context" anti-pattern (most critical one)
- ❌ Missing negative trigger redirects

**Verification:**
- Manual: Compare anti-patterns against design's ADR-specific anti-patterns
- Manual: Confirm exit signals match design's Exit Signals table

## Component Success Criteria

- SKILL.md is under 400 lines (target ~200-300, most focused skill)
- Sequential numbering is reliable (no gaps, no collisions)
- Only one MADR variant loaded per invocation
- Status lifecycle is clearly documented
- Follows established skill patterns

## References

- Docs: [docs:adr Workflow](../../designs/documentation-skills/design.md#docsadr-workflow), [ADR Anti-Patterns](../../designs/documentation-skills/design.md#anti-patterns)
- Patterns: `skills/brainstorm/SKILL.md` (phases, exit signals), MADR 4.0.0 (https://adr.github.io/madr/)
