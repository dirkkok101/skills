# Workflow Skills

A complete feature development workflow for AI coding agents. Structured SDLC phases, scope-based routing, and requirement traceability from PRD through to shipped code.

Works with **Claude Code**, **Cursor**, **Codex**, **OpenCode**, and **Gemini CLI**.

## Quick Start

### Claude Code / Cursor

```bash
/plugin install workflow@dirkkok-skills
```

### Codex

```bash
git clone https://github.com/dirkkok101/skills.git ~/.codex/workflow-skills
ln -s ~/.codex/workflow-skills/skills ~/.agents/skills/workflow
```

### Gemini CLI

```bash
gemini extensions install https://github.com/dirkkok101/skills
```

### OpenCode

See [`.opencode/plugins/workflow.js`](.opencode/plugins/workflow.js).

### Initialize Your Project

```
/workflow:init
```

## Skills

| Command | When to Use |
|---------|-------------|
| `/workflow:init` | Starting a new project, setting up docs structure |
| `/workflow:research` | Need competitive analysis, landscape review, prior art |
| `/workflow:brainstorm` | New feature idea, exploring approaches |
| `/workflow:discovery` | Complex feature requiring deep domain requirements |
| `/workflow:prd` | Writing formal product requirements |
| `/workflow:technical-design` | Architecture, API specs, data models |
| `/workflow:plan` | Breaking design into implementation tasks |
| `/workflow:beads` | Creating work packages from approved plan |
| `/workflow:execute` | Implementing from approved beads |
| `/workflow:review` | Multi-agent code review after implementation |
| `/workflow:review-prd` | Quality gate between PRD and design |
| `/workflow:review-design` | Quality gate between design and plan |
| `/workflow:review-plan` | Quality gate between plan and beads |
| `/workflow:review-beads` | Quality gate between beads and execute |
| `/workflow:review-execute` | Post-execution bead satisfaction verification |
| `/workflow:qa` | Browser-based QA testing |
| `/workflow:benchmark` | Performance benchmarking |
| `/workflow:security-audit` | OWASP + STRIDE security audit |
| `/workflow:ship` | Create PR with changelog and traceability |
| `/workflow:compound` | Capture learnings for future sessions |
| `/workflow:diagnose` | Bug investigation and root cause analysis |
| `/workflow:autoresearch` | Automated document quality convergence |

## Pipeline

```
research ─> brainstorm ─> discovery ─> prd ─> technical-design ─> plan ─> beads ─> execute
(optional)                 (COMP only)

  execute ─> qa ─> benchmark ─> review ─> review-execute ─> security-audit ─> ship ─> compound
             (opt)   (opt)                                      (opt)
```

Quality gates (`review-*`) are optional between pipeline stages.

### Scope-Based Routing

Brainstorm classifies features and routes to the right pipeline depth:

| Scope | Pipeline |
|-------|----------|
| **BRIEF** (0-2 pts) | brainstorm → plan → beads → execute → review → ship |
| **STANDARD** (3-4 pts) | brainstorm → prd → technical-design → plan → beads → execute → review → ship |
| **COMPREHENSIVE** (5+ pts) | brainstorm → discovery → prd → technical-design → plan → beads → execute → review → ship |

### Other Entry Points

| Scenario | Path |
|----------|------|
| Known requirements | prd → technical-design → plan → beads → execute → review → ship |
| Technical improvement | brainstorm → technical-design → plan → beads → execute → review → ship |
| Bug fix | diagnose → fix / beads / brainstorm |
| Pre-release check | qa → benchmark → review → security-audit → ship |

## Key Concepts

**Traceability Chain** — Requirements trace from PRD → Design → Plan → Beads → Execute → Review. Each phase references upstream artifacts by stable FR IDs.

**Intent Over Implementation** — Beads carry objectives and acceptance criteria, not code. The executing agent writes code from codebase patterns.

**Surgical Context** — Each bead specifies exactly which files to read. Context resets between beads to prevent drift.

**Self-Regulation** — Execute and QA track cumulative risk scores. High scores trigger PAUSE or STOP to prevent doing more harm than good.

**CONVERGE Mode** — Review skills auto-fix mechanical findings and re-review until 0 FAILs or convergence. Judgment calls are escalated to the user.

**Stage Gates** — Every phase pauses for user approval via `AskUserQuestion` before proceeding. Five interaction patterns: Decision Gate, Comparison, Batch Review, Guided Review, Combined.

## Project Structure After Init

```
your-project/
├── CLAUDE.md
├── .beads/beads.db
└── docs/
    ├── prd/           # Requirements
    ├── designs/       # Technical design
    ├── plans/         # Implementation plans
    ├── execution/     # Execute manifests
    ├── reviews/       # Review reports
    ├── learnings/     # Compound learnings
    ├── adr/           # Architecture decisions
    ├── patterns/      # Coding patterns
    └── architecture/  # System architecture
```

## Prerequisites

**Required:** `br` (beads-rust) — local issue tracking for beads

```bash
cargo install beads-rust
```

**Optional:** `agent-browser` for QA skill, project-level tools configured in your CLAUDE.md.

## Running Tests

```bash
bash tests/run-all.sh
```

Tests verify CSO compliance (descriptions are trigger-only), structural integrity (frontmatter, versions, no project-specific refs), and reference link validity.

## Philosophy

- **Scope-Routed** — Weighted signals route features to the right pipeline depth
- **Traceable** — FR IDs chain through every phase from PRD to PR
- **Documentation-First** — All phases produce permanent docs
- **Intent Over Implementation** — Beads contain objectives, not source code
- **Stack-Agnostic** — Skills work with any tech stack
- **Continuous Learning** — `/compound` captures learnings for future sessions

## License

MIT
