---
name: docs-write
description: Generate and update documentation using templates for any Diataxis type (tutorial, howto, reference, explanation), AI files (CLAUDE.md, AGENTS.md, llms.txt), architecture docs (C4 context/container, system overview, Mermaid diagrams), and project files (README, CONTRIBUTING, glossary). Template-driven with idempotent updates that preserve custom sections. Use when creating or updating documentation. Triggers on "write docs for", "create a tutorial", "document the API", "generate README", "create AGENTS.md", "write architecture overview".
argument-hint: "[doc-type] [subject] e.g. 'howto authentication' or 'AGENTS.md'"
---

# docs:write — Documentation Generation & Update

**Philosophy:** Template-driven documentation with progressive disclosure. Load only the reference template needed for the current request. Respect existing project conventions. Preserve custom content when updating.

## Core Principles

1. **Template-driven** - Consistency through templates, customization through content
2. **One reference per invocation** - Load only the selected template, not all 14
3. **Idempotent updates** - Preserve custom sections, update only managed sections
4. **Convention-aware** - Detect and follow existing project documentation structure
5. **Progressive disclosure** - SKILL.md routes, reference files provide detail

---

## Trigger Conditions

Run this skill when:
- Creating new documentation of any type
- Updating existing documentation with template guidance
- Generating AI-focused files (CLAUDE.md, AGENTS.md, llms.txt)
- Writing architecture documentation (C4, system overview)
- User says "write docs for", "create a tutorial", "document the API", "generate README"

**Do NOT use this skill for:**
- Assessing documentation health → Use `docs:audit`
- Recording architectural decisions → Use `docs:adr`
- "Review my docs" or "what's missing" → Use `docs:audit`
- "Record this decision" or "create an ADR" → Use `docs:adr`

---

## Critical Sequence

### Phase 0: Prerequisites Check

**Step 0.1 - Resolve Project Root:**

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
echo "Project root: ${PROJECT_ROOT}"

# Ensure docs folder exists
mkdir -p "${PROJECT_ROOT}/docs"
```

**Step 0.2 - Check Existing Documentation:**

```bash
# Check if target doc already exists
ls "${PROJECT_ROOT}/docs/"

# Check existing folder conventions (tutorials/ vs guides/ etc.)
find "${PROJECT_ROOT}/docs" -type d -maxdepth 2
```

**Verify:**
```
[ ] PROJECT_ROOT resolved correctly
[ ] docs/ folder exists (created if needed)
[ ] Checked for existing doc with same name/topic
[ ] Noted existing folder conventions
```

---

### Phase 1: Template Router

Classify the request and select the appropriate reference template. **Load only one reference file.**

#### Diataxis Types

| Trigger Keywords | Reference File | Doc Type |
|-----------------|----------------|----------|
| "tutorial", "learn", "getting started", "beginner" | `references/diataxis/tutorial.md` | Learning-oriented lesson |
| "how to", "howto", "guide", "steps to" | `references/diataxis/howto.md` | Task-oriented guide |
| "API", "reference", "specification", "config" | `references/diataxis/reference.md` | Information-oriented reference |
| "why", "concept", "explanation", "about", "understanding" | `references/diataxis/explanation.md` | Understanding-oriented discussion |

#### AI Files

| Trigger Keywords | Reference File | Doc Type |
|-----------------|----------------|----------|
| "CLAUDE.md", "claude instructions" | `references/ai-files/claude-md.md` | Project instructions for Claude |
| "AGENTS.md", "agent instructions" | `references/ai-files/agents-md.md` | Cross-platform agent instructions |
| "llms.txt", "llm index" | `references/ai-files/llms-txt.md` | LLM context optimization index |

#### Architecture

| Trigger Keywords | Reference File | Doc Type |
|-----------------|----------------|----------|
| "context diagram", "C4 context", "system context" | `references/architecture/c4-context.md` | C4 context diagram |
| "container diagram", "C4 container" | `references/architecture/c4-container.md` | C4 container diagram |
| "system overview", "architecture overview", "arc42" | `references/architecture/system-overview.md` | System architecture overview |
| "diagram", "mermaid", "diagram conventions" | `references/architecture/diagram-mermaid.md` | Mermaid diagram guide |

#### Project Files

| Trigger Keywords | Reference File | Doc Type |
|-----------------|----------------|----------|
| "README", "project readme" | `references/project/readme.md` | Project README |
| "CONTRIBUTING", "contribution guide" | `references/project/contributing.md` | Contributor guide |
| "glossary", "terminology", "domain terms" | `references/project/glossary.md` | Domain glossary |

#### Redirects and Ambiguity

| Trigger Keywords | Action |
|-----------------|--------|
| "ADR", "decision", "why we chose" | → Redirect to `docs:adr` |
| "audit", "review docs", "what's missing" | → Redirect to `docs:audit` |
| Ambiguous or unclear request | → Ask user to clarify doc type |

**If the request is ambiguous**, ask the user:
> "What type of documentation would you like? Options: tutorial, how-to guide, reference, explanation, AI file (CLAUDE.md/AGENTS.md/llms.txt), architecture doc, or project file (README/CONTRIBUTING)?"

---

### Phase 2: Load Reference Template

Read the selected reference file from `references/`:

```
- Load ONLY the one reference file identified in Phase 1
- Parse the template structure, required sections, and anti-patterns
- Note guidance specific to this doc type
```

---

### Phase 3: Gather Project Context

Before generating content, understand the project:

```
- Read existing docs to match style and tone
- Extract relevant code context for the subject being documented
- Check for existing glossary terms (if glossary exists)
- Identify related docs to cross-reference
- Detect naming conventions (kebab-case files? docs/tutorials/ or docs/guides/?)
```

---

### Phase 4: Generate Content

Fill the template with project-specific content:

```
- Apply template structure from the loaded reference
- Add project-specific examples from the codebase
- Include cross-references to related documentation
- Use terminology consistent with existing docs and code
- Follow detected folder conventions for file placement
```

---

### Phase 5: Validate

Before writing, check:

```
[ ] Single H1 heading
[ ] Logical heading hierarchy (no skipped levels)
[ ] All internal links resolve to existing targets
[ ] Code examples are syntactically valid
[ ] Cross-references to related docs included
[ ] Terminology matches existing glossary (if one exists)
[ ] File path follows project conventions
```

---

### Phase 6: Write or Update

**New file:** Write the complete document at the appropriate path.

**Existing file (update):** Use idempotent update with managed sections:

```markdown
<!-- BEGIN MANAGED SECTION: {section-name} -->
<!-- Auto-generated by docs:write. Do not edit manually. -->
{Generated content here}
<!-- END MANAGED SECTION: {section-name} -->

