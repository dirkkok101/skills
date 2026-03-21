#!/bin/bash
# semantic-diff.sh — Structural similarity scorer for PRD documents
# Usage: semantic-diff.sh <generated-prd> <ground-truth-prd>
#
# Extracts structural fingerprints from both files and computes
# Jaccard similarity. This catches structural drift that checklists miss.
#
# Fingerprint dimensions:
#   1. Section headings (H2, H3, H4)
#   2. FR/NFR ID patterns
#   3. Table column headers
#   4. Persona identifiers
#   5. Epic names
#   6. Metadata fields
#   7. Use case references
#   8. Acceptance criteria patterns (Given/When/Then)
#
# This is a FIXED scorer. Do NOT modify during the training loop.

set -uo pipefail

GENERATED="$1"
GROUND_TRUTH="$2"

GEN_FP=$(mktemp)
GT_FP=$(mktemp)
trap "rm -f $GEN_FP $GT_FP" EXIT

# --- Fingerprint Extraction ---

extract_fingerprints() {
    local file="$1"
    local output="$2"

    {
        # 1. Section headings (normalized to lowercase, stripped of markdown)
        (grep -P '^#{2,4} ' "$file" 2>/dev/null || true) | \
            sed 's/^#* //' | tr '[:upper:]' '[:lower:]' | \
            sed 's/[^a-z0-9 ]//g' | sort -u | \
            sed 's/^/HEADING: /'

        # 2. FR IDs (unique, sorted)
        (grep -oP 'FR-[A-Z]+-[A-Z][-A-Z]*' "$file" 2>/dev/null || true) | \
            sort -u | sed 's/^/FR: /'

        # 3. NFR IDs (unique, sorted)
        (grep -oP 'NFR-[A-Z]+-[A-Z][-A-Z]*' "$file" 2>/dev/null || true) | \
            sort -u | sed 's/^/NFR: /'

        # 4. Table column headers (first row of each table)
        (grep -P '^\|[^-]' "$file" 2>/dev/null || true) | \
            (grep -v '^\|[-: ]*\|$' || true) | \
            head -30 | \
            tr '[:upper:]' '[:lower:]' | \
            sed 's/\s*|\s*/|/g' | sort -u | \
            sed 's/^/TABLE: /'

        # 5. Persona identifiers
        (grep -oP 'P[1-9][:, ]' "$file" 2>/dev/null || true) | \
            sort -u | sed 's/^/PERSONA: /'

        # 6. Epic names
        (grep -P '### Epic:' "$file" 2>/dev/null || true) | \
            sed 's/### Epic: //' | tr '[:upper:]' '[:lower:]' | \
            sort -u | sed 's/^/EPIC: /'

        # 7. Metadata field names
        (grep -P '^\| (Field|Version|Date|Author|Status|Scope|Brainstorm|Discovery|Depends|Module|Design)' "$file" 2>/dev/null || true) | \
            (grep -oP '^\| \w+' || true) | sed 's/^\| //' | tr '[:upper:]' '[:lower:]' | \
            sort -u | sed 's/^/META: /'

        # 8. UC references
        (grep -oP 'UC-[A-Z]+-\d{3}' "$file" 2>/dev/null || true) | \
            sort -u | sed 's/^/UC: /'

        # 9. Acceptance criteria pattern types (happy path vs error)
        if grep -qP 'Given.*invalid|Given.*error|Given.*unauthori|Given.*duplicate' "$file" 2>/dev/null; then
            echo "AC_PATTERN: error_paths_present"
        fi
        if grep -qP 'Given.*valid|Given.*authenticated|Given.*authorized' "$file" 2>/dev/null; then
            echo "AC_PATTERN: happy_paths_present"
        fi

        # 10. Key structural markers
        grep -qP 'Security Criteria:' "$file" 2>/dev/null && echo "MARKER: security_criteria" || true
        grep -qP 'Compliance Criteria:' "$file" 2>/dev/null && echo "MARKER: compliance_criteria" || true
        grep -qP '## Document Approval' "$file" 2>/dev/null && echo "MARKER: document_approval" || true
        grep -qP '## Domain Validation' "$file" 2>/dev/null && echo "MARKER: domain_validation" || true
        grep -qP '## Integration Points' "$file" 2>/dev/null && echo "MARKER: integration_points" || true
        grep -qP '## Table of Contents' "$file" 2>/dev/null && echo "MARKER: toc" || true
        grep -qP '## Dependency Graph' "$file" 2>/dev/null && echo "MARKER: dependency_graph" || true
        grep -qP '──>' "$file" 2>/dev/null && echo "MARKER: ascii_dependency_graph" || true
        grep -qP 'Coverage Matrix' "$file" 2>/dev/null && echo "MARKER: coverage_matrix" || true
        grep -qP '## Appendix' "$file" 2>/dev/null && echo "MARKER: appendix" || true
        grep -qP 'API Endpoint' "$file" 2>/dev/null && echo "MARKER: api_endpoint_summary" || true
        grep -qP 'Database Table' "$file" 2>/dev/null && echo "MARKER: database_tables" || true
        grep -qP '## Glossary' "$file" 2>/dev/null && echo "MARKER: glossary" || true
        grep -qP '## Architecture' "$file" 2>/dev/null && echo "MARKER: architecture_context" || true
        grep -qP 'Kill Criteria' "$file" 2>/dev/null && echo "MARKER: kill_criteria" || true
        grep -qP '## Edge Cases' "$file" 2>/dev/null && echo "MARKER: edge_cases" || true
        grep -qP 'Business Rule' "$file" 2>/dev/null && echo "MARKER: business_rules" || true
        grep -qP 'Consumer Integration' "$file" 2>/dev/null && echo "MARKER: consumer_integration" || true
        grep -qP 'Upstream PRD' "$file" 2>/dev/null && echo "MARKER: upstream_prd_updates" || true
        grep -qP 'Consumed Services' "$file" 2>/dev/null && echo "MARKER: consumed_services" || true
        grep -qP 'Exposed Services' "$file" 2>/dev/null && echo "MARKER: exposed_services" || true

    } | sort -u > "$output"
}

