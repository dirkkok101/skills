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

## Workflow Sequence

```
workflow_diagnose  -> diagnose output triage
workflow_brainstorm -> "design approved"
workflow_plan       -> "plan approved"
workflow_beads      -> "beads approved"
workflow_execute    -> "done"
workflow_review     -> "changes approved"
workflow_compound   -> "done"
```

## Phase Outputs and Exit Signals

| Phase | Tool | Primary Output | Required Exit Signal |
|-------|------|----------------|----------------------|
| 1 | `workflow_diagnose` | Root cause + triage path | User confirms next path |
| 2 | `workflow_brainstorm` | `docs/designs/{feature}/design.md` | `design approved` |
| 3 | `workflow_plan` | `docs/plans/{feature}/overview.md` (+ sub-plans) | `plan approved` |
| 4 | `workflow_beads` | Beads created in `br` | `beads approved` |
| 5 | `workflow_execute` | Working code + tests | `done` |
| 6 | `workflow_review` | Findings and proposed fixes | `changes approved` |
| 7 | `workflow_compound` | Learning entry in `docs/learnings/` | `done` |

---

# Documentation Structure

Workflow documentation is stored under the project root `docs/` directory:

```text
docs/
├── designs/      # Brainstorm/design outputs
├── plans/        # Implementation plans and sub-plans
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
