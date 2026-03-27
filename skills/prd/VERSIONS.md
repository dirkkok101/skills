# PRD Skill — Version History

## v3.10
Reference persona format added. Personas with read-only involvement (dashboards, reports, notifications) can use lightweight `### P{n}: {Role} (Reference)` format with a link to the project personas doc and a 1-line module interaction note, instead of the full 6-field definition. Prevents generic boilerplate for dashboard consumers.

## v3.9
Table-compatible assumption/constraint format. `**A{n}:**` and `**C{n}:**` prefixes now accepted in both bullet format and as the first column of a table with Impact/Validate columns. Table format preferred for STANDARD+ when assumptions carry significant risk — preserves context that bullets lose.

## v3.8
Seven improvements from COMPREHENSIVE BFF NuGet package PRD feedback. (1) Consumer Research step (Phase 0.3) — for shared libraries/packages, identifies consuming projects and reads their integration expectations before drafting requirements. (2) Adaptive FR review pacing — after 3 consecutive approvals, offers batch mode for remaining FRs. (3) Package API Contract variant for Phase 8b — replaces microservices table format with public API surface, consumer integration pattern, and consumer responsibilities for library PRDs. (4) Self-review reduced from "2 consecutive clean rounds" to "1 thorough round + fix + re-check fixes only". (5) Cross-PRD Alignment step in Phase 9 — when Depends On references another PRD, enforces mapping of parent FR acceptance criteria to child FRs. (6) Adaptive pause density — after 3+ consecutive approvals without revision, offers to consolidate remaining gates. (7) Library & Package PRD variant — alongside Policy PRDs, covers the developer-as-persona, integration-scenario use cases, and package-specific NFR lens.

## v3.7
Depends On field added to metadata template. Policy & Standards PRDs guidance added — handles PRDs for shared concerns that don't map to a single module (lighter personas, fewer use cases, policy-as-NFR pattern). Derived from applying the skill across 14 PRDs and identifying edge cases.

## v3.6
Structural Conventions section added — codifies all naming, numbering, heading level, table format, and body structure conventions as explicit non-negotiable rules. Previously these were only shown in templates. Mandatory audit NFR for modules with state-changing operations. Strict 6-NFR minimum for COMPREHENSIVE enforced. Dependency Graph ASCII arrow format made explicit. Optional appendix sections documented. Derived from autoresearch refinement loop (6 test cases, 2 iterations, 98-100% structural compliance achieved).

## v3.5
Use case location restructured — feature-scoped UCs now live in `docs/prd/{feature}/use-cases/` (colocated with PRD), cross-module UCs in `docs/use-cases/`. PAUSE 2 added for per-use-case Guided Review (Approve/Revise/Remove/Skip). PAUSE numbering rationalized (sequential 1-5, removed "1b" label). BRIEF mode skip list completed (added Phase 8b, 10b). PAUSE 5 deferrals question guarded for STANDARD+ only. Stage gate reference path corrected.

## v3.4.1
FR review switched from Batch Review (Pattern 3) to per-requirement Guided Review (Pattern 5) — each FR reviewed individually with Approve/Revise/Remove/Skip options.

## v3.4
Stage gates upgraded to use AskUserQuestion tool. PAUSE 1 uses Guided Review (Pattern 5) walking through Problem+Goals then Personas. FR review uses per-requirement Guided Review (Pattern 5). Priority review uses Guided Review for MoSCoW validation with downgrade/upgrade flows. Final validation uses Combined Gate (Pattern 4) asking confidence, assumptions, and deferrals simultaneously.

## v3.3
Open Questions upgraded to resolution tracking table with Status/Decision/Owner columns. Table of Contents for COMPREHENSIVE PRDs (10+ sections). Integration Points section for platform services consumed by other systems. Document Approval section for COMPREHENSIVE mode. Legacy Update notice convention for long-lived PRDs.

## v3.2
Document History table for auditable PRD evolution. Use cases extracted as standalone files (COMPREHENSIVE mode) — prevents monolith PRDs. Cockburn format replaced with table-based scenario format matching identity project patterns. Depth tiers (1/2/3) for use cases. Optional traceability index for 5+ use cases. Glossary import from discovery. Monolith PRD and Undocumented Evolution anti-patterns added.

## v3.1
Collaborative model diagram, personas before assumptions, duration/length targets, edge case prioritization on Must Haves, consolidated 5 review themes, BRIEF skip markers, kill criteria check, NFR rationale tracing, arbitrary NFR targets anti-pattern.
