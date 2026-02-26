# Design: Documentation Skills Suite

> Validated design for a suite of documentation skills to help document existing codebases, domain features, and review/improve existing documentation. This document serves as permanent project documentation.

## Problem Statement

### Surface Request
"I would like us to design documentation skills to help us document existing codebase, domain features, review and improve existing documentation."

### Root Problem (5 Whys)
**Context loss** - Knowledge exists in code but isn't captured in forms that reduce future effort. Every feature takes longer because context must be rediscovered. No systematic process for capturing knowledge when it's fresh.

### User Journey
1. Developer joins brownfield project with sparse/outdated docs
2. Runs `/docs:audit` to understand documentation health
3. Gets gap report showing missing tutorials, outdated API docs, no AGENTS.md
4. Runs `/docs:write howto for authentication` to generate missing docs
5. When making architectural decisions, runs `/docs:adr` to capture rationale
6. Documentation improves incrementally, reducing onboarding time

---

## Core Principles

1. **Audit before create** - Understand documentation health before generating new docs
2. **Template-driven** - Consistency through templates, customization through content
3. **Idempotent updates** - Preserve custom sections, update only managed sections
4. **AI + Human audience** - Optimize for both readers simultaneously (Diátaxis + AGENTS.md)
5. **Progressive disclosure** - Load detail only when needed (keep SKILL.md lean)

---

## Trigger Conditions

### docs:audit
Run this skill when:
- Joining an existing project to assess documentation health
- Before major documentation effort to identify gaps
- Reviewing documentation quality or AI-friendliness
- User says "review my docs", "what docs are missing", "audit documentation", "check doc health"

Do NOT use this skill for:
- Writing new documentation → use `docs:write`
- Recording decisions → use `docs:adr`

### docs:write
Run this skill when:
- Creating new documentation of any type (tutorial, howto, reference, explanation)
- Updating existing documentation with template guidance
- Generating AI-focused files (CLAUDE.md, AGENTS.md, llms.txt)
- User says "write docs for", "create a tutorial", "document the API", "generate README"

Do NOT use this skill for:
- Assessing documentation health → use `docs:audit`
- Recording architectural decisions → use `docs:adr`

### docs:adr
Run this skill when:
- Making or recording an architectural decision
- Documenting why a technology/approach was chosen
- Capturing decision context before it's lost
- User says "record this decision", "create an ADR", "document why we chose", "capture rationale"

Do NOT use this skill for:
- Writing general documentation → use `docs:write`
- Assessing documentation health → use `docs:audit`

---

## Frontmatter Drafts

Each skill's YAML frontmatter serves as the primary trigger mechanism. The `description` field must include all "when to use" information since the SKILL.md body only loads after triggering.

### docs:audit
```yaml
---
name: docs-audit
description: Analyze documentation health for existing codebases. Detects structure, applies Diataxis gap analysis, checks AI-friendliness (CLAUDE.md, AGENTS.md, llms.txt), and scans for staleness. Use when joining a project, assessing documentation quality, or before a major documentation effort. Triggers on "review my docs", "what docs are missing", "audit documentation", "check doc health".
argument-hint: "[project-path] or run in current project"
---
```

### docs:write
```yaml
---
name: docs-write
description: Generate and update documentation using templates for any Diataxis type (tutorial, howto, reference, explanation), AI files (CLAUDE.md, AGENTS.md, llms.txt), architecture docs, and project files (README, CONTRIBUTING). Template-driven with idempotent updates that preserve custom sections. Use when creating or updating documentation. Triggers on "write docs for", "create a tutorial", "document the API", "generate README".
argument-hint: "[doc-type] [subject] e.g. 'howto authentication' or 'AGENTS.md'"
---
```

### docs:adr
```yaml
---
name: docs-adr
description: Record architectural decisions using MADR templates with full lifecycle support (Proposed, Accepted, Deprecated). Supports full, minimal, and bare template variants. Use when making or recording architectural decisions, documenting technology choices, or capturing decision rationale. Triggers on "record this decision", "create an ADR", "document why we chose", "capture rationale".
argument-hint: "[decision title] e.g. 'use PostgreSQL for persistence'"
---
```

---

## Documentation Foundation

