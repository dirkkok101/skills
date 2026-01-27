# Quality Criteria for Documentation Audit

Evaluation criteria for AI-optimization files and general documentation quality. Use during Phase 4 of the audit workflow.

## CLAUDE.md Quality

### Required Elements
- Project overview (what the project does, key technologies)
- Build and run commands (exact commands, not descriptions)
- Code conventions (naming, patterns, style rules)
- Testing instructions (how to run tests, what framework)

### Good Indicators
- Commands are copy-paste executable
- Conventions are specific ("use camelCase for functions") not vague ("follow best practices")
- Includes project-specific patterns agents wouldn't infer from code alone
- References key files and directories by path

### Anti-Patterns
- ❌ Vague instructions ("follow standard practices")
- ❌ Outdated commands (build steps that no longer work)
- ❌ Duplicating README content instead of agent-specific guidance
- ❌ Missing error handling guidance (what to do when builds fail)

## AGENTS.md Quality

### Required Elements
- Setup commands (installation, environment initialization)
- Build and test instructions (concrete, executable commands)
- Code style guidelines (formatting, naming, patterns)
- PR/commit conventions (message format, branch naming)

### Good Indicators
- Instructions are actionable and executable by agents
- Closest-to-file precedence documented when nested AGENTS.md exist
- Testing procedures include expected outcomes
- Concrete commands, not abstract descriptions

### Anti-Patterns
- ❌ Cluttered with human-facing content (use README for that)
- ❌ Vague instructions agents can't execute literally
- ❌ Missing tool permissions or environment requirements
- ❌ No context sections explaining project architecture

### Spec Compliance
- Standard Markdown with any heading structure
- Placed at repository root (nested files override for subdirectories)
- Agents attempt to run listed commands — instructions must be concrete

## llms.txt Quality

### Required Elements
- H1 heading with project/site name
- Blockquote summary with key project context

### Good Indicators
- Token-efficient (concise, no boilerplate)
- H2 sections with categorized URL lists
- "Optional" section separates supplementary from core content
- Link descriptions provide context (`[name](url): what this covers`)

### Anti-Patterns
- ❌ Raw HTML dumps instead of structured Markdown
- ❌ Unstructured content without clear sections
- ❌ Using heading levels beyond H1 and H2
- ❌ Missing descriptions on linked resources
- ❌ Jargon without explanation

### Spec Compliance
- Only H1 and H2 headings (no H3+)
- Section order: H1 → blockquote → body → H2 file lists
- File list items: `[name](url)` with optional `: description`

## General Documentation Quality

### Structure
- Single H1 per document
- Logical heading hierarchy (no skipped levels)
- Table of contents for documents over 100 lines

### Content
- Links resolve to existing targets (no broken links)
- Code examples are syntactically valid
- Cross-references to related docs where relevant

### Freshness
- Doc last modified within 6 months of related code changes (via git log)
- No references to deprecated APIs, removed features, or old versions
- Version numbers and dependency references are current

### AI-Friendliness
- Clear, scannable structure (headings, lists, tables over prose walls)
- Key information frontloaded (most important content first)
- Terminology consistent with codebase naming
