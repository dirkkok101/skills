# OPENAI_AGENT.md

@AGENTS.md

# OpenAI/Codex Agent Instructions

This file is for OpenAI-compatible agents (including Codex) running this workflow.
It is additive to existing Claude Code support and does not replace `CLAUDE.md`.

---

# Issue Tracking with Beads

Use **br** (beads-rust) for persistent issue tracking and dependency management.
The local database lives at `.beads/beads.db`.

## When to Use Beads vs Session Task Lists

| Use Beads (`br`) | Use Session Task Lists |
|------------------|------------------------|
| Multi-session work that must persist | Single-session tactical checklist |
| Work with blockers/dependencies | Small linear steps |
| Features, bugs, epics | Temporary execution tracking |
| Capturing discovered follow-up work | Real-time progress visibility |

## Session Start

```bash
br ready
```

## During Work

```bash
br update <id> --status in_progress
br create "Discovered follow-up" -p 2
```

## Session End

```bash
br close <id>
git add . && git commit && git push
```

---

# Workflow With Approval Gates

## Critical Rule

Do not write implementation code until the user explicitly approves progression.

When asked to build a feature:
1. Stop implementation work.
2. Confirm current phase and expected next phase.
3. Use the workflow sequence below with explicit gates.

## Scope-Based Routing

Brainstorm classifies features using weighted complexity signals:

| Scope | Path |
|-------|------|
| **BRIEF** (0-2 pts) | brainstorm → plan → beads → execute → review → compound |
| **STANDARD** (3-4 pts) | brainstorm → prd → technical-design → plan → beads → execute → review → compound |
| **COMPREHENSIVE** (5+ pts) | brainstorm → discovery → prd → technical-design → plan → beads → execute → review → compound |

## Phase Outputs and Exit Signals

| Phase | Tool | Primary Output | Required Exit Signal |
|-------|------|----------------|----------------------|
| 1 | `workflow_diagnose` | Root cause + triage path | User confirms next path |
| 2 | `workflow_brainstorm` | `docs/brainstorm/{feature}/brainstorm.md` | "start discovery" / "start prd" / "start plan" |
| 3 | `workflow_discovery` | `docs/discovery/{feature}/discovery-brief.md` | "start prd" |
| 4 | `workflow_prd` | `docs/prd/{feature}/prd.md` | `prd approved` |
| 5 | `workflow_plan` | `docs/plans/{feature}/overview.md` (+ sub-plans) | `plan approved` |
| 6 | `workflow_beads` | Beads created in `br` with FR tags | `beads approved` |
| 7 | `workflow_execute` | Working code + upstream verification | `done` |
| 8 | `workflow_review` | Findings with PRD compliance | `changes approved` |
| 9 | `workflow_compound` | Learning entry in `docs/learnings/` | `done` |

---

# Documentation Structure

Workflow documentation is stored under the project root `docs/` directory:

```text
docs/
├── research/     # Deep investigation briefs
├── brainstorm/   # Problem framing and approach selection
├── discovery/    # Domain-aware requirements (COMPREHENSIVE)
├── prd/          # Product requirements documents
├── designs/      # Technical design and architecture
├── plans/        # Implementation plans and sub-plans
├── reviews/      # Code review summaries
└── learnings/    # Compound learning capture
```

Use the docs workflow tool for documentation operations under `docs/`:
- `find` to discover docs files
- `summarize` to inspect a specific doc
- `update` to overwrite a doc safely

---

# Execution Expectations

- Prefer evidence over assumptions.
- Keep docs and beads aligned with actual implementation status.
- Use `br` for persistent workflow state, not ad hoc memory.
- Keep changes scoped and verifiable.
- Do not bypass approval gates.

---

# Project-Specific Instructions

<!-- Add project-specific OpenAI/Codex guidance below -->