### Research Validated
| Source | Key Finding | Application |
|--------|-------------|-------------|
| [Diátaxis](https://diataxis.fr/) | Four doc types: tutorials, howto, reference, explanation | Gap analysis categories |
| [AGENTS.md](https://agents.md/) | 60,000+ repos adopted, cross-platform standard | AI-friendliness checks |
| [MADR 4.0.0](https://adr.github.io/madr/) | Four template variants (full/minimal/bare) | ADR templates |
| [llms.txt](https://llmstxt.org/) | Up to 10x token reduction vs HTML | AI optimization |
| [Anthropic Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) | Progressive disclosure, 500-line limit | Skill architecture |
| [getsentry/skills](https://github.com/getsentry/skills) | agents-md + doc-coauthoring as separate skills | Modular pattern |
| [netresearch/agents-skill](https://github.com/netresearch/agents-skill) | Scoped detection, auto-extraction, templates | Automation patterns |

### Community Patterns Applied
| Pattern | From | How Applied |
|---------|------|-------------|
| Scoped file detection | netresearch/agents-skill | `docs:audit` auto-detects subsystems |
| Auto-extraction | netresearch/agents-skill | Extract commands from package.json, Makefile |
| Template variants | MADR 4.0.0 | Full, minimal, bare versions |
| Idempotent updates | netresearch/agents-skill | Preserve custom content, update managed sections |
| Domain organization | Anthropic best practices | references/diataxis/, references/ai-files/, etc. |
| Progressive disclosure | Anthropic best practices | SKILL.md as overview, references for detail |

---

## Boundaries

### Must Have (v1)
- Three focused skills: `docs:audit`, `docs:write`, `docs:adr`
- Full auto-detection of project structure in audit
- Template-driven generation for all doc types
- Diátaxis gap analysis
- AI-friendliness checks (CLAUDE.md, AGENTS.md, llms.txt)
- MADR template support with status lifecycle
- Integration points with existing workflow skills

### Deferred (v2+)
- Markdown linting integration (markdownlint, Vale)
- Documentation site generation
- API documentation from code (OpenAPI, JSDoc)
- Multi-language documentation
- Documentation translation

### Anti-Requirements
- Must NOT: Replace static site generators
- Must NOT: Generate marketing copy
- Must NOT: Sync to external documentation systems
- Must NOT: Require external services or API keys

### Kill Criteria
- Abandon if: Skills exceed 500 lines each (violates best practices)
- Abandon if: Template complexity exceeds benefit
- Abandon if: Audit automation proves unreliable

### Complexity Budget
- Max skills: 3
- Max lines per SKILL.md: ~400 (well under 500 limit)
- Max reference files: 15-20 (reasonable coverage)
- Token budget per invocation: SKILL.md (~400 lines) + 1-3 reference files loaded conditionally. Most invocations load 1 reference file (the relevant template). Audit loads quality-criteria.md (~200 lines). Total per invocation: ~600-800 lines context.

---

## Chosen Approach

### Summary
Three focused skills organized by documentation lifecycle: **audit** (analyze), **write** (create/update), and **adr** (decisions). Template-driven generation with progressive disclosure. Full auto-detection for brownfield codebase analysis.

### Why This Approach
1. **Matches proven Sentry pattern** - They separate `agents-md`, `doc-coauthoring`, `brand-guidelines`
2. **Lifecycle clarity** - Natural flow: audit → write → maintain
3. **ADR workflow is distinct** - Decision capture ≠ documentation creation
4. **Community validated** - Incorporates patterns from 60,000+ repos

### Trade-offs Accepted
- Three skills to maintain (vs. single skill simplicity)
- Template duplication across skills (vs. shared code)
- Glossary is integrated into write (vs. dedicated skill)

### Alternatives Considered
| Approach | Why Not Chosen |
|----------|----------------|
| Four skills (+ glossary) | Glossary maintenance doesn't need standalone workflow |
| Two skills (audit + generate) | ADRs have distinct lifecycle and workflow |
| Single skill | Would exceed 500-line limit, poor trigger specificity |

---

## Architecture

### Philosophy
Documentation skills follow the same patterns as existing workflow skills: explicit phases, self-review, exit signals. They complement but don't replace the feature workflow.

### Skill Overview

```
skills/
├── docs-audit/
│   ├── SKILL.md              # Analyze structure, gaps, AI-friendliness, staleness
│   └── references/
│       └── quality-criteria.md   # What good CLAUDE.md, AGENTS.md, llms.txt look like
├── docs-write/
│   ├── SKILL.md              # Generate documentation (any type from references)
│   └── references/           # Progressive disclosure - loaded on demand
│       ├── diataxis/
│       ├── ai-files/
│       ├── architecture/
│       └── project/
└── docs-adr/
    ├── SKILL.md              # Architecture Decision Records (MADR workflow)
    └── references/
        └── adr/              # MADR variants
```

### Component Responsibilities

#### docs:audit
| Component | Responsibility | Pattern Reference |
|-----------|----------------|-------------------|
| Structure Analyzer | Detect docs/, subsystems (backend/, frontend/) | netresearch scoped detection |
| Gap Detector | Apply Diátaxis categories, find missing types | Diátaxis framework |
| AI-Friendliness Checker | Verify CLAUDE.md, AGENTS.md, llms.txt | AGENTS.md standard |
| Staleness Scanner | Check doc age vs code changes | git blame analysis |
| Command Extractor | Pull from package.json, Makefile | netresearch auto-extraction |

#### docs:write
| Component | Responsibility | Pattern Reference |
|-----------|----------------|-------------------|
| Template Router | Select template based on doc type | Progressive disclosure |
| Content Generator | Fill templates with project context | Sentry doc-coauthoring |
| Glossary Manager | Extract/maintain domain terminology | Integrated maintenance |
| Cross-Reference Builder | Link related docs, code references | Reference-style links |
| Update Manager | Idempotent updates, preserve custom | netresearch pattern |

#### docs:adr
| Component | Responsibility | Pattern Reference |
|-----------|----------------|-------------------|
| Numbering Manager | Sequential IDs, collision prevention | MADR convention |
| Template Selector | Full, minimal, or bare template | MADR 4.0.0 |
| Status Manager | Proposed → Accepted → Deprecated | ADR lifecycle |
| Context Gatherer | Link to commits, PRs, related ADRs | Cross-referencing |

### Reference File Structure

Per skill-creator best practices, templates that Claude reads to inform content generation are classified as `references/` (loaded into context on demand). Each skill bundles only the references it needs.

```
docs-audit/references/
└── quality-criteria.md       # Evaluation criteria for AI files and doc quality

docs-write/references/
├── diataxis/
│   ├── tutorial.md           # Learning-oriented, step-by-step
│   ├── howto.md              # Task-oriented, assumes competence
│   ├── reference.md          # Information-oriented, technical
│   └── explanation.md        # Understanding-oriented, context
├── ai-files/
│   ├── claude-md.md          # Project instructions for Claude
│   ├── agents-md.md          # Cross-platform agent instructions
│   └── llms-txt.md           # LLM context optimization index
├── architecture/
│   ├── c4-context.md         # System context diagram guide
│   ├── c4-container.md       # Container diagram guide
│   ├── system-overview.md    # arc42-inspired overview
│   └── diagram-mermaid.md    # Mermaid conventions
└── project/
    ├── readme.md             # README template
    ├── contributing.md       # CONTRIBUTING template
    └── glossary.md           # Domain glossary template

docs-adr/references/
└── adr/
    ├── madr-full.md          # Complete MADR template
    ├── madr-minimal.md       # Required sections only
    └── madr-bare.md          # Sections without explanations
```

**Loading strategy:** SKILL.md contains the workflow and selection guidance. Claude loads only the relevant reference file based on the user's request (e.g., `howto.md` for a how-to guide, `madr-minimal.md` for a quick ADR). This keeps per-invocation context lean.

### Integration with Workflow Skills

```
┌─────────────────────────────────────────────────────────────────────┐
│                    INTEGRATION POINTS                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  WORKFLOW SKILL           TRIGGERS              DOCS SKILL           │
│  ──────────────           ────────              ──────────           │
│                                                                      │
│  /workflow:brainstorm ─── "document design" ──► docs:write           │
│  /workflow:plan ───────── "create plan docs" ─► docs:write           │
│  /workflow:execute ────── "record decision" ──► docs:adr             │
│  /workflow:compound ───── "update learnings" ─► docs:write           │
│                                                                      │
│  docs:audit ────────────── "gaps found" ──────► Recommendations      │
│  docs:audit ────────────── "create X doc" ────► docs:write           │
│  docs:write ────────────── "ADR needed" ──────► docs:adr             │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Workflows

### docs:audit Workflow

#### Phase 0: Prerequisites Check

**Step 0.1 - Resolve Project Root:**
```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
echo "Project root: ${PROJECT_ROOT}"
```

**Step 0.2 - Check for Existing Documentation:**
```bash
# Check existing doc structure
ls -la "${PROJECT_ROOT}/docs/" 2>/dev/null || echo "No docs/ folder"

# Check for AI files at root
ls "${PROJECT_ROOT}/CLAUDE.md" "${PROJECT_ROOT}/AGENTS.md" "${PROJECT_ROOT}/llms.txt" 2>/dev/null

# Check for package files (for command extraction)
ls "${PROJECT_ROOT}/package.json" "${PROJECT_ROOT}/Makefile" 2>/dev/null
```

**Verify:**
```
[ ] PROJECT_ROOT resolved correctly
[ ] Noted existing docs/ structure (or absence)
[ ] Identified AI files present/missing
[ ] Located package files for extraction
```

#### Phase 1-6: Audit Sequence

```markdown
## Audit Progress Checklist

- [ ] Phase 1: Auto-detect project structure
      - Scan for docs/, backend/, frontend/, src/, etc.
      - Identify subsystems and their documentation
- [ ] Phase 2: Analyze existing documentation
      - Inventory all .md files
      - Categorize by Diátaxis type
- [ ] Phase 3: Apply Diátaxis gap analysis
      - Check for tutorials (learning-oriented)
      - Check for how-to guides (task-oriented)
      - Check for reference docs (information-oriented)
      - Check for explanations (understanding-oriented)
- [ ] Phase 4: Check AI-optimization
      - CLAUDE.md presence and quality
      - AGENTS.md presence and quality
      - llms.txt presence
- [ ] Phase 5: Scan for staleness
      - Compare doc modification dates vs code changes
      - Flag docs not updated in >90 days with code changes
- [ ] Phase 6: Generate audit report with recommendations
      - Use report template (below)
      - Prioritized list of documentation needs
      - Specific actionable items
```

#### Audit Report Output Template

```markdown
# Documentation Audit Report

**Project:** {project-name}
**Date:** {date}
**Scope:** {subsystems audited}

## Summary

| Category | Status | Details |
|----------|--------|---------|
| Structure | {ok/gaps/missing} | {brief} |
| Diataxis Coverage | {N/4 types present} | {which types missing} |
| AI-Friendliness | {N/3 files present} | {which files missing} |
| Staleness | {N docs stale} | {oldest stale doc} |

## Documentation Inventory

| File | Diataxis Type | Last Updated | Status |
|------|---------------|--------------|--------|
| ... | tutorial/howto/reference/explanation/other | date | current/stale/outdated |

## Gap Analysis

### Diataxis Gaps
- **Tutorials:** {present/missing} - {recommendation}
- **How-to Guides:** {present/missing} - {recommendation}
- **Reference:** {present/missing} - {recommendation}
- **Explanation:** {present/missing} - {recommendation}

### AI-Friendliness
- **CLAUDE.md:** {present/missing/incomplete} - {recommendation}
- **AGENTS.md:** {present/missing/incomplete} - {recommendation}
- **llms.txt:** {present/missing} - {recommendation}

## Prioritized Recommendations

1. **[Critical]** {action item}
2. **[High]** {action item}
3. **[Medium]** {action item}

## Next Steps

Run `docs:write {type} {subject}` to address the highest-priority gaps.
```

---

### docs:write Workflow

#### Phase 0: Prerequisites Check

**Step 0.1 - Resolve Project Root:**
```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
echo "Project root: ${PROJECT_ROOT}"

# Ensure docs folder exists
mkdir -p "${PROJECT_ROOT}/docs"
```

**Step 0.2 - Check for Existing Documentation:**
```bash
# Check if target doc already exists
ls "${PROJECT_ROOT}/docs/" | grep -i "{doc-name}"

# Check existing doc conventions
ls "${PROJECT_ROOT}/docs/"
```

**Verify:**
```
[ ] PROJECT_ROOT resolved correctly
[ ] docs/ folder exists (created if needed)
[ ] Checked for existing doc with same name
[ ] Noted existing folder conventions
```

#### Phase 1-6: Writing Sequence

```markdown
## Writing Progress Checklist

- [ ] Phase 1: Detect documentation type from request
      - Tutorial: "learn", "getting started", "beginner"
      - How-to: "how to", "guide", "steps to"
      - Reference: "API", "reference", "specification"
      - Explanation: "why", "concept", "architecture"
      - AI file: "CLAUDE.md", "AGENTS.md", "llms.txt"
      - ADR: Redirect to docs:adr
- [ ] Phase 2: Select appropriate reference template
      - Load from references/{category}/{type}.md
- [ ] Phase 3: Gather project context
      - Read existing docs for style/conventions
      - Extract relevant code context
      - Check glossary for terminology
- [ ] Phase 4: Generate content with template
      - Fill template sections
      - Add project-specific examples
      - Include cross-references
- [ ] Phase 5: Validate structure and cross-references
      - All links resolve
      - Heading hierarchy correct
      - Code examples valid
- [ ] Phase 6: Write/update file with managed sections
      - Preserve custom content if updating
      - Use managed section markers
```

---

### docs:adr Workflow

#### Phase 0: Prerequisites Check

**Step 0.1 - Resolve Project Root:**
```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
echo "Project root: ${PROJECT_ROOT}"

# Ensure ADR folder exists
mkdir -p "${PROJECT_ROOT}/docs/adr"
```

**Step 0.2 - Check for Existing ADRs:**
```bash
# List existing ADRs to determine next number
ls "${PROJECT_ROOT}/docs/adr/" | grep -E "^[0-9]{4}-" | sort -r | head -5

# Check for related ADRs
grep -l "{decision keywords}" "${PROJECT_ROOT}/docs/adr/"*.md 2>/dev/null
```

**Verify:**
```
[ ] PROJECT_ROOT resolved correctly
[ ] docs/adr/ folder exists (created if needed)
[ ] Determined next sequential ADR number
[ ] Checked for related existing ADRs
```

#### Phase 1-6: ADR Sequence

```markdown
## ADR Progress Checklist

- [ ] Phase 1: Understand the decision to record
      - What decision was made?
      - Why was this decision necessary?
      - What problem does it solve?
- [ ] Phase 2: Select template variant
      - Full: Complex decisions with many options
      - Minimal: Standard decisions
      - Bare: Quick capture, fill details later
- [ ] Phase 3: Gather context
      - Options that were considered
      - Decision drivers (requirements, constraints)
      - Pros/cons of each option
      - Positive and negative consequences
- [ ] Phase 4: Generate ADR with sequential number
      - Format: NNNN-kebab-case-title.md
      - Example: 0001-use-postgresql-database.md
- [ ] Phase 5: Validate format and links
      - Status is set (Proposed/Accepted)
      - Related ADRs linked
      - Affected code/components noted
- [ ] Phase 6: Create ADR in docs/adr/
      - Write file
      - Confirm creation
```

---

## Error Handling

### Error Categories
| Category | Approach |
|----------|----------|
| Missing docs/ folder | Create with sensible defaults |
| Conflicting doc structures | Warn user, suggest consolidation |
| ADR number collision | Auto-increment to next available |
| Template not found | Fall back to generic, warn user |
| Stale detection false positive | Allow user override |

### Graceful Degradation
- If auto-detection fails: Fall back to manual specification
- If package.json parsing fails: Skip command extraction, continue audit
- If git not available: Skip staleness check, note limitation

---

## Quality Standards

### Documentation Audit
- [ ] Project structure detected correctly
- [ ] All doc directories scanned
- [ ] Diátaxis gaps identified with specific recommendations
- [ ] AI-files presence checked (CLAUDE.md, AGENTS.md, llms.txt)
- [ ] Staleness assessed with git history
- [ ] Report includes prioritized action items

### Documentation Writing
- [ ] Template selected matches documentation type
- [ ] Project context gathered (existing style, glossary)
- [ ] Cross-references validated (links resolve)
- [ ] Custom sections preserved (if updating)
- [ ] Output matches project folder conventions
- [ ] Heading hierarchy follows CommonMark (single H1)

### ADR Creation
- [ ] Sequential number assigned (no gaps, no collisions)
- [ ] Status lifecycle followed (Proposed → Accepted → Deprecated)
- [ ] Decision drivers documented (requirements, constraints)
- [ ] Options considered with pros/cons
- [ ] Consequences noted (positive and negative)
- [ ] Related ADRs linked

---

## Testing Philosophy

**Core behaviors requiring certainty:**
- Template rendering produces valid markdown
- ADR numbering is sequential without gaps
- Audit correctly identifies Diátaxis gaps
- Idempotent updates preserve custom content

**Risk areas for edge cases:**
- Non-standard project structures
- Mixed documentation conventions
- Partial AGENTS.md/CLAUDE.md files

**Approach:** Manual verification with example projects, checklist-based validation

---

## Anti-Patterns

❌ **Creating docs without audit**
```
"Let me generate a README for this project"
→ Might duplicate existing docs or miss project conventions
```

✅ **Audit first**
```
"Running docs:audit to understand existing documentation..."
"Found: partial README, no AGENTS.md, outdated API docs"
"Recommended: Complete README, create AGENTS.md, refresh API docs"
```

---

❌ **Ignoring existing doc structure**
```
Creating docs/guides/howto-auth.md when project uses docs/tutorials/
```

✅ **Follow existing conventions**
```
"Detected existing structure: docs/tutorials/, docs/reference/"
"Creating docs/tutorials/authentication.md to match convention"
```

---

❌ **Overwriting custom content**
```
Replacing entire file when only managed sections changed
```

✅ **Idempotent updates with managed sections**
```markdown
<!-- BEGIN MANAGED SECTION: auto-generated -->
This content is automatically updated by docs:write.
Do not edit manually.
<!-- END MANAGED SECTION -->

## Custom Notes
Your custom content here is preserved across updates.
```

---

❌ **ADRs without context**
```
# ADR 0005: Use Redis
We decided to use Redis.
```

✅ **ADRs with full decision context**
```markdown
# ADR 0005: Use Redis for Session Storage

## Status
Accepted

## Context
We need a session store that supports horizontal scaling...

## Decision Drivers
- Must support cluster deployment
- Team has Redis experience
- Need sub-millisecond latency

## Considered Options
1. Redis
2. Memcached
3. Database sessions

## Decision Outcome
Chosen: Redis, because...
```

---

❌ **Skipping AI-friendliness**
```
"Documentation is complete" (but no AGENTS.md, CLAUDE.md)
```

✅ **Including AI optimization**
```
"Documentation complete. Also generated:"
"- AGENTS.md for cross-platform AI agent support"
"- CLAUDE.md with project-specific instructions"
"- llms.txt index for context optimization"
```

---

## Work Decomposition Preview

### Logical Components
| Component | Scope | Implementation Order |
|-----------|-------|----------------------|
| Reference files | All reference templates (~15-20) | 1 - Foundation |
| docs:audit | Audit skill + auto-detection + quality-criteria.md | 2 - Entry point |
| docs:write | Write skill + reference routing | 3 - Core functionality |
| docs:adr | ADR skill + MADR references | 4 - Specialized |

### Context Considerations
- Reference files can be developed independently (no skill dependencies)
- docs:audit provides entry point for brownfield projects
- docs:write is the workhorse, most reference files used here
- docs:adr has distinct workflow, can be developed last

### Suggested Execution Order
1. **Reference files** - Foundation for all skills
2. **docs:audit** - Users need analysis before creation
3. **docs:write** - Primary generation capability
4. **docs:adr** - Specialized for decisions

---

## Exit Signals

| Skill | Signal | Meaning |
|-------|--------|---------|
| docs:audit | "audit complete" | Report generated, ready for action |
| docs:write | "docs committed" | Files written, ready for review |
| docs:adr | "adr created" | Decision recorded |
| Any | "refine" | Continue iterating |
| Any | "abort" | Cancel current operation |

---

## Open Questions (Resolved)

- ~~Should templates be in the skills repo or bundled with each skill?~~
  **Resolved:** Bundle with each skill as `references/` per skill-creator best practices. Skills must be self-contained.
- How to handle documentation in monorepos (multiple docs/ folders)?
  *Deferred to v2. For v1, audit scans from PROJECT_ROOT and notes multiple docs/ locations but doesn't attempt cross-package analysis.*
- ~~Should we support custom template directories?~~
  **Resolved:** No for v1. Reference files are bundled. Custom templates add complexity without proven need.

## Plugin Namespace Decision

These skills will be a **separate plugin** named `docs` (not added to the existing `workflow` plugin). This provides:
- Independent versioning and release cycle
- Clean `docs:audit`, `docs:write`, `docs:adr` invocation names
- Separate `plugin.json` in a dedicated repo or subfolder
- No coupling to the workflow skill lifecycle

The plugin structure:
```
docs-skills/
├── .claude-plugin/
│   └── plugin.json          # name: "docs"
├── skills/
│   ├── audit/               # → docs:audit
│   ├── write/               # → docs:write
│   └── adr/                 # → docs:adr
└── templates/
    └── CLAUDE.md
```

## Rollback Plan

If this approach fails:
- Skills are independent; can remove individually
- Templates are just markdown; easy to modify or replace
- No database or state to clean up

---

## Self-Review Log

### Round 1
**Issues Found:** 5
- [Trigger Conditions] Missing explicit triggers for each skill
  → Fix: Added Trigger Conditions section with specific phrases
- [Phase 0] No PROJECT_ROOT pattern like brainstorm
  → Fix: Added Phase 0 prerequisites to each workflow
- [Anti-Patterns] Section missing entirely
  → Fix: Added Anti-Patterns with ❌/✅ examples
- [Quality Standards] Only Testing Philosophy present
  → Fix: Added Quality Standards checklist by skill
- [Core Principles] Design lacks guiding philosophy
  → Fix: Added Core Principles section (5 principles)

### Round 2 (fresh read)
**Issues Found:** 1
- [Component Tables] Inconsistent column naming (Pattern vs Pattern Reference)
  → Fix: Standardized to "Pattern Reference" in all tables

### Round 3 (fresh read)
**Issues Found:** 0
- All themes pass ✅

### Round 4 (skill-creator review)
**Issues Found:** 10 (3 critical, 4 significant, 3 minor)
- [Resource Directories] Used non-standard `templates/` instead of `references/`
  → Fix: Renamed to `references/` per skill anatomy (scripts/references/assets)
- [Frontmatter] Missing YAML frontmatter drafts for each skill
  → Fix: Added Frontmatter Drafts section with name, description, argument-hint
- [Argument Hints] Missing `argument-hint` field (all existing skills use it)
  → Fix: Added argument-hint to each frontmatter draft
- [Directory Names] `diátaxis/` accent mark causes filesystem issues
  → Fix: Changed to `diataxis/` throughout
- [Audit Output] No report template for audit results
  → Fix: Added Audit Report Output Template with structured format
- [Negative Triggers] Missing "Do NOT use for" redirects per skill
  → Fix: Added negative triggers with redirects to correct skill
- [Audit References] docs-audit had no bundled references for quality evaluation
  → Fix: Added `references/quality-criteria.md` to docs-audit
- [Open Questions] First and third questions answered by skill-creator best practices
  → Fix: Resolved with rationale, kept monorepo question as deferred
- [Plugin Namespace] Undecided whether new plugin or extend workflow
  → Fix: Added Plugin Namespace Decision section (separate `docs` plugin)
- [Token Budget] No estimate of context cost per invocation
  → Fix: Added token budget estimate to Complexity Budget section

---

*Design created: 2026-01-26*
*Updated: 2026-01-27 (skill-creator review)*
*Research sources: Diátaxis, AGENTS.md, MADR, llms.txt, Anthropic best practices, getsentry/skills, netresearch/agents-skill, VoltAgent/awesome-claude-skills*
