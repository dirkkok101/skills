# Sub-Plan: Reference Files

> Part of [Documentation Skills Plan](overview.md)

## Objective

Create all 18 reference templates across the 3 skills. These are markdown files loaded into context on demand by Claude to inform content generation. They are the knowledge foundation for the entire plugin.

## Context

Depends on [01-plugin-scaffold](01-plugin-scaffold.md) for the directory structure. All three skill SKILL.md files depend on these reference files existing. Reference files follow progressive disclosure — Claude loads only the relevant file per invocation.

## Tasks

### Task 1: docs:audit Reference (1 file)

**Objective:** Create `audit/references/quality-criteria.md` — evaluation criteria for AI files and documentation quality.

**Approach:**
Define what "good" looks like for CLAUDE.md, AGENTS.md, llms.txt, and general documentation. Include concrete evaluation criteria with scoring dimensions.

**Pseudocode:**
```
quality-criteria.md sections:
  CLAUDE.md quality:
    - Required: project overview, conventions, build commands
    - Anti-patterns: vague instructions, outdated commands
  AGENTS.md quality:
    - Required: spec compliance, cross-platform markers
    - Anti-patterns: missing tool permissions, no context sections
  llms.txt quality:
    - Required: structured index, token-efficient format
    - Anti-patterns: raw HTML dumps, unstructured content
  General doc quality:
    - Heading hierarchy, link validity, freshness indicators
```

**Pattern Reference:**
- AGENTS.md standard: https://agents.md/
- llms.txt spec: https://llmstxt.org/

**Success Criteria:**
- Criteria are specific enough to drive consistent audits
- Covers all 3 AI file types plus general quality

**Failure Criteria:**
- ❌ Criteria too vague to produce consistent audit results
- ❌ Missing evaluation dimensions for any AI file type

**Verification:**
- Manual: Apply criteria to an existing project and confirm audit produces actionable results
- Manual: Verify each AI file type has specific required/anti-pattern sections

---

### Task 2: docs:write Diataxis References (4 files)

**Objective:** Create `write/references/diataxis/{tutorial,howto,reference,explanation}.md`

**Approach:**
Each file is a template + guidance for one Diataxis documentation type. Include the template structure, key characteristics, common mistakes, and a brief example.

**Pseudocode:**
```
FOR EACH diataxis type:
  - Type definition (1-2 sentences from Diataxis)
  - Key characteristics (what makes this type distinct)
  - Template structure (section headings with guidance)
  - Anti-patterns for this type
  - Brief example showing correct application
```

**Pattern Reference:**
- Diataxis framework: https://diataxis.fr/

**Success Criteria:**
- Each file captures the essential Diataxis guidance for its type
- Templates are practical (not academic)

**Failure Criteria:**
- ❌ Types blur together (e.g., tutorial reads like a how-to)
- ❌ Template sections too abstract to fill without additional research

**Verification:**
- Manual: Read each file and confirm it clearly distinguishes its type from the other three
- Manual: Attempt to fill each template for a sample subject — sections should be fillable

---

### Task 3: docs:write AI-Files References (3 files)

**Objective:** Create `write/references/ai-files/{claude-md,agents-md,llms-txt}.md`

**Approach:**
Each file provides a template and guidance for generating the respective AI optimization file. Include required sections, optional sections, and examples of good content.

**Pseudocode:**
```
claude-md.md: Project instructions for Claude
  - Sections: overview, conventions, build commands, patterns
agents-md.md: Cross-platform agent instructions
  - Sections: per AGENTS.md spec, tool permissions, context
llms-txt.md: LLM context optimization index
  - Sections: per llms.txt spec, structured index format
```

**Pattern Reference:**
- AGENTS.md: https://agents.md/
- llms.txt: https://llmstxt.org/
- CLAUDE.md: existing patterns in projects

**Success Criteria:**
- Templates follow their respective specifications
- Guidance is actionable, not just spec-quoting

**Failure Criteria:**
- ❌ Template deviates from the official spec
- ❌ Guidance is a spec restatement without practical application

**Verification:**
- Manual: Compare each template against its source spec for compliance
- Manual: Confirm guidance adds practical value beyond the spec itself

---

### Task 4: docs:write Architecture References (4 files)

