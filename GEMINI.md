# Feature Workflow Skills for Gemini CLI

This repository provides a collection of specialized Agent Skills for the Gemini CLI, designed to manage the entire software development lifecycle from bug diagnosis to feature implementation and documentation.

## Core Mandates

- **Evidence-Driven Diagnosis**: Investigate with reproduction and evidence, not guesses.
- **Adaptive Triage**: Right-size the response—simple bugs get quick fixes, complex issues get proper design.
- **Documentation-First**: All phases produce permanent documentation in `docs/`.
- **Intent Over Implementation**: Beads contain objectives, not source code.
- **Surgical Context**: Each bead specifies exactly which files to read.
- **Continuous Learning**: Use the `/compound` skill to capture learnings.
- **Explicit Approval**: Each phase (Design, Plan, Beads) requires user approval before proceeding.

## Workflow Sequence

1. **Brainstorm**: `brainstorm [idea]` → `design approved`
2. **Plan**: `plan [feature]` → `plan approved`
3. **Beads**: `beads [feature]` → `beads approved`
4. **Execute**: `execute [epic-id]`
5. **Review**: `review`
6. **Compound**: `compound [topic]`

For bugs:
1. **Diagnose**: `diagnose [symptom]` → Simple Fix OR Handoff to Brainstorm/Beads.

## Standards

- **Files**: Follow the project standards defined in `GEMINI.md` and `templates/GEMINI.md`.
- **Tests**: Always verify implementation with tests before marking a bead as complete.
- **Code Style**: Adhere to the existing codebase patterns found during research.

## Skill Discovery

The Gemini CLI automatically discovers skills in this repository. Use `activate_skill` when relevant tasks are identified.
