# Review-PRD Skill — Version History

## v2.3
Production feedback from API Keys CONVERGE + COMPREHENSIVE run. (1) READ-ONLY vs CONVERGE contradiction fixed — READ-ONLY scoped to non-CONVERGE modes. (2) Phase 1 chunking strategy for PRDs >300 lines (3 passes: metadata+problem, FRs+NFRs, prioritisation+validation). (3) WARN triage step after 0 FAILs — present remaining WARNs for user resolution. (4) NFR-AUDIT template content for mechanical fixes. (5) Phase 4 severity guide table (FAIL vs WARN per finding type). (6) Rubber Stamp anti-pattern updated — low Phase 1 findings on revised PRDs (v1.2+) is a quality signal, not insufficient depth. (7) Convergence report template for consistent round-by-round reporting.

## v2.2
CONVERGE mode refined — skip interactive stage gates, replace per-finding walkthrough with summary table, WARNs listed but not interactive. Chunked reading guidance for large PRDs.

## v2.1
CONVERGE mode added — autoresearch loop built into the review skill. Runs review at selected depth, classifies findings (MECHANICAL/JUSTIFIED_DEVIATION/DECISION), auto-fixes mechanical issues, re-reviews until 0 FAILs or convergence. Authority hierarchy specific to PRDs.

## v2.0
Phase 1 checklist fully synced with /prd v3.7 Structural Conventions — now checks exact heading formats, numbering prefixes (G/NG/A/C), heading levels (H2/H3/H4), all 6 persona sub-fields individually, FR/NFR body structure lines, mandatory audit NFR, strict NFR minimum (Fail not Warning), MoSCoW exact headings, Integration Points sub-headings, Document Approval table columns, Dependency Graph with ASCII arrows. Phase 2 adds naming convention consistency, heading level compliance, and audit coverage checks. Policy & Standards PRD exceptions noted. Template Worship anti-pattern reconciled with non-negotiable structural conventions. TOC upgraded from Warning to Fail for COMPREHENSIVE.
