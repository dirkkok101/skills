# Plan Review Checklists

Reference tables for `/review-plan` phases. The SKILL.md workflow drives when and how to apply these checklists.

---

## Phase 1: Structural Compliance (vs /plan skill spec)

### 1.1 Overview Document Structure

Verify the overview contains all required sections from the `/plan` skill spec:

| Required Section | BRIEF | STANDARD | COMPREHENSIVE |
|-----------------|-------|----------|---------------|
| References | Yes | Yes | Yes |
| Decomposition Strategy | Yes | Yes | Yes |
| Cross-Cutting Concerns | Yes | Yes | Yes |
| Task Summary table | Yes | Yes | Yes |
| FR Coverage table | Yes | Yes | Yes |
| UC Coverage table | No | Yes | Yes |
| Design Coverage table | No | Yes | Yes |
| Design Decision Coverage table | No | Yes | Yes |
| Implementation Status (non-greenfield) | No | If applicable | If applicable |
| Dependency Graph | No | Yes | Yes |
| Critical Path | No | Yes | Yes |
| Risk Register | No | No | Yes |
| Testing Summary | No | Yes | Yes |
| Sub-Plans table | No | Yes | Yes |

Flag missing required sections as **WARN** findings.

### 1.2 Sub-Plan Document Structure (STANDARD+)

For each sub-plan, verify required sections:
- Traceability (Implements, Design Reference, Validates Against)
- Prerequisites
- Objective
- Context
- Tasks (each with: Objective, Approach, Success Criteria)
- Component Success Criteria
- References

Verify conditional sections are present when applicable:
- Pseudocode (when design produced algorithmic detail)
- Contract Shapes (when task defines or modifies contracts)
- Pattern Reference (when established patterns exist)

Verify mandatory sections:
- Failure Criteria — REQUIRED for **implementation tasks**. Must include explicit "do NOT" guidance derived from design decisions and rejected alternatives. Flag missing Failure Criteria on implementation tasks as **WARN**. **Exception:** verification/audit tasks (tasks whose primary objective is confirming existing code matches a specification) may omit Failure Criteria — the success criteria checklist serves as the constraint.

Flag missing required sections as **WARN**. Flag missing conditional sections (when clearly applicable) as **Minor**.

### 1.3 Companion Document Compliance (COMPREHENSIVE)

If plan mode is COMPREHENSIVE, verify companion documents exist and contain required structure:
- `e2e-test-plan.md`: Scope, Environment, Smoke Checks, Critical Path Scenarios
- `security-hardening-checklist.md`: Priority tiers (0/1/2), Exit Criteria (skip if design says "no security implications")
- `test-scenario-matrix.md`: Summary metrics, UC-to-test mapping

Flag missing COMPREHENSIVE companion docs as **WARN**.

### 1.4 Anti-Pattern Detection

Check for each anti-pattern defined in the `/plan` skill spec:

| Anti-Pattern | Detection Signal | Severity |
|-------------|-----------------|----------|
| **Horizontal-Only Decomposition** | All tasks scoped to a single layer (all DB, then all API, then all UI) with no end-to-end slice | FAIL |
| **Deferred Risk** | High-risk or integration tasks appear only in late phases | WARN |
| **Testing as Phase N** | A dedicated "write tests" phase/task with no per-task test expectations. **Exception:** for non-greenfield plans where existing code has zero tests, a dedicated test task for pre-existing code is legitimate. | WARN |
| **200-Task Plan** | Excessive task count relative to feature scope; trivial tasks that should be merged | WARN |
| **Plan-as-Design** | Sub-plans make architectural decisions not present in the design (new patterns, new entities, new API shapes) | FAIL |
| **Copy-Paste Sub-Plans** | Large blocks of text duplicated verbatim from design docs instead of referenced | Minor |
| **Hollow Sub-Plans** | Sub-plans with only prose descriptions — no pseudocode, no contract shapes, no pattern references despite design having produced this detail | WARN |
| **Misaligned Decomposition** | Sub-plan grouping doesn't mirror the design's feature decomposition structure | WARN |

### 1.5 Plan/Beads Boundary Violations

Verify no sub-plan contains content that belongs in /beads:
- Compilable source code (not pseudocode)
- Commit messages or git workflow instructions
- File modification checklists (specific files to create/edit)
- Test commands or CI pipeline steps

Flag violations as **Minor** (they don't block /beads but indicate confusion about the boundary).
