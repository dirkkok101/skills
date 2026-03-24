# Discovery Skill — Version History

## v3.5
Prerequisites modernized from bash scripts to prose-based artifact import. Added docs/adr/ (as [CONSTRAINT]) and docs/patterns/ (as [PRIOR-ART]) to upstream imports. Collaborative model adds Phase 5 (Output). Exit signals table expanded with "When to Recommend" column. Version scheme aligned with pipeline.

## v3.4
PAUSE points replaced with AskUserQuestion stage gates — PAUSE 1 uses Guided Review (Pattern 5) for actors/workflows/risks, PAUSE 2 uses Batch Review (Pattern 3) for domain requirements, PAUSE 3 uses Combined Gate (Pattern 4) for completeness + routing.

## v3.3
Stage gate reference added.

## v3.2
Glossary extracted as standalone file (`glossary.md`) alongside brief — enables inheritance by PRD and technical-design. Glossary template supports disambiguation tables (multiple meanings per term) modelled on identity project's glossary. Brief references glossary via link instead of embedding.

## v3.1
Duration target, pre-mortem moved to Phase 1, glossary started early, domain depth prioritization, grounded checklist questions, focused STRIDE analysis, split Phase 3/3b, partial workflow option, kill criteria check in synthesis, readiness items requiring user confirmation flagged, generic questions anti-pattern added.
