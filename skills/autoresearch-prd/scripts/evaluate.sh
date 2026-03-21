#!/bin/bash
# evaluate.sh — Deterministic PRD checklist scorer (v2)
# Usage: evaluate.sh <generated-prd> <ground-truth-prd> <test-case-id> [scope]
# Scope: BRIEF | STANDARD | COMPREHENSIVE (default: COMPREHENSIVE)
#
# Checks against canonical-structure.md — strict structural compliance.
# This is the FIXED loss function. Do NOT modify during the training loop.

set -uo pipefail

GENERATED="$1"
GROUND_TRUTH="$2"
TEST_CASE="$3"
SCOPE="${4:-COMPREHENSIVE}"

PASS=0
FAIL=0
WARN=0
TOTAL=0
DETAILS=""

# --- Helpers ---

check() {
    local severity="$1" desc="$2" result="$3"
    TOTAL=$((TOTAL + 1))
    if [ "$result" -eq 0 ]; then
        PASS=$((PASS + 1))
    elif [ "$severity" = "FAIL" ]; then
        FAIL=$((FAIL + 1))
        DETAILS="${DETAILS}FAIL: ${desc}\n"
    else
        WARN=$((WARN + 1))
        DETAILS="${DETAILS}WARN: ${desc}\n"
    fi
}

# H2 section heading — matches "## X" or "## X (suffix)" (case-insensitive)
has_h2() {
    grep -qiP "^## ${1}( |$)" "$GENERATED" 2>/dev/null
}

# Exact H3 heading (case-insensitive)
has_h3() {
    grep -qiP "^### ${1}" "$GENERATED" 2>/dev/null
}

# File contains pattern (case-insensitive)
has() {
    grep -qiP "$1" "$GENERATED" 2>/dev/null
}

# File contains pattern (case-sensitive)
has_exact() {
    grep -qP "$1" "$GENERATED" 2>/dev/null
}

# File does NOT contain pattern
lacks() {
    ! grep -qiP "$1" "$GENERATED" 2>/dev/null
}

# Count pattern occurrences (safe — always returns an integer)
count() {
    local n
    n=$(grep -cP "$1" "$GENERATED" 2>/dev/null) || true
    echo "${n:-0}"
}

# Count in a section (between two H2 headings)
count_in_section() {
    local section="$1" pattern="$2"
    local n
    n=$(sed -n "/^## ${section}/,/^## /p" "$GENERATED" 2>/dev/null | grep -cP "$pattern" 2>/dev/null) || true
    echo "${n:-0}"
}

# --- Pre-flight ---

if [ ! -f "$GENERATED" ]; then
    echo "ERROR: Generated file not found: $GENERATED"
    echo "CHECKLIST_SCORE: 0"
    exit 1
fi

# ============================================================
# 1. METADATA TABLE
# ============================================================

check FAIL "H1 title: # PRD: {Name}" \
    $(has_exact '^# PRD: '; echo $?)

check FAIL "Metadata table present (| Field | Value |)" \
    $(has_exact '^\| Field\s*\|'; echo $?)

for field in Version Date Author Status Scope Brainstorm Discovery; do
    sev=FAIL
    [ "$field" = "Brainstorm" ] || [ "$field" = "Discovery" ] && sev=WARN
    check $sev "Metadata: ${field} field" \
        $(has_exact "^\| ${field}"; echo $?)
done

check WARN "Metadata: Depends On field" \
    $(has_exact '^\| Depends On'; echo $?)

# ============================================================
# 2. DOCUMENT HISTORY
# ============================================================

check FAIL "## Document History" \
    $(has_h2 "Document History"; echo $?)

check FAIL "History table: Version | Date | Changes" \
    $(has_exact '^\| Version\s*\| Date\s*\| Changes'; echo $?)

# ============================================================
# 3. TABLE OF CONTENTS (COMPREHENSIVE)
# ============================================================

if [ "$SCOPE" = "COMPREHENSIVE" ]; then
    check FAIL "## Table of Contents" \
        $(has_h2 "Table of Contents"; echo $?)