# --- Extract Both ---

extract_fingerprints "$GENERATED" "$GEN_FP"
extract_fingerprints "$GROUND_TRUTH" "$GT_FP"

# --- Compute Jaccard Similarity ---

INTERSECTION=$(comm -12 "$GEN_FP" "$GT_FP" | wc -l)
UNION=$(sort -u "$GEN_FP" "$GT_FP" | wc -l)

if [ "$UNION" -eq 0 ]; then
    SIMILARITY=0
else
    SIMILARITY=$(( (INTERSECTION * 100) / UNION ))
fi

# --- Per-dimension breakdown ---

echo "=== SEMANTIC DIFF ==="
echo "GENERATED_FINGERPRINTS: $(wc -l < "$GEN_FP")"
echo "GROUND_TRUTH_FINGERPRINTS: $(wc -l < "$GT_FP")"
echo "INTERSECTION: ${INTERSECTION}"
echo "UNION: ${UNION}"
echo "SIMILARITY_PCT: ${SIMILARITY}"
echo ""

# Show what's in ground truth but missing from generated
MISSING=$(comm -23 "$GT_FP" "$GEN_FP")
if [ -n "$MISSING" ]; then
    MISSING_COUNT=$(echo "$MISSING" | wc -l)
    echo "--- MISSING FROM GENERATED ($MISSING_COUNT items) ---"
    echo "$MISSING" | head -30
    if [ "$MISSING_COUNT" -gt 30 ]; then
        echo "... and $((MISSING_COUNT - 30)) more"
    fi
    echo ""
fi

# Show what's in generated but not in ground truth (extra content)
EXTRA=$(comm -13 "$GT_FP" "$GEN_FP")
if [ -n "$EXTRA" ]; then
    EXTRA_COUNT=$(echo "$EXTRA" | wc -l)
    echo "--- EXTRA IN GENERATED ($EXTRA_COUNT items) ---"
    echo "$EXTRA" | head -20
    if [ "$EXTRA_COUNT" -gt 20 ]; then
        echo "... and $((EXTRA_COUNT - 20)) more"
    fi
    echo ""
fi

echo "SEMANTIC_SCORE: ${SIMILARITY}"
