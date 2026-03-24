# Plan Skill — Version History

## v4.3
Design Decision Coverage table added to overview — every decision from decisions/*.md must appear as failure criteria in at least one sub-plan. Unpropagated decisions are blocking. From full-pipeline adversarial review.

## v4.2
Production feedback from Approvals, Identity Providers, Users runs. Verification Mode clarified for non-trivial remaining work (>90% exists but 3+ distinct gaps). Gap analysis agent partitioning by layer (data/backend/contracts/frontend/cross-cutting). Agent absence claim verification required. Re-planning file cleanup explicit (list + remove old files). PAUSE 1 always shows FR Coverage inline. Test mapping precision (mark approximate with ~). Companion doc overwrite handling.

## v4.1
Gap analysis Step 1.0b. No Explore agents for gap analysis. Re-planning guidance. PAUSE 1 inline artifacts. Test coverage first-class.

## v4.0
Verification Mode (>90% exists). Gap analysis as single source of truth. Design Feedback section. Agent efficiency. PAUSE 1 lighter for non-greenfield.

## v3.9
Failure Criteria exemption for verification/audit tasks.

## v3.8
Production feedback from 3 runs (Entitlements, Applications, Roles). Non-greenfield fast path: run gap analysis FIRST (Step 1.1), reorder Phase 1 when >70% exists. Gap-driven decomposition strategy added. Structured gap analysis checklist (entity, contract, command, query, endpoint, frontend — use Grep/Glob not Explore agents). Task sizing table for modifications (pattern replacement/field addition/behavioral change/architecture change). Scope-excluded UC handling (not a blocker). PAUSE 1 adaptive: single gate for ≤8 tasks, multi-step for >8. Companion docs scope-aware for non-greenfield. Failure criteria extraction from decision records/*.md with step-by-step process.

## v3.7
Adversarial review fixes. UC Coverage Ordering column, Tier 1 blockers, failure criteria extraction, gap analysis always required, PAUSE 1 validates all 3 coverage tables.

## v3.6
UC Coverage table (Step 1.4b), Design Coverage Matrix (Step 1.4c), Implementation Gap Analysis (Step 1.4d), mandatory Failure Criteria.

## v3.5
Prerequisites expanded with use cases, browser E2E plans, ADRs, and patterns paths. Phase 3b added to collaborative model. BRIEF skip list made explicit. ASCII conventions path corrected.

## v3.4
AskUserQuestion stage gates. PAUSE 1 uses Guided Review Workflow (Pattern 5) with Batch Review for task validation, Decision Gate for FR coverage, and Decision Gate for ordering. PAUSE 2 uses Decision Gate (Pattern 1) for plan approval. Fallback to prose-based patterns when AskUserQuestion is unavailable.

## v3.3
Companion documents for COMPREHENSIVE plans: e2e-test-plan.md (acceptance-level E2E scenarios), security-hardening-checklist.md (operationalized security findings with priority tiers), test-scenario-matrix.md (UC → test class living mapping). Dependency graph diagram for complex plans. All patterns validated against AMPS actions project (17 sub-plans + 3 companion docs).

## v3.2
Plan/beads boundary shifted — sub-plans now include pseudocode (algorithmic intent), contract shapes, failure criteria, and pattern references. Sub-plan template restructured with Tasks/Objective/Approach/Pseudocode/Contract Shapes sections (modelled on identity project's plans). Feature decomposition alignment — sub-plans mirror design's feature structure. Updated self-review Theme 6 for new boundary. Hollow Sub-Plans and Misaligned Decomposition anti-patterns added.

## v3.1
Duration targets, kill criteria check before decomposition, prose-based artifact import (no hardcoded shell), self-review moved before user presentation (merged PAUSE 2+3), structured PAUSE response options, conditional issue tracker for uncovered FRs, overview reconciliation after sub-plans, plan/beads boundary check in self-review, concrete pattern guidance in sub-plans, anti-patterns explain WHY.
