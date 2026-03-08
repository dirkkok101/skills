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

## Pipeline Overview

PRD, Design, and Plan are **separate skills with explicit stage gates**. Each requires user approval before proceeding to the next.

```
research ─> brainstorm ─> discovery ─> prd ─> technical-design ─> plan ─> beads ─> execute ─> review ─> compound
(optional)                 (COMP only)         (STANDARD+)
```

### Scope-Based Entry Points

Brainstorm classifies features as BRIEF, STANDARD, or COMPREHENSIVE using weighted signals:

| Scope | Path |
|-------|------|
| **BRIEF** | brainstorm → plan → beads → execute → review → compound |
| **STANDARD** | brainstorm → prd → technical-design → plan → beads → execute → review → compound |
| **COMPREHENSIVE** | brainstorm → discovery → prd → technical-design → plan → beads → execute → review → compound |
| **Bug fix** | diagnose → fix / beads / brainstorm |
| **Technical improvement** | brainstorm → technical-design → plan → beads → execute → review |

### Approval Gates

Each phase requires explicit user approval before proceeding:

| Phase | Exit Signal | Next Step |
|-------|-------------|-----------|
| research | "research complete" | brainstorm or prd |
| brainstorm | "start discovery" / "start prd" / "start plan" | discovery, prd, technical-design, or plan |
| discovery | "start prd" | prd |
| prd | "prd approved" | technical-design |
| technical-design | "design approved" | plan |
| plan | "plan approved" | beads |
| beads | "beads approved" | execute |
| execute | "done" | review |
| review | "changes approved" | compound |

## Quick Reference

| Command | When to Use |
|---------|-------------|
| `/workflow:research [topic]` | New problem space, need competitive/technical analysis |
| `/workflow:brainstorm [idea]` | Starting a new feature, exploring approaches |
| `/workflow:discovery [feature]` | After brainstorm for COMPREHENSIVE features |
| `/workflow:prd [feature]` | After brainstorm/discovery, need formal requirements |
| `/workflow:technical-design [feature]` | After PRD, need architecture and API specs |
| `/workflow:diagnose [symptom]` | Something is broken or behaving unexpectedly |
| `/workflow:plan [feature]` | After design is approved (or after brainstorm for BRIEF) |
| `/workflow:beads [feature]` | After plan is approved |
| `/workflow:execute [epic-id]` | After beads are approved |
| `/workflow:review` | After implementation complete |
| `/workflow:compound [topic]` | After review to capture learnings |

## Key Rules

- **Explicit approval** - Never proceed without user saying the magic words
- **Push before stopping** - Work is not complete until `git push` succeeds
- **Traceability** - FRs trace to UCs, UCs trace to personas, beads tag FRs, tests tag UCs

---

# Documentation Structure

```
your-project/
├── docs/
│   ├── research/       # Created by /research
│   ├── brainstorm/     # Created by /brainstorm
│   │   └── {feature}/brainstorm.md
│   ├── discovery/      # Created by /discovery (COMPREHENSIVE)
│   │   └── {feature}/discovery-brief.md
│   ├── prd/            # Created by /prd
│   │   └── {feature}/prd.md
│   ├── designs/        # Created by /technical-design
│   │   └── {feature}/design.md, architecture.md, api-spec.md, ...
│   ├── plans/          # Created by /plan
│   │   └── {feature}/overview.md, 01-data-model.md, ...
│   ├── reviews/        # Created by /review
│   │   └── review-{timestamp}.md
│   ├── learnings/      # Created by /compound
│   │   └── {category}.md
│   ├── reference/      # Project-specific reference docs (manual)
│   └── systems/        # Project-specific system docs (manual)
└── .beads/
    └── beads.db        # Created by br init
```

---

# Domain References

The workflow skills use domain reference files for domain-specific checklists and patterns:

| Domain | Reference | Used By |
|--------|-----------|---------|
| Identity/Auth | `_shared/references/identity-auth.md` | discovery, technical-design |
| Data Platform | `_shared/references/capstone-data.md` | discovery, technical-design |
| Mobile/EHS | `_shared/references/guardian-mobile.md` | discovery, technical-design |
| General SaaS | `_shared/references/general-saas.md` | discovery, technical-design |

Domain references are updated by /compound when domain-specific learnings are captured.

---

# Project-Specific Instructions

<!-- Add your project-specific instructions below -->
