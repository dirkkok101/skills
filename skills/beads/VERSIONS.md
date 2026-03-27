# Beads Skill — Version History

## v5.18
Production feedback from unified-rbac greenfield (74 beads, STANDARD mode). Infrastructure/cross-cutting decomposition section for non-entity-CRUD features — decompose by compilation units, not entity pattern tables. Proportional Phase 3 self-assessment scaling (≤20: full, 20-50: 30% sample, 50+: spot-check 10). Delegation pattern for >40 bead sets (Phase 0-1 main context, Phase 2 sub-agent, Phase 3 main context). Scope growth check clarified: always compare against sub-task count, 2x threshold for infrastructure features. From unified-rbac 64-bead greenfield run.

## v5.17
Production feedback from NuGet client v0.2 beads. Incremental bead creation mode (versioned beads.md, epic reuse, version-prefixed bead IDs). Test bead sizing relaxed for modification work (≤15 greenfield, ≤25 modification/verification). Context-aware Phase 0 (skip doc tree scan when upstream docs already loaded from prior skills). br ID capture guidance (batch query after creation, not inline parsing). From first multi-agent flywheel test run.

## v5.16
Multi-agent flywheel support. `## Files (reservation globs)` section in bead template for Agent Mail file reservation. Dependency minimization pass (Step 1.4b) prunes pattern-sequence edges to compile-order edges, widening parallel tracks (~4 tracks after Contracts instead of 1 deep chain). Backend decomposition table updated with compile-order dependencies. Hard gate vs soft checkpoint distinction — hard gates create `br dep add` edges, soft checkpoints are advisory notes (UI test gates, UC verify, module complete are soft). Parallelism + file reservation completeness checklists in Phase 3 self-assessment.

## v5.15
Role Templates + Sessions feedback. Non-greenfield approach must reference actual code paths (not design pseudocode). Frontend verification beads need explicit "verify or fix" policy. Schema migration generalized to any ORM.

## v5.14
Authentication feedback. Test bead sizing ≤15. Dependency validation. Contract change downstream consumers.

## v5.13
Entitlements + IdP feedback. Compilation unit check. Frontend beads coarser. Verification beads batchable.

## v5.12
Users feedback. Small feature slice grouping. EF migration in entity scope. E2E execution-context tagging.

## v5.11
Applications feedback. Context path validation via glob in Phase 3.

## v5.10
Languages feedback. "Exists" elements only get verification beads if gap analysis flags mismatches.

## v5.9
Organizations feedback. Verification bead template: test alignment in scope, Context to Load section added.

## v5.8
Context budget per bead by mode (5/8/12 files). Large bead splitting heuristic (>8 files or >3 patterns = mandatory split). Inspired by gstack's scope discipline patterns.

## v5.7
Production feedback from cross-cutting execution.

## v5.6
Consolidated feedback from 11 production runs. Scope growth check uses sub-task count, exempts Verification Mode. beads.md single source of truth. Remaining presentation triggers removed.

## v5.5
Consolidated feedback from 6 production runs. Verify "New" elements via glob before decomposing (plan can be stale). Scope growth check excludes gate beads. br correction protocol (## CORRECTION header for br comments add).

## v5.4
Production feedback round 2. Dry-run option: write beads.md first, create in br AFTER approval (prevents delete+recreate cycles). Lighter verification bead descriptions (checklist format, not full template). Gate scaling: skip UC/module verify for ≤10 impl beads in Verification Mode. Context efficiency: rely on plan tables, spot-check file paths only.

## v5.3
Production feedback from Entitlements run. Verification Mode fast path (>90% exists → map directly from plan, skip decomposition analysis, 1 verification bead per feature not per element). Checkpoint/resume for interrupted runs (detect existing beads, offer resume vs delete). Gate scaling for verification mode (lightweight gates when ≤10 impl beads). Context efficiency: rely on plan's coverage tables, spot-check source docs only.

## v5.2
Removed /review and /simplify gate beads — they treat code built for future beads as "dead code" and delete it, breaking the pipeline. Replaced with test gates only (test at feature boundaries, verify at UC and module boundaries). Run /review and /simplify AFTER epic completes when all code exists. PAUSE 1 simplified to summary + single approval (user can't evaluate individual beads in detail — /review-beads handles that). Gate overhead reduced: 2 test + 1 UC verify + 1 module verify per feature (was 6 review/simplify + 2 test per feature).

## v5.1
Full-pipeline adversarial review fixes. Hybrid mode (30-70%) decomposition instructions added. Verification beads for "Exists" elements at 70-90% (not just >90%). FR Coverage with acceptance criteria depth (ACs Covered column — Partial if any AC unaddressed). Design Decision Coverage table (verify every decision propagated as failure criteria). Decomposition Adaptation Algorithm for non-.NET projects (build from docs/patterns/ directory). Verification bead template added.

## v5.0
Plan integration — reads plan's FR/UC/Design Coverage tables and Implementation Status (gap analysis) BEFORE decomposition. Non-greenfield mode: >70% exists → gap-driven beads (Modify/New only, skip Exists). >90% exists → Verification Mode beads. Failure criteria propagated from plan's design decisions (not generic). UC gate beads verify scenario flows (not just code quality) with scenario steps from plan's UC Coverage table. Portability: decomposition tables are examples for .NET/Angular, adapt to your project's patterns. Auto-detect BRIEF gates for ≤5 beads / ≤3 tasks. First-bead module spec loading guidance. From adversarial review of beads + review-beads.

## v4.0
Phase 0 doc discovery — scans project docs tree to build a doc map instead of assuming hardcoded paths. Handles variance in project structure: flat vs nested patterns, decisions in adr/ or designs/{feature}/decisions/, numbered design prefixes, subfeature nesting. Decomposition tables use pattern keys resolved from the doc map. Gate beads load discovered decisions, architecture docs, and learnings into context. Pattern-granular decomposition — one bead per pattern artifact with Backend/Frontend/Test decomposition tables. Stage gate beads — `/review` + `/simplify` cycles at feature slice, use case, and module boundaries. Frontend beads depend on backend test gates, never on raw backend impl beads. Trust hierarchy for gate findings. Bead description format includes Pattern and Commit fields. Bead size heuristic rewritten around pattern alignment with grouping exceptions and never-combine rules. Bead count comparison showing impact.

## v3.5
Prerequisites expanded. Parallel Tracks corrected.

## v3.4
AskUserQuestion stage gates (removed in v5.2 — user cannot evaluate individual beads).

## v3.2
Review beads (REMOVED in v5.2 — /review and /simplify gates deleted preparatory code needed by future beads).

## v3.1
Duration targets, scope growth check, prose-based artifact import, self-review themes, language-neutral examples.
