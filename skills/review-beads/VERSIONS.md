# Review-Beads Skill — Version History

## v2.9
Multi-agent flywheel alignment with beads v5.16. Phase 5: dependency edges must reflect compile-time necessity (not pattern sequence), transitive edge pruning, parallelism metrics (≥3 ready at start, critical path depth check). Category 7b: gate serialization check, hard vs soft gate classification. Category 8: `## Files (reservation globs)` section required. What NOT to Flag: intentionally minimized dependencies, soft checkpoint gates without br dep edges. CONVERGE: dependency minimization is intentional — adding unnecessary edges to match pattern table ordering is itself WRONG_DEPENDENCY.

## v2.8
Fixed stale /review+/simplify references in Phase 3 stage gate count table (was counting 3 gates per feature, now 1 test gate per feature). Fixed gate chain check in Phase 5 cross-bead consistency (was "/review → /simplify → test", now "impl → test gate → next phase").

## v2.7
Final production feedback from 15/15 modules. Verification fast path: removed ≤10 bead count threshold (>90% exists is sufficient regardless of count). Wave 1 only for non-greenfield >70%.

## v2.6
Consolidated feedback from 11 production runs. Gate prohibition refined: dangerous between sequential impl beads, defensible at phase boundaries before tests. Auto-downgrade: single module always STANDARD regardless of bead count (apply before loading). Verification Module fast path: skip Phases 2-3 for >90% exists ≤10 beads. Category applicability table by bead type. br comments pattern documented. From Audit, Organizations, Authentication, Identity Providers, Users reviews.

## v2.5
Consolidated feedback from 6 production runs. Do NOT delegate finding generation to agents (80% false positive rate — agents can't call br show). Verification Mode Phase 3 shortcut (skip decomposition tables). Non-CRUD granularity method (services, guards, components). Compact report default for 0-FAIL. False positive log section formalized. Auto-downgrade COMPREHENSIVE for <15 beads. Project-specific references removed (nxgn components, module names).

## v2.4
Production feedback from Roles review. /review+/simplify gates downgraded from FAIL to DECISION (older bead sets may have them — user decides removal). Compact report auto-selected when 0 FAILs. Non-greenfield granularity method noted (count verification beads from Implementation Status, not greenfield decomposition tables).

## v2.3
Category 7b aligned with beads v5.2+ — /review and /simplify gates prohibited (was required). Test/verify gate checks updated. Non-greenfield granularity method noted as needing different approach from greenfield decomposition tables. From Entitlements production review feedback.

## v2.2
Removed /review and /simplify gate checks — these gate types no longer exist in beads v5.2. Updated cross-bead consistency to check for test/verify gates and flag any /review or /simplify gates as findings (they break the pipeline).

## v2.1
Full-pipeline adversarial review fixes. FR acceptance criteria depth check (each Given/When/Then must map to a bead success criterion). Design Decision Coverage cross-reference (failure criteria must trace to design decisions, not be generic). From end-to-end pipeline review covering PRD→design→plan→beads→review-beads.

## v2.0
CONVERGE mode with progressive loading, cascade check, same-session detection, WARN triage. Severity model aligned to FAIL/WARN (was class-only). Finding classification now includes default severity per class. Authority hierarchy aligned with siblings. Non-greenfield bead review guidance (verification beads, modify beads). Token budget estimate. Compact report format. From adversarial review against review-prd v2.3, review-design v2.5, and review-plan v2.6.

## v1.0
Initial release. 11 review categories, 6-phase review process, severity calibration with examples, finding classification taxonomy, granularity decomposition with expected bead count derivation, FR/UC coverage matrices, stage gate analysis, batch execution support for multi-module reviews, anti-patterns.
