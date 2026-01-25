# Feature Workflow Skills

A complete feature development workflow for Claude Code with structured phases: brainstorm, plan, beads, execute, review, and compound.

## Overview

| Command | Purpose | Output |
|---------|---------|--------|
| `/brainstorm` | Transform ideas into validated designs | `docs/designs/{feature}/design.md` |
| `/plan` | Convert designs into hierarchical implementation plans | `docs/plans/{feature}/overview.md` |
| `/beads` | Create intent-based work packages (tasks) | Beads in `br` database |
| `/execute` | Implement beads with surgical context loading | Working code |
| `/review` | Multi-agent parallel code review | Findings and fixes |
| `/compound` | Capture learnings for future work | `docs/learnings/{category}.md` |

## Installation

### Step 1: Install br (beads-rust) CLI

These skills require `br` for task management with dependencies.

```bash
# Install br
cargo install beads-rust

# Verify installation
br version
```

### Step 2: Install the Plugin

In Claude Code:

```bash
# Add marketplace
/plugin marketplace add dirkkok101/skills

# Install plugin
/plugin install workflow@dirkkok-skills
```

### Step 3: Set Up Your Project

Initialize beads in your project:

```bash
cd your-project
br init
```

Copy the template files to your project root:

```bash
# From this repository's templates/ folder, copy to your project:
# - templates/CLAUDE.md → your-project/CLAUDE.md
# - templates/AGENTS.md → your-project/AGENTS.md
```

Or download directly:

```bash
curl -o CLAUDE.md https://raw.githubusercontent.com/dirkkok101/skills/main/templates/CLAUDE.md
curl -o AGENTS.md https://raw.githubusercontent.com/dirkkok101/skills/main/templates/AGENTS.md
```

### Project Structure After Setup

```
your-project/
├── CLAUDE.md           # From templates/CLAUDE.md
├── AGENTS.md           # From templates/AGENTS.md
├── .beads/
│   └── beads.db        # Created by br init
└── docs/               # Created by workflow skills
    ├── designs/        # Created by /brainstorm
    ├── plans/          # Created by /plan
    └── learnings/      # Created by /compound
```

## Usage

### Workflow

```
/brainstorm → "design approved" → /plan → "plan approved" → /beads → "beads approved" → /execute → /review → /compound
```

### Starting a Feature

```
/brainstorm I want to add user authentication
```

### Quick Reference

| Command | When to Use |
|---------|-------------|
| `/brainstorm [idea]` | Starting a new feature |
| `/plan [feature]` | After design is approved |
| `/beads [feature]` | After plan is approved |
| `/execute [epic-id]` | After beads are approved |
| `/review` | After implementation complete |
| `/compound [topic]` | After review to capture learnings |

## What the Templates Provide

### CLAUDE.md

- Instructions for using beads vs TodoWrite
- Feature workflow overview with approval gates
- Documentation structure expectations
- Session start/end workflows
- Placeholder for project-specific instructions

### AGENTS.md

- Complete `br` CLI reference
- "Landing the plane" checklist (mandatory push before stopping)
- Issue lifecycle commands
- Dependency management
- Query and search commands

## Philosophy

- **Documentation-First**: All phases produce permanent documentation
- **Intent Over Implementation**: Beads contain objectives, not source code
- **Surgical Context**: Each bead specifies exactly which files to read
- **Continuous Learning**: `/compound` captures learnings for future features
- **Explicit Approval**: Each phase requires user approval before proceeding

## License

MIT
