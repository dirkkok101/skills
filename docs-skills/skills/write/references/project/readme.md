# README Template

A README is the **front door** to a project. It answers: What is this? How do I use it? How do I contribute? Every section should help a new visitor get oriented quickly.

## Template

```markdown
# {Project Name}

{Optional badges: build status, version, license, coverage}

{1-2 sentences: what this project does and who it's for.}

## Features

- {Key feature 1}
- {Key feature 2}
- {Key feature 3}

## Getting Started

### Prerequisites

- {Runtime/tool requirement, e.g., "Node.js >= 20"}
- {Other dependency}

### Installation

```bash
{clone or install command}
{dependency install command}
```

### Usage

```bash
{primary run command}
```

{Brief description of what happens, or a minimal usage example.}

## Documentation

- {Link to full docs, API reference, or wiki if they exist}

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, coding standards, and PR process.

## License

{License type} — see [LICENSE](LICENSE) for details.
```

## Optional Sections

Add these when relevant:

### Configuration
```markdown
## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `{VAR}` | `{default}` | {What it controls} |
```

### Architecture
```markdown
## Architecture

{Brief overview or link to architecture docs.}
```

### FAQ / Troubleshooting
```markdown
## Troubleshooting

### {Common issue}
{Solution}
```

## Guidance
- Put the most important information first (what it does, how to install)
- Keep the README under 200 lines — link to separate docs for details
- Every command should be copy-paste executable
- Don't duplicate content from CONTRIBUTING.md or docs — link to them
- Include a license section even if it's just a link to the LICENSE file

## Anti-Patterns
- ❌ Missing installation or usage instructions
- ❌ No license information
- ❌ Walls of text without structure or code examples
- ❌ Outdated commands that no longer work
- ❌ Duplicating CONTRIBUTING.md content instead of linking
