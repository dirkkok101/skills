# Sub-Plan: docs:write SKILL.md

> Part of [Documentation Skills Plan](overview.md)

## Objective

Create the `write/SKILL.md` — the primary documentation generation skill. This is the most complex of the three skills because it routes to 14 different reference templates across 4 categories and supports idempotent updates with managed sections.

## Context

Depends on [02-reference-files](02-reference-files.md) for all 14 reference templates under `write/references/`. Can be implemented in parallel with docs:audit and docs:adr. The template routing logic is the critical design challenge — SKILL.md must guide Claude to select the right reference file based on user intent.

## Tasks

### Task 1: Write Frontmatter

**Objective:** Define YAML frontmatter that triggers for any documentation creation/update request.

**Approach:**
Use the frontmatter draft from the design. Description must cover all 4 reference categories (diataxis, ai-files, architecture, project) and include idempotent update mention.

**Pseudocode:**
```
frontmatter:
  name: docs-write
  description: (from design Frontmatter Drafts section)
    - Include: all doc types (tutorial, howto, reference, explanation)
    - Include: AI files (CLAUDE.md, AGENTS.md, llms.txt)
    - Include: architecture, project files (README, CONTRIBUTING)
    - Include: idempotent updates, template-driven
    - Include trigger phrases: "write docs for", "create tutorial", "generate README"
  argument-hint: "[doc-type] [subject] e.g. 'howto authentication' or 'AGENTS.md'"
```

**Pattern Reference:**
- Design: Frontmatter Drafts section

**Success Criteria:**
- Triggers on doc creation phrases ("write docs for", "create tutorial", "generate README")
- Does NOT trigger on audit or ADR requests
- argument-hint shows doc-type + subject pattern

**Failure Criteria:**
- ❌ Description too broad (triggers on audit or ADR requests)
- ❌ Description too narrow (misses architecture or project doc requests)

**Verification:**
- Test: Mentally walk through trigger phrases — "create a tutorial" triggers? "audit my docs" does NOT?
- Manual: Compare description against docs:audit and docs:adr to confirm no overlap

---

### Task 2: Write Prerequisites (Phase 0)

**Objective:** Define the prerequisites check that runs before template routing.

**Approach:**
Phase 0 resolves project root, ensures `docs/` folder exists, and checks for existing documentation to inform style conventions.

**Pseudocode:**
```
Phase 0: Prerequisites
  Resolve PROJECT_ROOT via git rev-parse
  Ensure docs/ folder exists (create if needed)
  Check if target doc already exists (update vs create)
  Note existing folder conventions (docs/tutorials/ vs docs/guides/ etc.)
```

**Pattern Reference:**
- Prerequisites pattern: `skills/diagnose/SKILL.md` (Phase 0)
- Design: docs:write Phase 0 Prerequisites Check

**Success Criteria:**
- PROJECT_ROOT always resolved before any file operations
- Existing doc conventions detected and respected
- Clearly distinguishes new file vs update scenario

**Failure Criteria:**
- ❌ Writing files without resolving PROJECT_ROOT first
- ❌ Ignoring existing folder conventions when creating new docs

**Verification:**
- Test: Walk through Phase 0 for a project with existing docs/ — does it detect conventions?
- Test: Walk through Phase 0 for a project without docs/ — does it create the folder?

---

### Task 3: Write Template Router (Phase 1)

**Objective:** Define the routing logic that maps user intent to the correct reference template.

**Approach:**
Create a classification table mapping keywords/phrases to reference file paths. Use conditional workflow pattern: detect type → select category → load specific reference.

**Pseudocode:**
```
DETECT doc type from user request:
  IF mentions "tutorial", "learn", "getting started"
    → LOAD references/diataxis/tutorial.md
  IF mentions "how to", "guide", "steps"
    → LOAD references/diataxis/howto.md
  IF mentions "API", "reference", "specification"
    → LOAD references/diataxis/reference.md
  IF mentions "why", "concept", "explanation"
    → LOAD references/diataxis/explanation.md
  IF mentions "CLAUDE.md"
    → LOAD references/ai-files/claude-md.md
  IF mentions "AGENTS.md"
    → LOAD references/ai-files/agents-md.md
  IF mentions "llms.txt"
    → LOAD references/ai-files/llms-txt.md
  IF mentions "C4", "context diagram", "container diagram"
    → LOAD references/architecture/{appropriate}.md
  IF mentions "system overview", "architecture"
    → LOAD references/architecture/system-overview.md
  IF mentions "README"
    → LOAD references/project/readme.md
  IF mentions "CONTRIBUTING"
    → LOAD references/project/contributing.md
  IF mentions "glossary", "terminology"
    → LOAD references/project/glossary.md
  IF mentions "ADR", "decision"
    → REDIRECT to docs:adr
  IF ambiguous
    → ASK user to clarify doc type
```

