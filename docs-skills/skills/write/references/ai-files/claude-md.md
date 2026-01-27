# CLAUDE.md Template

A CLAUDE.md file provides **project-specific instructions** for Claude Code. It supplements what Claude can infer from code by capturing conventions, commands, and patterns that aren't obvious from the source alone.

## Required Sections

### Project Overview
```markdown
# {Project Name}

{1-2 sentences: what the project does, primary language/framework, key dependencies.}
```

### Build & Run Commands
```markdown
## Development

```bash
{install command}
{build command}
{run command}
{test command}
```
```

Commands must be copy-paste executable. Include the full command, not a description.

### Code Conventions
```markdown
## Code Conventions

- {Naming: e.g., "camelCase for functions, PascalCase for types"}
- {Patterns: e.g., "use Result<T> for fallible operations, never throw"}
- {Style: e.g., "prefer primary constructors over field-backed constructors"}
- {Imports: e.g., "group by stdlib → external → internal, alphabetized"}
```

Be specific. "Use camelCase for functions" is useful. "Follow best practices" is not.

### Testing
```markdown
## Testing

```bash
{test command}
{single test command with filter example}
```

- Framework: {name}
- Pattern: {e.g., "one test file per module, named {module}_test.go"}
- Conventions: {e.g., "use table-driven tests, test factories in tests/helpers/"}
```

## Optional Sections

### Key Architecture
```markdown
## Architecture

- `src/services/` — Business logic, one service per domain
- `src/models/` — Data structures, immutable records
- `src/api/` — HTTP handlers, thin wrappers over services
```

Include only what helps Claude navigate — not a full directory listing.

### Error Handling
```markdown
## Error Handling

- {Pattern: e.g., "return errors, don't panic/throw"}
- {When builds fail: e.g., "run `make clean` first, check Node version >= 20"}
```

### Commit Conventions
```markdown
## Commits

- Format: `{type}({scope}): {message}`
- Types: feat, fix, refactor, test, docs, chore
```

## Anti-Patterns
- ❌ Duplicating README content (CLAUDE.md is for Claude, not humans)
- ❌ Vague guidance ("follow standard practices")
- ❌ Outdated commands that no longer work
- ❌ Documenting things Claude can infer from the code itself
- ❌ Walls of text instead of scannable lists and code blocks

## Good Indicators
- Every command is executable without modification
- Conventions are specific enough to resolve ambiguity
- Includes project-specific patterns Claude wouldn't guess
- References key files and directories by path
- Stays under 200 lines (concise is better)