fi

# ============================================================
# 4. PROBLEM STATEMENT
# ============================================================

check FAIL "## Problem Statement" \
    $(has_h2 "Problem Statement"; echo $?)

check FAIL "Impact: list" \
    $(has_exact '^Impact:'; echo $?)

check FAIL "Why now:" \
    $(has_exact '^Why now:'; echo $?)

# ============================================================
# 5. GOALS
# ============================================================

check FAIL "## Goals" \
    $(has_h2 "Goals"; echo $?)

check FAIL "Goals use **G{n}:** format" \
    $(has_exact '\*\*G[1-9]:\*\*'; echo $?)

GOAL_N=$(count '\*\*G[0-9]+:\*\*')
check WARN "At least 3 goals ($GOAL_N found)" \
    $([ "$GOAL_N" -ge 3 ] && echo 0 || echo 1)

# ============================================================
# 6. NON-GOALS
# ============================================================

check FAIL "## Non-Goals" \
    $(has_h2 "Non-Goals"; echo $?)

check FAIL "Non-Goals use **NG{n}:** format" \
    $(has_exact '\*\*NG[1-9]:\*\*'; echo $?)

# ============================================================
# 7. SUCCESS METRICS (STANDARD+)
# ============================================================

if [ "$SCOPE" != "BRIEF" ]; then
    check FAIL "## Success Metrics" \
        $(has_h2 "Success Metrics"; echo $?)

    check FAIL "Metrics table: Metric | Current | Target | By When | How Measured" \
        $(has 'Metric.*Current.*Target.*By When.*How Measured'; echo $?)
fi

# ============================================================
# 8. USER PERSONAS (STANDARD+)
# ============================================================

if [ "$SCOPE" != "BRIEF" ]; then
    check FAIL "## User Personas" \
        $(has_h2 "User Personas"; echo $?)

    PERSONA_N=$(count '^### P[0-9]+:')
    check FAIL "Personas use ### P{n}: format ($PERSONA_N found)" \
        $([ "$PERSONA_N" -ge 1 ] && echo 0 || echo 1)

    check WARN "At least 2 personas ($PERSONA_N found)" \
        $([ "$PERSONA_N" -ge 2 ] && echo 0 || echo 1)

    # Canonical sub-fields (all 6 required per canonical-structure.md)
    check FAIL "Persona field: **Goals:**" \
        $(has_exact '\*\*Goals:\*\*'; echo $?)

    check FAIL "Persona field: **Pain Points:**" \
        $(has_exact '\*\*Pain Points:\*\*'; echo $?)

    check FAIL "Persona field: **Current Workaround:**" \
        $(has_exact '\*\*Current Workaround:\*\*'; echo $?)

    check FAIL "Persona field: **Success Criteria:**" \
        $(has_exact '\*\*Success Criteria:\*\*'; echo $?)

    check FAIL "Persona field: **Tech Level:**" \
        $(has_exact '\*\*Tech Level:\*\*'; echo $?)

    check FAIL "Persona field: **Frequency:**" \
        $(has_exact '\*\*Frequency:\*\*'; echo $?)
fi

# ============================================================
# 9. ASSUMPTIONS & CONSTRAINTS
# ============================================================

check FAIL "## Assumptions & Constraints" \
    $(has_h2 "Assumptions" ; echo $?)

# Assumptions: bullet list with **A{n}:** prefix
check FAIL "### Assumptions sub-heading" \
    $(has_h3 "Assumptions"; echo $?)

check FAIL "Assumptions use **A{n}:** format" \
    $(has_exact '\*\*A[1-9]:\*\*'; echo $?)

ASSUMPTION_N=$(count '\*\*A[0-9]+:\*\*')
check WARN "At least 3 assumptions ($ASSUMPTION_N found)" \
    $([ "$ASSUMPTION_N" -ge 3 ] && echo 0 || echo 1)

