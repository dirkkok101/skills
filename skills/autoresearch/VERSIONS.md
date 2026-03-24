# Autoresearch Skill — Version History

## v1.4
Anti-patterns section added (6 patterns: spinning without escalating, fixing WARNs, modifying review skill, fixing decision records, guessing on decisions, single-pass assumptions). Example invocations section with 4 usage patterns. Duration estimates added.

## v1.3
Authority hierarchy: added backend.md, ui-mockup.md ranking. FR ID aliasing guidance. Cascade scope bounded to module directory. Cross-module cascades noted as WARNs. Aligned with review-design v2.5.

## v1.2
Skip interactive stage gates during loop. Decision records excluded from cascade scope. WARNs listed but not interactive.

## v1.1
Progressive loading strategy (3 waves to reduce upfront context cost). JUSTIFIED_DEVIATION classification for pattern/ADR deviations with documented rationale. Cascade check after cross-cutting fixes (grep for related terms). Compact report format for quick convergences. Severity alignment note (review skill wins on FAIL vs WARN). Agent vs direct read guidance. All improvements from first production run on Entitlements module.

## v1.0
Initial autoresearch convergence loop. Adapted from Karpathy autoresearch + pi-autoresearch (domain-agnostic). Frozen metric = review FAIL count. Mechanical vs decision classification. Authority hierarchy for conflict resolution. Max 5 rounds with revert-on-regression guardrail. Multi-module parallel mode.
