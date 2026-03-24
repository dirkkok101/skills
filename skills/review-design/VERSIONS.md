# Review-Design Skill — Version History

## v2.5
Production feedback round 3. Authority hierarchy: added backend.md > ui-mockup.md ranking within feature areas. FR ID aliasing: documented aliases are acceptable, check for mapping before cross-referencing. Cascade scope bounded: module directory only, cross-module cascades noted as WARNs. Phase 1 structural checks softened: FAIL if concern missing, WARN if present under non-canonical heading (substance over form). Mockup states: lowered from 3 to 2 (populated + one other). Token budget estimate for COMPREHENSIVE. All from Applications CONVERGE + COMPREHENSIVE production run.

## v2.4
CONVERGE mode refined from production runs. Skip all interactive stage gates (scope confirmation, per-finding walkthrough). Replace Phase 6 interactive walkthrough with summary table. WARNs listed but not interactive. Decision records excluded from cascade scope. Large authority sources may need chunked reading. Cascade check catches related issues across all normative files.

## v2.3
CONVERGE mode added — autoresearch loop built into the review skill. Runs review at selected depth, classifies findings (MECHANICAL/JUSTIFIED_DEVIATION/DECISION), auto-fixes mechanical issues, re-reviews until 0 FAILs or convergence. Progressive loading, cascade check, authority hierarchy, max 5 rounds.

## v2.2
Feature area to PRD Epic alignment check added. Phase 2 FR coverage independently verified (don't trust the design's own matrix). Phase 3 rewritten — ADR, pattern, and architecture checks are now generic (read from docs/adr/, docs/patterns/, docs/architecture/) instead of hardcoded to a specific project's conventions. This makes the review skill portable across projects.

## v2.1
Synced with /technical-design v3.7. PRD Coverage Matrix check added (every Must Have FR must map to endpoint + tests). ADR Compliance table check added (all ADRs classified). Endpoint table check updated to 5 columns (Verb, Route, Purpose, Maps To, Auth Policy).

## v2.0
Phase 1 fully synced with /technical-design v3.6 Structural Conventions. Now checks exact file structure (mandatory files, feature decomposition), design.md H2 section order, Documentation Foundation sub-headings, assumption table format (4-column, never bullets), two-layer decision pattern (summary table + decision files), operational design sub-headings, work decomposition format (component breakdown table + dependency graph + execution order), self-review table format with round count enforcement, architecture.md C4 level requirements, data-model.md completeness, per-feature doc structure and test plan quality. Policy/standards design exception documented. All checks specify exact severity (Fail vs Warn).
