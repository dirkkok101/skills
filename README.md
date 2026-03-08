# Feature Workflow Skills

A complete feature development workflow for Claude Code with structured SDLC phases, scope-based routing, and requirement traceability.

## Overview

| Command | Purpose | Output |
|---------|---------|--------|
| `/workflow:research` | Deep research before designing | `docs/research/{feature}/research-brief.md` |
| `/workflow:brainstorm` | Problem framing, approaches, scope classification | `docs/brainstorm/{feature}/brainstorm.md` |
| `/workflow:discovery` | Domain-aware requirements elicitation | `docs/discovery/{feature}/discovery-brief.md` |
| `/workflow:prd` | Tiered product requirements document | `docs/prd/{feature}/prd.md` |
| `/workflow:technical-design` | C4 architecture, API specs, data models | `docs/designs/{feature}/` |
| `/workflow:diagnose` | Bug investigation with root cause analysis | Fix, beads, or design handoff |
| `/workflow:plan` | Implementation plans (BRIEF or STANDARD mode) | `docs/plans/{feature}/overview.md` |
| `/workflow:beads` | Intent-based work packages with FR traceability | Beads in `br` database |
| `/workflow:execute` | Sub-agent implementation with upstream verification | Working code |
| `/workflow:review` | Parallel agent review with PRD compliance | Findings and fixes |
| `/workflow:compound` | Structured learning capture by phase/domain | `docs/learnings/{category}.md` |

> **Note:** All commands use the `workflow:` namespace prefix because this is a marketplace plugin.

## Workflow

```
research ─> brainstorm ─> discovery ─> prd ─> technical-design ─> plan ─> beads ─> execute ─> review ─> compound
(optional)                 (COMP only)                (STANDARD+)
```

### Scope-Based Routing

Brainstorm classifies features using weighted complexity signals (auth/security ×2, others ×1):

| Scope | Weighted Score | Pipeline Path |
|-------|---------------|---------------|
| **BRIEF** | 0-2 points | brainstorm → plan → beads → execute → review → compound |
| **STANDARD** | 3-4 points | brainstorm → prd → technical-design → plan → beads → execute → review → compound |
| **COMPREHENSIVE** | 5+ points | brainstorm → discovery → prd → technical-design → plan → beads → execute → review → compound |

### Other Entry Points

| Scenario | Path |
|----------|------|
| **Known requirements** | prd → technical-design → plan → beads → execute → review |
| **Technical improvement** | brainstorm → technical-design → plan → beads → execute → review |
| **Bug fix** | diagnose → fix / beads / brainstorm |

### Approval Gates

Each phase requires explicit user approval before proceeding:

| Phase | Exit Signal | Next Step |
|-------|-------------|----------|
| research | "research complete" | brainstorm or prd |
| brainstorm | "start discovery" / "start prd" / "start plan" | discovery, prd, technical-design, or plan |
| discovery | "start prd" | prd |
| prd | "prd approved" | technical-design |
| technical-design | "design approved" | plan |
| plan | "plan approved" | beads |
| beads | "beads approved" | execute |
| execute | "done" | review |
| review | "changes approved" | compound |

### Traceability Chain

```
PRD FR-{feature}-{NAME}
  → UC-{feature}-{NAME} (use case)
    → @UC-{feature}-{NAME} (BDD tag)
      → BEAD-{id} (implements FR, tags UC)
        → execute upstream verification
          → review PRD-compliance agent
```

## What's New in v2.0

- **Discovery skill** — Domain-aware requirements elicitation for complex features, with checklists for identity/auth, data platform, mobile/EHS, and general SaaS
- **Scope classifier** — Weighted signals automatically route features to the right pipeline depth
- **FR traceability** — Requirements trace from PRD through beads to review, with stable descriptive IDs
- **Upstream verification** — Execute verifies each bead against PRD acceptance criteria and design specs
- **PRD-compliance review agent** — 9th review agent checks Must-Have FR coverage and scope compliance
- **BRIEF plan mode** — Plan works without a design document for simple features
- **Tiered PRD** — BRIEF (50-100 lines), STANDARD (200-300), COMPREHENSIVE (400-500 with Cockburn use cases)
- **Domain references** — Shared checklists and patterns for identity-auth, capstone-data, guardian-mobile, general-saas

## Workflow

```
┌──────────┐   ┌───────────┐   ┌─────┐   ┌──────────────────┐
│ research │──▶│ brainstorm │──▶│ prd │──▶│ technical-design │
│(optional)│   │ (6 phases) │   │     │   │   (.NET/C#)      │
└──────────┘   └───────────┘   └─────┘   └──────────────────┘
                                                   │
                    ┌──────────────────────────────┘
                    ▼
              ┌──────┐   ┌───────┐   ┌─────────┐   ┌────────┐
              │ plan │──▶│ beads │──▶│ execute │──▶│ review │
              └──────┘   └───────┘   └─────────┘   └────────┘
                                                        │
                                                   ┌────┘
                                                   ▼
                                              ┌──────────┐
                                              │ compound │
                                              └──────────┘
```

### Entry Points by Complexity

| Scenario | Path |
|----------|------|
| **Full SDLC** | research → brainstorm → prd → technical-design → plan → beads → execute → review → compound |
| **Known requirements** | prd → technical-design → plan → beads → execute → review |
| **Technical improvement** | brainstorm → technical-design → plan → beads → execute → review |
| **Simple change** | brainstorm → plan → beads → execute → review |
| **Bug fix** | diagnose → fix / beads / brainstorm |

### Approval Gates

