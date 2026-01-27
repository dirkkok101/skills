# CONTRIBUTING Template

A CONTRIBUTING file tells potential contributors **how to participate**. It covers development setup, coding standards, the PR process, and what reviewers look for.

## Template

```markdown
# Contributing to {Project Name}

Thank you for your interest in contributing. This guide covers setup, standards, and the PR process.

## Development Setup

### Prerequisites

- {Runtime and version, e.g., "Node.js >= 20"}
- {Package manager, e.g., "npm or yarn"}

### Getting Started

```bash
git clone {repo-url}
cd {project}
{install command}
{build command}
{test command to verify setup}
```

## Coding Standards

### Style
- {Formatting tool and config, e.g., "Prettier with project .prettierrc"}
- {Linting, e.g., "ESLint — run `npm run lint` before committing"}

### Naming
- {Convention, e.g., "camelCase for functions, PascalCase for types"}

### Testing
- {Framework, e.g., "Jest for unit tests, Playwright for E2E"}
- {Expectation, e.g., "New features require tests, bug fixes require regression tests"}
- {Run command, e.g., "`npm test` for full suite, `npm test -- --filter {name}` for single test"}

### Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
{type}({scope}): {description}

Types: feat, fix, refactor, test, docs, chore
```

## Pull Request Process

### Before Submitting

- [ ] Code follows the style guidelines above
- [ ] Tests pass locally (`{test command}`)
- [ ] Lint passes (`{lint command}`)
- [ ] New features include tests
- [ ] Documentation updated if applicable

### PR Format

```markdown
## Summary
{What this PR does and why}

## Changes
- {Change 1}
- {Change 2}

## Testing
- {How you tested this}
```

### Review Process

- {Who reviews, e.g., "At least one maintainer approval required"}
- {Timeline, e.g., "Reviews typically within 48 hours"}
- {Merge strategy, e.g., "Squash and merge to main"}

## Reporting Issues

Use [GitHub Issues]({issues-url}) with:
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, runtime version)
```

## Guidance
- Keep setup instructions executable — a new contributor should go from clone to running tests
- Be specific about standards (tool names, config files) rather than generic ("write clean code")
- Include the PR checklist so contributors self-review before submitting
- Don't prescribe tools the project doesn't actually use

## Anti-Patterns
- ❌ Setup instructions that skip steps or assume prior knowledge
- ❌ Vague standards ("write good tests") instead of specific ones
- ❌ Missing PR process — contributors won't know what to expect
- ❌ Too opinionated about specific tools when the project is flexible
- ❌ No mention of how to report issues
