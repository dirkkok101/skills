# GEMINI.md

@AGENTS.md

# Issue Tracking with Beads

This project uses **br** (beads-rust) for local issue tracking. The database lives at `.beads/beads.db` (SQLite-only, not synced to git).

## When to Use Beads vs Internal Todo

| Use Beads (`br`) | Use Internal Todo |
|------------------|-------------------|
| Multi-session work that persists | Single-session task breakdown |
| Work with dependencies/blockers | Simple sequential steps |
| Features, bugs, epics | Immediate execution checklist |
| Discovered work to capture for later | Progress visibility for current task |

## Session Start

```bash
br ready                  # See available work
```

## During Work

```bash
br update <id> --status in_progress   # Claim task
br create "Discovered issue" -p 2     # Capture discovered work
```

## Session End

```bash
br close <id>             # Complete finished work
git add . && git commit && git push   # Push code (MANDATORY)
```

---

# Feature Development Workflow

## CRITICAL: No Implementation Without Explicit Approval

**NEVER write implementation code until the user explicitly says "approved" or "implement".**

When asked to build a feature:
1. **STOP** - Do not write code
2. **Ask** - "Should we start with brainstorming, or is there an existing plan?"
3. **Use the workflow skills** - Each requires explicit user approval to proceed

## Pipeline Overview

```
research ─> brainstorm ─> discovery ─> prd ─> technical-design ─> plan ─> beads ─> execute ─> review ─> compound
(optional)                 (COMP only)                (STANDARD+)
```

### Scope-Based Entry Points

Brainstorm classifies features as BRIEF, STANDARD, or COMPREHENSIVE using weighted signals:

| Scope | Path |
|-------|------|
| **BRIEF** | brainstorm → plan → beads → execute → review → compound |
| **STANDARD** | brainstorm → prd → technical-design → plan → beads → execute → review → compound |
| **COMPREHENSIVE** | brainstorm → discovery → prd → technical-design → plan → beads → execute → review → compound |
| **Bug fix** | diagnose → fix / beads / brainstorm |

## Quick Reference

| Phase | Skill | Output | Exit Signal |
|-------|-------|--------|-------------|
| 1 | `brainstorm` | Design doc + scope | "start discovery" / "start prd" / "start plan" |
| 2 | `discovery` | Discovery brief | "start prd" |
| 3 | `prd` | Requirements doc | "prd approved" |
| 4 | `technical-design` | Architecture docs | "design approved" |
| 5 | `plan` | Implementation plan | "plan approved" |
| 6 | `beads` | Work packages | "beads approved" |
| 7 | `execute` | Working code | "done" |
| 8 | `review` | Findings | "changes approved" |
| 9 | `compound` | Learnings | "done" |

## Key Rules

- **Explicit approval** - Never proceed without user saying the magic words
- **Push before stopping** - Work is not complete until `git push` succeeds
- **Traceability** - FRs trace to UCs, beads tag FRs, tests tag UCs

---

# Documentation Structure

```
your-project/
├── docs/
│   ├── research/       # Created by research
│   ├── brainstorm/     # Created by brainstorm
│   ├── discovery/      # Created by discovery (COMPREHENSIVE)
│   ├── prd/            # Created by prd
│   ├── designs/        # Created by technical-design
│   ├── plans/          # Created by plan
│   ├── reviews/        # Created by review
│   ├── learnings/      # Created by compound
│   ├── reference/      # Project-specific reference docs (manual)
│   └── systems/        # Project-specific system docs (manual)
└── .beads/
    └── beads.db        # Created by br init
```

---

# Project-Specific Instructions

<!-- Add your project-specific instructions below -->