Each phase requires explicit user approval before proceeding:

| Phase | Exit Signal | Next Step |
|-------|-------------|----------|
| research | "research complete" | brainstorm or prd |
| brainstorm | "start prd" / "start technical-design" / "start plan" | prd, technical-design, or plan |
| prd | "prd approved" | technical-design |
| technical-design | "design approved" | plan |
| plan | "plan approved" | beads |
| beads | "beads approved" | execute |
| execute | "done" | review |
| review | "changes approved" | compound |

## Prerequisites

This skill library assumes your Claude Code environment has global tooling configured via `~/.claude/CLAUDE.md` and `~/AGENTS.md`. These provide the tool instructions that skills reference conditionally (issue tracking, session search, knowledge base).

**Required:** `br` (beads-rust), `rtk` (token optimization)
**Recommended:** `bv` (beads-viewer), `cass` (session search), `qmd` (knowledge base)
**Optional:** `agent-browser` (browser automation for UI work)

See [`skills/_shared/prerequisites.md`](skills/_shared/prerequisites.md) for full details on each tool and how skills reference them.

## Installation

### Step 1: Install br (beads-rust) CLI

```bash
cargo install beads-rust
br version
```

### Step 2: Install the Plugin

```bash
# Add marketplace
/plugin marketplace add dirkkok101/skills

# Install plugin
/plugin install workflow@dirkkok-skills
```

### Step 3: Set Up Your Project

```bash
cd your-project
br init
```

Copy template files:

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
    ├── research/       # /workflow:research
    ├── brainstorm/     # /workflow:brainstorm
    ├── discovery/      # /workflow:discovery (COMPREHENSIVE)
    ├── prd/            # /workflow:prd
    ├── designs/        # /workflow:technical-design
    ├── plans/          # /workflow:plan
    ├── reviews/        # /workflow:review
    └── learnings/      # /workflow:compound
```

## Usage

### Full SDLC (COMPREHENSIVE Feature)

```
/workflow:research user authentication options
→ "research complete"

/workflow:brainstorm I want to add user authentication
→ Scope: COMPREHENSIVE (auth ×2 + multiple roles ×1 + regulatory ×2 = 5)
→ "start discovery"

/workflow:discovery user authentication
→ "start prd"

/workflow:prd user authentication
→ "prd approved"

/workflow:technical-design user authentication
→ "design approved"

/workflow:plan user authentication
→ "plan approved"

/workflow:beads user authentication
→ "beads approved"

/workflow:execute
→ /workflow:review
→ /workflow:compound
```

### Quick Change (BRIEF Feature)

```
/workflow:brainstorm add sorting to the user list
→ Scope: BRIEF (1 signal: UI-heavy = 1 point)
→ "start plan"

/workflow:plan user list sorting
→ "plan approved"

/workflow:beads user list sorting
→ ...
```

### Bug Investigation

```
/workflow:diagnose users can't log in after password reset
→ Fix-in-Place (simple bugs)
→ /workflow:beads (medium issues)
→ /workflow:brainstorm (complex/systemic issues)
```

## Domain References

Skills load domain-specific checklists and patterns from shared references:

| Domain | Reference File | Used By |
|--------|---------------|---------|
| Identity/Auth | `_shared/references/identity-auth.md` | discovery, technical-design |
| Data Platform (Capstone) | `_shared/references/capstone-data.md` | discovery, technical-design |
| Mobile/EHS (Guardian) | `_shared/references/guardian-mobile.md` | discovery, technical-design |
| General SaaS | `_shared/references/general-saas.md` | discovery, technical-design |

Domain references are updated by `/workflow:compound` when domain-specific learnings are captured.

## Updating the Plugin

### Check Your Version

Run `/plugin` → **Installed** tab. You should see version **2.0.0** or higher.

### Update to Latest

```bash
claude plugin update workflow@dirkkok-skills
```

### Enable Auto-Updates (Recommended)

1. Run `/plugin` → **Marketplaces** tab → `dirkkok-skills` → **Enable auto-update**

## OpenAI / Codex Integration

This repository is model-agnostic. Claude Code plugin and marketplace workflow remain unchanged. OpenAI/Codex support is provided as an additive integration layer.

### For Claude Code Users

Continue using the plugin as documented above. No migration required.

### For OpenAI/Codex Users

1. Load `templates/OPENAI_AGENT.md` as your system/agent instruction file
2. Register OpenAI function tools from `openai/tools.json`
3. Optionally use `openai/bootstrap.ts` as a reference dispatcher

```bash
node openai/validate-tools.mjs
```

## Gemini CLI Integration

1. Install: `gemini extensions install https://github.com/dirkkok101/skills`
2. Copy templates: `templates/GEMINI.md` → `your-project/GEMINI.md`
3. Gemini CLI automatically discovers and activates skills

## Philosophy

- **Scope-Routed SDLC** — Weighted signals route features to the right pipeline depth
- **Domain-Aware** — Shared checklists and patterns for identity, data, mobile, and SaaS domains
- **Traceable** — Requirements trace from PRD through design, plan, beads, and review
- **Documentation-First** — All phases produce permanent documentation
- **Intent Over Implementation** — Beads contain objectives, not source code
- **Surgical Context** — Each bead specifies exactly which files to read
- **Upstream Fidelity** — Execute and review verify implementation matches what was specified
- **Continuous Learning** — `/workflow:compound` captures learnings by phase and domain
- **Explicit Approval** — Each phase requires user approval before proceeding
- **.NET/C# Native** — Technical design produces ASP.NET Core patterns

## License

MIT