if [ "$SCOPE" != "BRIEF" ]; then
    check FAIL "### Constraints sub-heading" \
        $(has_h3 "Constraints"; echo $?)

    check FAIL "Constraints use **C{n}:** format" \
        $(has_exact '\*\*C[1-9]:\*\*'; echo $?)

    CONSTRAINT_N=$(count '\*\*C[0-9]+:\*\*')
    check WARN "At least 2 constraints ($CONSTRAINT_N found)" \
        $([ "$CONSTRAINT_N" -ge 2 ] && echo 0 || echo 1)
fi

# Risks table
if [ "$SCOPE" != "BRIEF" ]; then
    check FAIL "### Risks sub-heading" \
        $(has_h3 "Risks"; echo $?)

    check FAIL "Risks table: Risk | Likelihood | Impact | Mitigation" \
        $(has 'Risk.*Likelihood.*Impact.*Mitigation'; echo $?)
fi

# Open Questions table
if [ "$SCOPE" != "BRIEF" ]; then
    check FAIL "### Open Questions sub-heading" \
        $(has_h3 "Open Questions"; echo $?)

    # OQ table required unless section says "None" (all resolved)
    check FAIL "OQ table or 'None' statement" \
        $(has 'Question.*Context.*Status.*Decision.*Owner' || has 'None.*resolved'; echo $?)
fi

# ============================================================
# 10. USE CASES (COMPREHENSIVE)
# ============================================================

if [ "$SCOPE" = "COMPREHENSIVE" ]; then
    check FAIL "## Use Cases" \
        $(has_h2 "Use Cases"; echo $?)

    UC_N=$(count 'UC-[A-Z]+-[0-9]{3}')
    check WARN "At least 3 use case references ($UC_N found)" \
        $([ "$UC_N" -ge 3 ] && echo 0 || echo 1)
fi

# ============================================================
# 11. FUNCTIONAL REQUIREMENTS
# ============================================================

check FAIL "## Functional Requirements" \
    $(has_h2 "Functional Requirements"; echo $?)

# Epic organization
EPIC_N=$(count '^### Epic:')
check FAIL "FRs organized under ### Epic: headings ($EPIC_N found)" \
    $([ "$EPIC_N" -ge 1 ] && echo 0 || echo 1)

# FR heading format: #### FR-{MODULE}-{NAME}: {Title}
FR_HEADING_N=$(count '^#### FR-[A-Z]+-[A-Z][-A-Z]*:')
check FAIL "FR headings use #### FR-{MOD}-{NAME}: format ($FR_HEADING_N found)" \
    $([ "$FR_HEADING_N" -ge 1 ] && echo 0 || echo 1)

# FR IDs are descriptive (no sequential numbers)
check FAIL "FR IDs are descriptive (not FR-XXX-001)" \
    $(lacks 'FR-[A-Z]+-[0-9]{3}'; echo $?)

# FR body structure
check FAIL "FRs have Priority: line" \
    $(has_exact '^Priority: (Must|Should|Could|Won'\''t)'; echo $?)

check FAIL "FRs have Complexity: line" \
    $(has_exact '^Complexity: (S|M|L|XL)'; echo $?)

check FAIL "FRs have user story (As a ...)" \
    $(has_exact '^As a '; echo $?)

check FAIL "FRs have Acceptance Criteria:" \
    $(has_exact '^Acceptance Criteria:'; echo $?)

check FAIL "FRs use Given/When/Then format" \
    $(has_exact '^\s+Given '; echo $?)

# FR counts
if [ "$SCOPE" = "BRIEF" ]; then MIN_FR=3
elif [ "$SCOPE" = "STANDARD" ]; then MIN_FR=8
else MIN_FR=10; fi

FR_ID_N=$(count 'FR-[A-Z]+-[A-Z][-A-Z]*:')
check WARN "Minimum FR count ($MIN_FR for $SCOPE, $FR_ID_N found)" \
    $([ "$FR_ID_N" -ge "$MIN_FR" ] && echo 0 || echo 1)

# Security Criteria on FRs (COMPREHENSIVE)
if [ "$SCOPE" = "COMPREHENSIVE" ]; then
    check FAIL "Security Criteria: present on FRs" \
        $(has_exact '^Security Criteria:'; echo $?)
