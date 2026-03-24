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

```bash
mkdir -p ~/.agents/skills
ln -sf ~/workflow-skills/skills ~/.agents/skills/workflow
ln -sf ~/workflow-skills/skills/_shared ~/.agents/skills/workflow/_shared
```

### 3. Copy the agent instruction template

```bash
cp ~/workflow-skills/templates/OPENAI_AGENT.md ~/your-project/AGENTS.md
```

Edit `AGENTS.md` to add any project-specific instructions in the marked section at the bottom.

### 4. Register OpenAI function tools (optional)

If your Codex setup uses function tool definitions:

```bash
cp ~/workflow-skills/openai/tools.json ~/your-project/.codex/tools.json
```

Validate the tool definitions:

```bash
node ~/workflow-skills/openai/validate-tools.mjs
```

### 5. Initialize beads in your project

```bash
cd ~/your-project
br init
br version
```

## Skill Namespace

All skills use the `workflow:` namespace prefix:

| Command | Purpose |
|---------|---------|
| `workflow:init` | Initialize project docs structure |
| `workflow:research` | Deep research before designing |
| `workflow:brainstorm` | Problem framing and scope classification |
| `workflow:discovery` | Domain-aware requirements (COMPREHENSIVE) |
| `workflow:prd` | Tiered product requirements document |
| `workflow:technical-design` | Architecture, API specs, data models |
| `workflow:plan` | Implementation plans with companion docs |
| `workflow:beads` | Intent-based work packages with FR traceability |
| `workflow:execute` | Sub-agent implementation with verification |
| `workflow:review` | Parallel agent review with alignment audits |
| `workflow:review-prd` | Adversarial PRD review |
| `workflow:review-design` | Adversarial design review |
| `workflow:review-plan` | Adversarial plan review |
| `workflow:review-beads` | Adversarial bead compliance review |
| `workflow:review-execute` | Post-execution bead satisfaction verification |
| `workflow:compound` | Structured learning capture |
| `workflow:diagnose` | Bug investigation with root cause analysis |
| `workflow:qa` | Browser-based QA with diff-aware scoping |
| `workflow:benchmark` | Performance benchmarking with regression detection |
| `workflow:security-audit` | OWASP + STRIDE zero-noise security audit |
| `workflow:ship` | Release pipeline: changelog, PR, traceability |

## Pipeline

```
brainstorm -> [discovery] -> [prd] -> [technical-design] -> plan -> beads -> execute -> review -> ship
```

Scope-based routing determines which optional phases are included:
- **BRIEF** (0-2 points): brainstorm -> plan -> beads -> execute -> review
- **STANDARD** (3-4 points): brainstorm -> prd -> technical-design -> plan -> beads -> execute -> review
- **COMPREHENSIVE** (5+ points): brainstorm -> discovery -> prd -> technical-design -> plan -> beads -> execute -> review

## Updating

```bash
cd ~/workflow-skills
git pull origin main
```

The symlink ensures Codex picks up changes immediately.
