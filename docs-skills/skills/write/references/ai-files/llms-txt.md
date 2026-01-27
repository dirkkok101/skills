# llms.txt Template

An llms.txt file provides a **token-efficient index** of a project or website for LLM consumption. It follows a strict structure: only H1 and H2 headings, a blockquote summary, and categorized URL lists.

## Spec Summary
- Only H1 (`#`) and H2 (`##`) headings — no H3 or deeper
- Section order: H1 title → blockquote summary → optional body → H2 file lists
- File list items: `[name](url)` with optional `: description`
- Token-efficient: concise, no boilerplate or filler
- Served at `/{project}/llms.txt` or site root `/llms.txt`

## Template

```markdown
# {Project or Site Name}

> {1-3 sentence summary: what this project does, who it's for, key capabilities. This is the most important context — LLMs read this first.}

{Optional body: additional context, key concepts, or terminology that helps LLMs understand the project. Keep brief.}

## Docs

- [Getting Started](url): Setup and first steps
- [API Reference](url): Complete API documentation
- [Architecture](url): System design and component overview

## Optional

- [Contributing Guide](url): How to contribute
- [Changelog](url): Version history
- [FAQ](url): Common questions
```

## Section Guidelines

### H1 Title
Use the project name. One H1 per file.

### Blockquote Summary
The single most important paragraph. Frontload key information: what the project does, primary technology, target audience.

### Body (Optional)
Brief additional context. Use for:
- Key terminology or concepts
- Scope boundaries ("covers X, not Y")
- Relationship to other projects

### H2 Sections
Categorize links logically. Common categories:
- `## Docs` — Core documentation
- `## API` — API references and endpoints
- `## Examples` — Code examples and tutorials
- `## Optional` — Supplementary resources (separates nice-to-have from essential)

### Link Descriptions
Every link should have a description: `[name](url): what this covers`. Bare links without descriptions waste LLM context by requiring the LLM to fetch the link to understand what it contains.

## Anti-Patterns
- ❌ Using heading levels beyond H1 and H2
- ❌ Raw HTML dumps instead of structured Markdown
- ❌ Unstructured content without clear sections
- ❌ Missing descriptions on linked resources
- ❌ Jargon without explanation
- ❌ Listing every page — curate the most useful resources

## Good Indicators
- Blockquote summary is self-contained and informative
- Links are categorized logically with descriptive text
- "Optional" section separates supplementary from core content
- Total file is under 100 lines (token-efficient)
- A new LLM reading this file could understand the project's scope and find relevant docs