fi

# ============================================================
# 12. NON-FUNCTIONAL REQUIREMENTS
# ============================================================

check FAIL "## Non-Functional Requirements" \
    $(has_h2 "Non-Functional Requirements"; echo $?)

# NFR heading format: ### NFR-{MODULE}-{NAME}: {Title}
NFR_HEADING_N=$(count '^### NFR-[A-Z]+-[A-Z][-A-Z0-9]*:')
check FAIL "NFR headings use ### NFR-{MOD}-{NAME}: format ($NFR_HEADING_N found)" \
    $([ "$NFR_HEADING_N" -ge 1 ] && echo 0 || echo 1)

# NFR IDs are descriptive
check FAIL "NFR IDs are descriptive (not NFR-XXX-001)" \
    $(lacks 'NFR-[A-Z]+-[0-9]{3}'; echo $?)

# NFR body structure
check FAIL "NFRs have Category: line" \
    $(has_exact '^Category: '; echo $?)

check FAIL "NFRs have Target: line with number" \
    $(has_exact '^Target: ' && has 'Target:.*[0-9]'; echo $?)

check FAIL "NFRs have Measurement: line" \
    $(has_exact '^Measurement: '; echo $?)

check FAIL "NFRs have Rationale: line" \
    $(has_exact '^Rationale: '; echo $?)

if [ "$SCOPE" = "BRIEF" ]; then MIN_NFR=2
elif [ "$SCOPE" = "STANDARD" ]; then MIN_NFR=4
else MIN_NFR=6; fi

check WARN "Minimum NFR count ($MIN_NFR for $SCOPE, $NFR_HEADING_N found)" \
    $([ "$NFR_HEADING_N" -ge "$MIN_NFR" ] && echo 0 || echo 1)

# ============================================================
# 13. INTEGRATION POINTS (COMPREHENSIVE)
# ============================================================

if [ "$SCOPE" = "COMPREHENSIVE" ]; then
    check FAIL "## Integration Points" \
        $(has_h2 "Integration Points"; echo $?)

    check FAIL "### Consumed Services" \
        $(has_h3 "Consumed Services"; echo $?)

    check FAIL "### Exposed Services" \
        $(has_h3 "Exposed Services"; echo $?)
fi

# ============================================================
# 14. PRIORITISATION (STANDARD+)
# ============================================================

if [ "$SCOPE" != "BRIEF" ]; then
    check FAIL "## Prioritisation" \
        $(has_h2 "Prioritisation"; echo $?)

    check FAIL "### Must Have (MVP)" \
        $(has_h3 "Must Have"; echo $?)

    check FAIL "### Should Have" \
        $(has_h3 "Should Have"; echo $?)

    check FAIL "### Could Have" \
        $(has_h3 "Could Have"; echo $?)

    check FAIL "### Won't Have" \
        $(has_h3 "Won.t Have"; echo $?)

    # Must Have count ≤ 10
    MUST_N=$(count_in_section "Prioritisation" '^- FR-')
    check WARN "Must Have ≤ 10 items ($MUST_N in Prioritisation)" \
        $([ "$MUST_N" -le 10 ] && echo 0 || echo 1)

    check FAIL "## Dependency Graph" \
        $(has_h2 "Dependency Graph" || has_exact '## Dependency'; echo $?)

    check WARN "ASCII dependency diagram (──>)" \
        $(has_exact '──>'; echo $?)
fi

# ============================================================
# 15. DOMAIN VALIDATION (COMPREHENSIVE)
# ============================================================

if [ "$SCOPE" = "COMPREHENSIVE" ]; then
    check FAIL "## Domain Validation" \
        $(has_h2 "Domain Validation"; echo $?)

    check FAIL "### Coverage Matrix" \
        $(has_h3 "Coverage Matrix" || has 'Coverage Matrix'; echo $?)
fi

# ============================================================
# 16. DOCUMENT APPROVAL (COMPREHENSIVE)
# ============================================================

