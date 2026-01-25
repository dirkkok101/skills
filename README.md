# Feature Workflow Skills

A complete feature development workflow for Claude Code with structured phases: brainstorm, plan, beads, execute, review, and compound.

## Overview

| Skill | Purpose | Output |
|-------|---------|--------|
| `/brainstorm` | Transform ideas into validated designs | `docs/designs/{feature}/design.md` |
| `/plan` | Convert designs into hierarchical implementation plans | `docs/plans/{feature}/overview.md` |
| `/beads` | Create intent-based work packages (tasks) | Beads in `br` database |
| `/execute` | Implement beads with surgical context loading | Working code |
| `/review` | Multi-agent parallel code review | Findings and fixes |
| `/compound` | Capture learnings for future work | `docs/learnings/{category}.md` |

## Prerequisites

### br (beads-rust) CLI

These skills use `br` for task management with dependencies.

```bash
# Install br (see https://github.com/anthropics/beads-rust for details)
cargo install beads-rust

# Initialize in your project
br init
```

### Project Structure

The skills expect and create documentation in your project root:

```
your-project/
├── docs/
│   ├── designs/      # Created by /brainstorm
│   ├── plans/        # Created by /plan
│   ├── learnings/    # Created by /compound
│   ├── reference/    # Your project's reference docs (optional)
│   ├── systems/      # Your project's system docs (optional)
│   └── architecture/ # Your project's architecture docs (optional)
└── .beads/
    └── beads.db      # Created by br init
```

## Installation

### Add Marketplace

```bash
/plugin marketplace add dirkkok101/skills
```

### Install Plugin

```bash
/plugin install feature-workflow@dirkkok-skills
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

## Philosophy

- **Documentation-First**: All phases produce permanent documentation
- **Intent Over Implementation**: Beads contain objectives, not source code
- **Surgical Context**: Each bead specifies exactly which files to read
- **Continuous Learning**: `/compound` captures learnings for future features

## License

MIT
