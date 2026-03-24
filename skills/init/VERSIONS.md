# Init Skill — Version History

## v3.6
Minimal scaffold — init now creates only 6 foundational directories (prd, designs, architecture, patterns, adr, learnings). Remaining 9 directories (research, brainstorm, discovery, use-cases, plans, reviews, reference, browser-e2e-plans, diagnosis) are created on demand by each skill. Philosophy updated. CLAUDE.md template split into foundations vs on-demand tables. Phase 3 tree simplified.

## v3.5
Removed docs/decisions/ (compound now uses docs/adr/). Updated docs/adr/ attribution to reflect both /technical-design and /compound. Added docs/patterns/ and docs/browser-e2e-plans/ to Phase 3 tree diagram. Updated docs/patterns/ description to include /plan and /review as consumers. Version scheme aligned with pipeline.

## v1.1
Adversarial review fixes. Added 4 missing directories (reviews, adr, decisions, architecture). Fixed nested code fence rendering (pipeline uses indented block). Fixed BRIEF pipeline routing to match brainstorm skill (skips prd and technical-design). Added .claude/CLAUDE.md location detection. Improved idempotency to check both markers and handle corrupt state. Clarified COMPREHENSIVE-only directories in table descriptions.

## v1.0
Initial release. Eager folder creation, CLAUDE.md workflow section with markers, tech stack detection and warning, idempotent design.