if [ "$SCOPE" = "COMPREHENSIVE" ]; then
    check FAIL "## Document Approval" \
        $(has_h2 "Document Approval"; echo $?)

    check FAIL "Approval table: Role | Name | Status | Date" \
        $(has 'Role.*Name.*Status.*Date'; echo $?)

    check WARN "Approval footer text" \
        $(has 'Approval means'; echo $?)
fi

# ============================================================
# 17. CONTENT QUALITY
# ============================================================

if [ "$SCOPE" != "BRIEF" ]; then
    # Ambiguity words in acceptance criteria
    AC_LINES=$(grep -P '^\s+(Given|When|Then) ' "$GENERATED" 2>/dev/null || true)
    AMBIGUITY_N=0
    if [ -n "$AC_LINES" ]; then
        AMBIGUITY_N=$(echo "$AC_LINES" | grep -ciP '\b(appropriate|reasonable|quickly|user-friendly|intuitive|properly|as needed|etc\.|and/or)\b' || true)
        AMBIGUITY_N="${AMBIGUITY_N:-0}"
    fi
    check WARN "No ambiguity words in acceptance criteria ($AMBIGUITY_N found)" \
        $([ "$AMBIGUITY_N" -eq 0 ] && echo 0 || echo 1)

    # Error/edge case criteria
    check WARN "Error/edge case acceptance criteria present" \
        $(has 'Given.*(invalid|error|fail|unauthori|forbidden|duplicate|missing|empty|timeout|does not exist|already exists)'; echo $?)

    # Goals numbered with **G{n}:**
    check WARN "All goals numbered (**G{n}:**)" \
        $([ "$GOAL_N" -ge 3 ] && echo 0 || echo 1)

    # Persona references in user stories
    check WARN "User stories reference personas (P{n} or role name)" \
        $(has 'As a .*(P[1-4]|Platform|Org |Admin|Developer|End User|Auditor)'; echo $?)

    # Audit logging
    check WARN "Audit logging addressed (NFR or criteria)" \
        $(has '(audit|Audit).*(log|trail|event)' || has 'NFR-.*AUDIT'; echo $?)
fi

# ============================================================
# 18. GROUND TRUTH ALIGNMENT
# ============================================================

if [ -f "$GROUND_TRUTH" ]; then
    # Module prefix match
    GT_PREFIX=$(grep -oP '(?<=^#### FR-)[A-Z]+(?=-)' "$GROUND_TRUTH" 2>/dev/null | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')
    GT_PREFIX="${GT_PREFIX:-}"
    if [ -n "$GT_PREFIX" ]; then
        check FAIL "FR prefix matches module (FR-${GT_PREFIX}-*)" \
            $(has_exact "FR-${GT_PREFIX}-"; echo $?)
    fi

    GT_NFR_PREFIX=$(grep -oP '(?<=^### NFR-)[A-Z]+(?=-)' "$GROUND_TRUTH" 2>/dev/null | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')
    GT_NFR_PREFIX="${GT_NFR_PREFIX:-}"
    if [ -n "$GT_NFR_PREFIX" ]; then
        check FAIL "NFR prefix matches module (NFR-${GT_NFR_PREFIX}-*)" \
            $(has_exact "NFR-${GT_NFR_PREFIX}-"; echo $?)
    fi
fi

# ============================================================
# RESULTS
# ============================================================

CHECKLIST_PCT=0
if [ "$TOTAL" -gt 0 ]; then
    CHECKLIST_PCT=$(( (PASS * 100) / TOTAL ))
fi

echo "=== EVALUATE: ${TEST_CASE} (${SCOPE}) ==="
echo "TOTAL: ${TOTAL}"
echo "PASS: ${PASS}"
echo "FAIL: ${FAIL}"
echo "WARN: ${WARN}"
echo "CHECKLIST_PCT: ${CHECKLIST_PCT}"
echo ""

if [ -n "$DETAILS" ]; then
    echo "--- FINDINGS ---"
    printf "%b" "$DETAILS"
fi

echo "CHECKLIST_SCORE: ${CHECKLIST_PCT}"