## Custom Notes
Your custom content here is preserved across updates.
```

**Update rules:**
- Only modify content between matching `BEGIN/END MANAGED SECTION` markers
- Preserve everything outside managed sections
- If no managed sections exist, treat entire file as custom — ask before overwriting
- Add new managed sections at appropriate positions, don't reorganize existing content

---

## Quality Standards

- [ ] Template selected matches documentation type
- [ ] Only one reference file loaded per invocation
- [ ] Project context gathered (existing style, glossary, conventions)
- [ ] Cross-references validated (links resolve to existing targets)
- [ ] Custom sections preserved when updating existing docs
- [ ] Output matches project folder conventions
- [ ] Heading hierarchy follows CommonMark (single H1)
- [ ] Code examples are syntactically valid

---

## Anti-Patterns

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
<!-- BEGIN MANAGED SECTION: api-reference -->
This content is auto-generated. Do not edit manually.
<!-- END MANAGED SECTION: api-reference -->

## Custom Notes
Your custom content is preserved across updates.
```

---

❌ **Loading multiple templates**
```
Reading all 14 reference files to decide which template to use
```

✅ **Route then load**
```
"Request is for a how-to guide → loading references/diataxis/howto.md"
(Only one reference file loaded)
```

---

❌ **Guessing doc type when ambiguous**
```
User says "document authentication" → silently picking "reference"
```

✅ **Ask when ambiguous**
```
"Would you like a how-to guide (task steps), reference (API details),
tutorial (learning exercise), or explanation (design rationale)?"
```

---

❌ **Generic content without project context**
```
Writing a README with placeholder text and no project-specific details
```

✅ **Content informed by codebase**
```
"Extracted build commands from package.json"
"Found 3 API endpoints to document from src/routes/"
"Using terminology from existing glossary"
```

---

## Exit Signals

| Signal | Meaning |
|--------|---------|
| "docs committed" | File written, ready for review |
| "refine" | Continue iterating on content |
| "abort" | Cancel current operation |
| "audit docs" | → Redirect to `docs:audit` |
| "record decision" | → Redirect to `docs:adr` |
| "create ADR" | → Redirect to `docs:adr` |

When complete: **"Documentation written. Review the generated file and refine if needed."**
