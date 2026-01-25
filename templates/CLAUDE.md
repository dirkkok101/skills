# CLAUDE.md

@AGENTS.md

# Issue Tracking with Beads

This project uses **br** (beads-rust) for local issue tracking. The database lives at `.beads/beads.db` (SQLite-only, not synced to git).

## When to Use Beads vs TodoWrite

| Use Beads (`br`) | Use TodoWrite |
|------------------|---------------|
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

## Workflow Overview

```
/brainstorm → /plan → /beads → /execute → /review → /compound
       ↓                    ↓                 ↓                  ↓                  ↓                  ↓
  "design approved"   "plan approved"   "beads approved"      "done"        "changes approved"      "done"
```

## Quick Reference

| Phase | Skill | Output | Exit Signal |
|-------|-------|--------|-------------|
| 1 | `/brainstorm` | Design doc | "design approved" |
| 2 | `/plan` | Plan doc | "plan approved" |
| 3 | `/beads` | Beads | "beads approved" |
| 4 | `/execute` | Working code | "done" |
| 5 | `/review` | Findings | "changes approved" |
| 6 | `/compound` | Learnings | "done" |

## Key Rules

- **Explicit approval** - Never proceed without user saying the magic words
- **Push before stopping** - Work is not complete until `git push` succeeds

---

# Documentation Structure

The workflow skills create and use this structure:

```
your-project/
├── docs/
│   ├── designs/      # Created by /brainstorm
│   │   └── {feature}/
│   │       └── design.md
│   ├── plans/        # Created by /plan
│   │   └── {feature}/
│   │       ├── overview.md
│   │       └── 01-{component}.md
│   ├── learnings/    # Created by /compound
│   │   └── {category}.md
│   ├── reference/    # Your project's reference docs (optional)
│   └── systems/      # Your project's system docs (optional)
└── .beads/
    └── beads.db      # Created by br init
```

---

# Project-Specific Instructions

<!-- Add your project-specific instructions below -->