**Objective:** Create `write/references/architecture/{c4-context,c4-container,system-overview,diagram-mermaid}.md`

**Approach:**
Templates for architecture documentation. C4 files cover context and container diagrams. System overview follows arc42-inspired structure. Mermaid file covers diagram conventions.

**Pseudocode:**
```
c4-context.md: System context diagram guide
  - Actors, external systems, relationships
  - Mermaid template for context diagram
c4-container.md: Container diagram guide
  - Services, databases, connections
  - Mermaid template for container diagram
system-overview.md: Arc42-inspired overview
  - Context, constraints, building blocks, runtime
diagram-mermaid.md: Mermaid conventions
  - Diagram types (flowchart, sequence, class, state)
  - Styling conventions, copy-paste examples
```

**Pattern Reference:**
- C4 model: https://c4model.com/
- arc42: https://arc42.org/

**Success Criteria:**
- Templates produce useful architecture docs (not just empty sections)
- Mermaid examples are copy-paste ready

**Failure Criteria:**
- ❌ C4 templates missing key elements (actors, boundaries, relationships)
- ❌ Mermaid examples don't render correctly

**Verification:**
- Manual: Render Mermaid examples to confirm they produce valid diagrams
- Manual: Fill C4 templates for a sample system and verify completeness

---

### Task 5: docs:write Project References (3 files)

**Objective:** Create `write/references/project/{readme,contributing,glossary}.md`

**Approach:**
Standard project documentation templates. README covers the standard sections. CONTRIBUTING covers PR process, coding standards. Glossary provides domain term capture format.

**Pseudocode:**
```
readme.md: README template
  - Overview, installation, usage, contributing link, license
contributing.md: CONTRIBUTING template
  - Setup, coding standards, PR process, review checklist
glossary.md: Domain glossary template
  - Table format: term, definition, context, aliases
```

**Pattern Reference:**
- Open-source conventions: GitHub's community standards documentation
- README best practices: common patterns across popular repositories

**Success Criteria:**
- Templates match common open-source conventions
- Each template is practical and fills a real need

**Failure Criteria:**
- ❌ README template missing standard sections (install, usage, license)
- ❌ Glossary format too rigid for varied domain terminology

**Verification:**
- Manual: Compare README template against GitHub's recommended community files
- Manual: Fill glossary template with 3-5 sample terms to test format flexibility

---

### Task 6: docs:adr References (3 files)

**Objective:** Create `adr/references/adr/{madr-full,madr-minimal,madr-bare}.md`

**Approach:**
Three MADR 4.0.0 template variants at different detail levels. Full has all sections with explanatory text. Minimal has required sections only. Bare has section headings without explanations.

**Pseudocode:**
```
madr-full.md: All MADR sections with explanatory guidance
  - Title, Status, Context, Decision Drivers, Considered Options
  - Decision Outcome, Pros/Cons per option, Links
madr-minimal.md: Required sections only
  - Title, Status, Context, Decision, Consequences
madr-bare.md: Section headings without explanations
  - Same as minimal but headings only, no guidance text
ALL variants: Include status lifecycle (Proposed, Accepted, Deprecated, Superseded)
```

**Pattern Reference:**
- MADR 4.0.0: https://adr.github.io/madr/

**Success Criteria:**
- Templates match MADR 4.0.0 specification
- Three variants provide meaningful differentiation
- Status lifecycle included (Proposed, Accepted, Deprecated, Superseded)

**Failure Criteria:**
- ❌ Variants are too similar (no meaningful differentiation)
- ❌ Full template missing MADR sections (e.g., Decision Drivers, Consequences)

**Verification:**
- Manual: Compare full template against MADR 4.0.0 spec section-by-section
- Manual: Confirm bare variant is genuinely minimal (just headings, no filler)

## Component Success Criteria

- All 18 reference files created (1 + 4 + 3 + 4 + 3 + 3)
- Each file is well-structured markdown with clear sections
- Files are practical templates, not academic descriptions
- Total size reasonable (each file ~50-150 lines)

## References

- Docs: [Reference File Structure](../../designs/documentation-skills/design.md#reference-file-structure)
- Patterns: Diataxis (https://diataxis.fr/), MADR (https://adr.github.io/madr/), AGENTS.md (https://agents.md/), llms.txt (https://llmstxt.org/), C4 (https://c4model.com/)
