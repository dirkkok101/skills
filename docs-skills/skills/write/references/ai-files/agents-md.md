# AGENTS.md Template

An AGENTS.md file provides **instructions for AI coding agents** across platforms (Codex, Copilot, Claude Code, etc.). It uses standard Markdown with free-form structure. Agents treat listed commands as executable — every instruction must be concrete.

## Spec Summary
- Standard Markdown, any heading structure
- Placed at repository root; nested files override for subdirectories (closest-to-file wins)
- Agents attempt to run listed commands literally
- Audience is AI agents, not humans (use README for humans)

## Template

```markdown
# AGENTS.md

## Setup

```bash
{install dependencies}
{environment setup}
```

## Build & Test

```bash
{build command}
{test command — full suite}
{test command — single test, with filter example}
```

Expected test output: {what passing looks like, e.g., "All tests passed" or exit code 0}

## Code Style

- Language: {primary language and version}
- Formatting: {tool and config, e.g., "prettier with .prettierrc"}
- Naming: {conventions, e.g., "camelCase functions, PascalCase types"}
- Imports: {ordering convention}
- Error handling: {pattern, e.g., "return Result<T>, never throw"}

## Project Structure

- `src/` — {what it contains}
- `tests/` — {test organization}
- `docs/` — {documentation location}

## PR & Commit Conventions

- Branch naming: `{type}/{description}` (e.g., `feat/add-auth`)
- Commit format: `{type}({scope}): {message}`
- PR requirements: {e.g., "all tests pass, no lint warnings"}

## Permissions

- {Tool permissions if applicable, e.g., "May run `npm test` and `npm run lint`"}
- {File access restrictions, e.g., "Do not modify files in `config/production/`"}
```

## Nested AGENTS.md

For monorepos or subdirectories with different conventions:

```
repo/
├── AGENTS.md              # Root: general conventions
├── frontend/
│   └── AGENTS.md          # Overrides for frontend (closer to file wins)
└── backend/
    └── AGENTS.md          # Overrides for backend
```

Nested files should only contain overrides, not repeat root content.

## Anti-Patterns
- ❌ Human-facing content (that belongs in README)
- ❌ Vague instructions agents can't execute literally ("ensure quality")
- ❌ Missing tool permissions or environment requirements
- ❌ No context sections explaining project architecture
- ❌ Repeating root content in nested files instead of overriding

## Good Indicators
- Instructions are executable without human interpretation
- Commands include expected outcomes
- Closest-to-file precedence is documented when nested files exist
- Architecture section helps agents navigate the codebase
- Permissions and restrictions are explicit
