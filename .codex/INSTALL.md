# Installing Workflow Skills for Codex

## Prerequisites

- [br (beads-rust)](https://crates.io/crates/beads-rust) CLI for task management
- Git

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/dirkkok101/skills.git ~/workflow-skills
```

### 2. Symlink skills into the Codex agents directory

Codex discovers skills from `~/.agents/skills/`. Create a symlink:

```bash
mkdir -p ~/.agents/skills
ln -sf ~/workflow-skills/skills ~/.agents/skills/workflow
```

### 3. Copy the AGENTS.md template (optional)

If your project doesn't have an AGENTS.md yet:

```bash
cp ~/workflow-skills/templates/AGENTS.md ~/your-project/AGENTS.md
```

Edit to add project-specific instructions.

### 4. Initialize beads in your project

```bash
cd ~/your-project
br init    # WARNING: destructive on existing workspaces — only for NEW projects
br version
```

## Skill Discovery

Codex matches skills by their `name` and `description` in SKILL.md frontmatter. All skills use the `workflow:` namespace prefix (e.g., `workflow:brainstorm`, `workflow:execute`).

## Updating

```bash
cd ~/workflow-skills
git pull origin main
```

The symlink ensures Codex picks up changes immediately.