**Pattern Reference:**
- Conditional workflow: skill-creator `references/workflows.md`
- Progressive disclosure: load only the selected reference file

**Success Criteria:**
- Every reference file has a clear routing path
- Ambiguous requests prompt clarification instead of guessing
- ADR requests redirect to docs:adr

**Failure Criteria:**
- ❌ Loading multiple reference files when only one is needed
- ❌ Guessing type when request is ambiguous
- ❌ Missing routing path for any of the 14 reference files

**Verification:**
- Test: For each of the 14 reference files, identify at least one phrase that routes to it
- Manual: Confirm "ADR" and "decision" redirect to docs:adr, not handled locally

---

### Task 4: Write Content Generation Workflow (Phases 2-6)

**Objective:** Define the phases from context gathering through writing/updating.

**Approach:**
After template routing (Phase 1), phases cover: gather project context → generate content with template → validate structure → write/update file with managed sections.

**Pseudocode:**
```
Phase 2: Load selected reference template
Phase 3: Gather project context
  - Read existing docs for style conventions
  - Extract relevant code context for the subject
  - Check glossary for terminology if exists
Phase 4: Generate content
  - Fill template sections with project-specific content
  - Add examples from codebase
  - Include cross-references to related docs
Phase 5: Validate
  - Heading hierarchy correct (single H1)
  - Links resolve
  - Code examples are valid
Phase 6: Write/Update
  IF new file: Write with full template
  IF existing file: Idempotent update
    - Identify managed sections (<!-- BEGIN/END MANAGED SECTION -->)
    - Update managed content only
    - Preserve all custom sections
```

**Pattern Reference:**
- Idempotent updates: Design's Anti-Patterns section (managed section markers)
- Phase structure: `skills/brainstorm/SKILL.md`

**Success Criteria:**
- Idempotent update logic clearly defined with managed section markers
- Custom content preservation is explicit
- Validation catches common markdown issues

**Failure Criteria:**
- ❌ Update overwrites custom sections outside managed markers
- ❌ Generated content missing cross-references to related docs

**Verification:**
- Test: Walk through update scenario — existing file with custom sections should preserve them
- Manual: Confirm managed section markers match design's anti-pattern examples exactly

---

### Task 5: Write Quality Standards, Anti-Patterns, Exit Signals

**Objective:** Standard skill sections ensuring consistent behavior.

**Approach:**
Include anti-patterns from the design (ignoring existing structure, overwriting custom content). Exit signals: "docs committed", "refine", "abort".

**Pseudocode:**
```
Quality Standards:
  - Template matches documentation type
  - Project context gathered (existing style, glossary)
  - Cross-references validated
  - Custom sections preserved (if updating)
  - Heading hierarchy follows CommonMark (single H1)

Anti-Patterns:
  ❌ Ignoring existing doc structure → ✅ Follow conventions
  ❌ Overwriting custom content → ✅ Idempotent managed sections
  ❌ Skipping AI-friendliness → ✅ Include AI optimization

Exit Signals:
  "docs committed" → File written
  "refine" → Continue iterating
  "abort" → Cancel
  Negative: "audit docs" → redirect to docs:audit
  Negative: "record decision" → redirect to docs:adr
```

**Pattern Reference:**
- Anti-Patterns: Design's Anti-Patterns section
- Exit Signals: Design's Exit Signals section

**Success Criteria:**
- Anti-patterns warn against overwriting custom content
- Anti-patterns warn against ignoring existing doc conventions
- Exit signals include path to docs:adr when decision recording needed

**Failure Criteria:**
- ❌ Missing idempotent update anti-pattern (core differentiator)
- ❌ Missing negative trigger redirects

**Verification:**
- Manual: Compare anti-patterns against design's Anti-Patterns section for full coverage
- Manual: Confirm exit signals match design's Exit Signals table

## Component Success Criteria

- SKILL.md is under 400 lines (target ~300-400, most complex skill)
- Template routing covers all 14 reference files
- Idempotent update logic clearly documented
- Only one reference file loaded per invocation
- Follows established skill patterns

## References

- Docs: [docs:write Workflow](../../designs/documentation-skills/design.md#docswrite-workflow), [Anti-Patterns](../../designs/documentation-skills/design.md#anti-patterns)
- Patterns: skill-creator `references/workflows.md` (conditional workflows), `skills/brainstorm/SKILL.md` (phases)
