# Feature Workflow Skills for Gemini CLI

This repository provides a collection of specialized Agent Skills for the Gemini CLI, designed to manage the entire software development lifecycle from bug diagnosis to feature implementation and documentation.

## Core Mandates

- **Scope-Routed SDLC**: Weighted complexity signals route features to BRIEF, STANDARD, or COMPREHENSIVE pipeline depths.
- **Domain-Aware Requirements**: Discovery skill walks domain-specific checklists for identity, data, mobile, and SaaS features.
- **Evidence-Driven Diagnosis**: Investigate with reproduction and evidence, not guesses.
- **Adaptive Triage**: Right-size the response—simple bugs get quick fixes, complex issues get proper design.
- **Documentation-First**: All phases produce permanent documentation in `docs/`.
- **Intent Over Implementation**: Beads contain objectives, not source code.
- **Requirement Traceability**: FRs trace from PRD through beads to review, with upstream verification.
- **Explicit Approval**: Each phase requires user approval before proceeding.

## Workflow Sequence

**BRIEF path:** brainstorm → plan → beads → execute → review → compound

**STANDARD path:** brainstorm → prd → technical-design → plan → beads → execute → review → compound

**COMPREHENSIVE path:** brainstorm → discovery → prd → technical-design → plan → beads → execute → review → compound

For bugs: diagnose → Fix-in-Place OR Handoff to Brainstorm/Beads.

## Standards

- **Files**: Follow the project standards defined in `GEMINI.md` and `templates/GEMINI.md`.
- **Tests**: Always verify implementation with tests before marking a bead as complete.
- **Code Style**: Adhere to the existing codebase patterns found during research.

## Skill Discovery

The Gemini CLI automatically discovers skills in this repository. Use `activate_skill` when relevant tasks are identified.
