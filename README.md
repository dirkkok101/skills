# Feature Workflow Skills

A complete feature development workflow for Claude Code with structured phases: diagnose, brainstorm, plan, beads, execute, review, and compound.

## Overview

| Command | Purpose | Output |
|---------|---------|--------|
| `/workflow:diagnose` | Investigate bugs with root cause analysis and adaptive triage | Fix, beads, or design handoff |
| `/workflow:brainstorm` | Transform ideas into validated designs | `docs/designs/{feature}/design.md` |
| `/workflow:plan` | Convert designs into hierarchical implementation plans | `docs/plans/{feature}/overview.md` |
| `/workflow:beads` | Create intent-based work packages (tasks) | Beads in `br` database |
| `/workflow:execute` | Implement beads with surgical context loading | Working code |
| `/workflow:review` | Multi-agent parallel code review | Findings and fixes |
| `/workflow:compound` | Capture learnings for future work | `docs/learnings/{category}.md` |

> **Note:** All commands use the `workflow:` namespace prefix because this is a marketplace plugin. This prevents conflicts with other plugins.

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
    ├── designs/        # Created by /workflow:brainstorm
    ├── plans/          # Created by /workflow:plan
    └── learnings/      # Created by /workflow:compound
```

## Updating the Plugin

If skills show only short descriptions instead of the full workflow, you need to update to the latest version.

### Check Your Version

Run `/plugin` in Claude Code, go to the **Installed** tab. You should see version **1.9.0** or higher.

### Update to Latest

```bash
claude plugin update workflow@dirkkok-skills
```

Or through the interactive UI:
1. Run `/plugin`
2. Go to **Installed** tab
3. Select `workflow`
4. Choose the update option

### Enable Auto-Updates (Recommended)

To receive future updates automatically:
1. Run `/plugin`
2. Go to **Marketplaces** tab
3. Select `dirkkok-skills`
4. Select **Enable auto-update**

### Troubleshooting: Skills Not Loading Full Content

If skills only show a short description instead of the full workflow:

1. **Clear plugin cache:**
   ```bash
   rm -rf ~/.claude/plugins/cache
   ```

2. **Reinstall the plugin:**
   ```bash
   claude plugin update workflow@dirkkok-skills
   ```

3. **Restart Claude Code** completely

4. **Verify installation:** Run `/plugin`, check the **Installed** tab shows version 1.9.0+

## Usage

### Workflow

**Feature Development:**
```
/workflow:brainstorm → "design approved" → /workflow:plan → "plan approved" → /workflow:beads → "beads approved" → /workflow:execute → /workflow:review → /workflow:compound
```

**Bug Investigation:**
```
/workflow:diagnose → Fix-in-Place (simple bugs)
                  → /workflow:beads → /workflow:execute (medium issues)
                  → /workflow:brainstorm (complex/systemic issues)
```

### Starting a Feature

```
/workflow:brainstorm I want to add user authentication
```

### Quick Reference

| Command | When to Use |
|---------|-------------|
| `/workflow:diagnose [symptom]` | Something is broken or behaving unexpectedly |
| `/workflow:brainstorm [idea]` | Starting a new feature |
| `/workflow:plan [feature]` | After design is approved |
| `/workflow:beads [feature]` | After plan is approved |
| `/workflow:execute [epic-id]` | After beads are approved |
| `/workflow:review` | After implementation complete |
| `/workflow:compound [topic]` | After review to capture learnings |

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

## OpenAI / Codex Integration

This repository is model-agnostic. The existing Claude Code plugin and marketplace workflow remain unchanged, and OpenAI/Codex support is provided as an additive integration layer.

### For Claude Code Users

Continue using the plugin exactly as documented above:
- `/plugin install workflow@dirkkok-skills`
- `templates/CLAUDE.md` and `templates/AGENTS.md`
- `/workflow:*` commands

No migration is required for Claude users.

### For OpenAI/Codex Users

Use these OpenAI-specific assets:

1. Load `templates/OPENAI_AGENT.md` as your system/agent instruction file.
2. Register OpenAI **function tools** from `openai/tools.json` (`type: "function"` format).
3. Optionally use `openai/bootstrap.ts` as a reference dispatcher implementation.

Quick validation:

```bash
node openai/validate-tools.mjs
```

The OpenAI/Codex workflow mirrors the same phases:
`diagnose → brainstorm → plan → beads → execute → review → compound`
with the same approval gates (`design approved`, `plan approved`, `beads approved`, etc.).

### OpenAI Docs Skill Mapping

The OpenAI tool `workflow_docs` is a docs-focused skill equivalent for operating under `docs/`:
- `find` searches recursively in `docs/`
- `summarize` returns a concise summary (and can optionally include full content)
- `update` overwrites a specific file under `docs/` (creating parent directories as needed)

This maps directly to the workflow documentation structure:
- `docs/designs`
- `docs/plans`
- `docs/learnings`

## Philosophy

- **Evidence-Driven Diagnosis**: Investigate with reproduction and evidence, not guesses
- **Adaptive Triage**: Right-size the response—simple bugs get quick fixes, complex issues get proper design
- **Documentation-First**: All phases produce permanent documentation
- **Intent Over Implementation**: Beads contain objectives, not source code
- **Surgical Context**: Each bead specifies exactly which files to read
- **Continuous Learning**: `/workflow:compound` captures learnings for future features
- **Explicit Approval**: Each phase requires user approval before proceeding

## License

MIT
