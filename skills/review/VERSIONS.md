# Review Skill — Version History

## v3.7
MECHANICAL/JUDGMENT finding classification — auto-fix mechanicals, batch judgment calls for user. Diff-size scaling alongside file count for mode selection. AI slop detection in code-reviewer agent. Agent output cap (15 findings max). Consolidation failure recovery protocol. Inspired by gstack's fix-first and adversarial scaling patterns.

## v3.6
ADR consistency check added to design-intent agent — when changed files include new/modified ADRs, agent reads all existing ADRs and flags contradictions (criticality 8-10). Prevents ADR conflicts from slipping through review.

## v3.5
Design-intent agent scopes feature subdirs. Plan-intent agent receives patterns path. Consolidation agent uses ${PROJECT_ROOT} path. Browser E2E plans noted in upstream doc check and pr-test-analyzer. Cherry-pick option added to findings decision gate. Phase 4 cherry-pick workflow with Batch Review for Should Consider items.

## v3.4
AskUserQuestion stage gates at Phase 4 (findings decision) and Phase 6 (review cycle decision) using Decision Gate (Pattern 1) and Batch Review (Pattern 3) patterns from `../_shared/references/stage-gates.md`.

## v3.2
Alignment audit agent for COMPREHENSIVE mode — produces permanent `docs/reference/alignment-audit.md` with systematic PRD ↔ Design ↔ Plan ↔ Patterns cross-verification. Modelled on AMPS actions project's alignment audit (found 11 critical, ~30 medium, ~25 low issues across ~30 files).

## v3.1
Duration targets, BRIEF mode skips consolidation agent, agent failure/timeout recovery with health check, kill criteria added to plan-intent and prd-compliance agent prompts, self-review step before committing fixes, removed duplicate Quality Standards section, structured PAUSE response options, removed Phase 7 learning identification (handled by execute re-entry and compound), commit format deferred to CLAUDE.md, anti-patterns explain WHY.
