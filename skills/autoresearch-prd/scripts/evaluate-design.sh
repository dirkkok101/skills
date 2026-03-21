#!/bin/bash
# evaluate-design.sh — Deterministic technical design checklist scorer
# Usage: evaluate-design.sh <design-dir> <test-case-id>
#
# Checks design.md + supporting files against canonical structure.

set -uo pipefail

DESIGN_DIR="$1"
TEST_CASE="$2"
DESIGN="$DESIGN_DIR/design.md"

PASS=0; FAIL=0; WARN=0; TOTAL=0; DETAILS=""

check() {
    local sev="$1" desc="$2" result="$3"
    TOTAL=$((TOTAL + 1))
    if [ "$result" -eq 0 ]; then PASS=$((PASS + 1))
    elif [ "$sev" = "FAIL" ]; then FAIL=$((FAIL + 1)); DETAILS="${DETAILS}FAIL: ${desc}\n"
    else WARN=$((WARN + 1)); DETAILS="${DETAILS}WARN: ${desc}\n"; fi
}

has() { grep -qiP "$1" "$DESIGN" 2>/dev/null; }
has_exact() { grep -qP "$1" "$DESIGN" 2>/dev/null; }
has_h2() { grep -qiP "^## ${1}( |$)" "$DESIGN" 2>/dev/null; }
has_h3() { grep -qiP "^### ${1}" "$DESIGN" 2>/dev/null; }
count() { local n; n=$(grep -cP "$1" "$DESIGN" 2>/dev/null) || true; echo "${n:-0}"; }
file_exists() { [ -f "$DESIGN_DIR/$1" ]; }

if [ ! -f "$DESIGN" ]; then
    echo "ERROR: design.md not found at $DESIGN"
    echo "CHECKLIST_SCORE: 0"
    exit 1
fi

# ============================================================
# 1. FILE STRUCTURE
# ============================================================

check FAIL "design.md exists" $(file_exists "design.md"; echo $?)
check FAIL "README.md exists" $(file_exists "README.md"; echo $?)
check FAIL "architecture.md exists" $(file_exists "architecture.md"; echo $?)
check FAIL "data-model.md exists" $(file_exists "data-model.md"; echo $?)
check WARN "glossary.md exists" $(file_exists "glossary.md"; echo $?)
check WARN "diagrams/ directory exists" $([ -d "$DESIGN_DIR/diagrams" ]; echo $?)
check WARN "decisions/ directory exists" $([ -d "$DESIGN_DIR/decisions" ]; echo $?)
check WARN "features/ directory exists" $([ -d "$DESIGN_DIR/features" ]; echo $?)

# ============================================================
# 2. DESIGN.MD — MANDATORY H2 SECTIONS
# ============================================================

check FAIL "## Documentation Foundation" $(has_h2 "Documentation Foundation"; echo $?)
check FAIL "## Constraints" $(has_h2 "Constraints"; echo $?)
check FAIL "## Assumptions" $(has_h2 "Assumptions"; echo $?)
check FAIL "## Key Decisions" $(has_h2 "Key Decisions"; echo $?)
# Domain Model: either inline H2 or reference to data-model.md
check WARN "## Domain Model section or data-model.md reference" \
    $(has_h2 "Domain Model" || has 'data-model\.md'; echo $?)
check FAIL "## Security & Privacy" $(has_h2 "Security"; echo $?)
check FAIL "## Operational Design" $(has_h2 "Operational Design"; echo $?)
check FAIL "## Work Decomposition" $(has_h2 "Work Decomposition"; echo $?)
check FAIL "## Self-Review Log" $(has_h2 "Self-Review Log"; echo $?)

# ============================================================
# 3. DOCUMENTATION FOUNDATION
# ============================================================

check FAIL "### Upstream Artifacts" \
    $(has_h3 "Upstream Artifacts" || has_h3 "Upstream"; echo $?)
check WARN "### Sibling Designs" $(has_h3 "Sibling Designs"; echo $?)
check WARN "### Learnings Applied" $(has_h3 "Learnings Applied"; echo $?)
check FAIL "PRD referenced" $(has 'prd.*\.md' || has 'PRD'; echo $?)

# ============================================================
# 4. CONSTRAINTS & ASSUMPTIONS
# ============================================================

check FAIL "### Technical Constraints" $(has_h3 "Technical Constraints"; echo $?)
check FAIL "### Organisational Constraints" $(has_h3 "Organisational Constraints"; echo $?)

# Assumptions table format
check FAIL "Assumptions table: # | Assumption | Impact if Wrong | How to Validate" \
    $(has 'Assumption.*Impact.*Wrong.*Validate'; echo $?)

ASSUMPTION_N=$(count '^\| [0-9]+ \|')
check WARN "At least 2 assumptions ($ASSUMPTION_N found)" \
    $([ "$ASSUMPTION_N" -ge 2 ] && echo 0 || echo 1)

# ============================================================
# 5. KEY DECISIONS
# ============================================================

# Two-layer decision pattern:
# Layer 1 (design.md): summary table — Decision | Chosen Approach | Rationale
# Layer 2 (decisions/*.md): full exploration — Alternatives table, Recommendation, Trade-off

# Layer 1: design.md summary
# Accept: "Design Decisions", "Prior Decisions", "Additional Design Decisions", or decision summary table
check FAIL "Design decisions documented (heading or summary table)" \
    $(has_h3 "Design Decisions" || has_h3 "Prior Decisions" || has_h3 "Decision Summary" || \
     has 'Decision.*Chosen.*Rationale' || has 'Decision.*Approach.*Rationale'; echo $?)

check FAIL "Decision summary table (Decision | Chosen Approach | Rationale)" \
    $(has 'Decision.*Chosen.*Rationale' || has 'Decision.*Approach.*Rationale' || has 'Source.*Title.*Implication'; echo $?)

# Layer 2: decision files exist
DECISION_FILES=$(find "$DESIGN_DIR/decisions" -name "*.md" 2>/dev/null | wc -l)
check WARN "Decision files in decisions/ ($DECISION_FILES found)" \
    $([ "$DECISION_FILES" -ge 1 ] && echo 0 || echo 1)

# ============================================================
# 6. SECURITY & PRIVACY
# ============================================================

check WARN "### Authentication & Authorization sub-section" \
    $(has_h3 "Authentication" || has 'authoriz'; echo $?)

check WARN "### Audit Logging sub-section" \
    $(has_h3 "Audit" || has 'audit.*log'; echo $?)

# ============================================================
# 7. OPERATIONAL DESIGN
# ============================================================

check FAIL "### Deployment Strategy" $(has_h3 "Deployment Strategy"; echo $?)

check FAIL "### Failure Modes" $(has_h3 "Failure Modes"; echo $?)
check FAIL "Failure Modes table: Component | Failure Mode | Impact | Mitigation" \
    $(has 'Component.*Failure.*Impact.*Mitigation'; echo $?)

check FAIL "### Observability" $(has_h3 "Observability"; echo $?)

# ============================================================
# 8. WORK DECOMPOSITION
# ============================================================

check FAIL "### Component Breakdown" $(has_h3 "Component Breakdown"; echo $?)
check FAIL "Component Breakdown table: Component | Scope | Complexity | Risk | Implements" \
    $(has 'Component.*Scope.*Complexity.*Risk'; echo $?)

check FAIL "### Dependency Graph" $(has_h3 "Dependency Graph" || has '## Dependency'; echo $?)
check WARN "ASCII dependency arrows (──>)" $(has_exact '──>'; echo $?)

check FAIL "### Suggested Execution Order" $(has_h3 "Suggested Execution Order"; echo $?)

# ============================================================
# 8b. PRD COVERAGE & ADR COMPLIANCE
# ============================================================

check FAIL "PRD Coverage Matrix present" \
    $(has 'PRD Coverage' || has 'FR.*Title.*Priority.*Feature' || has 'Coverage Matrix'; echo $?)

check FAIL "ADR Compliance table present" \
    $(has 'ADR Compliance' || has 'ADR.*Title.*Applicable'; echo $?)

# Check endpoint table has Maps To column
FIRST_API=$(find "$DESIGN_DIR" -name "api-surface.md" 2>/dev/null | head -1)
if [ -n "$FIRST_API" ]; then
    check WARN "Endpoint table has Maps To column (FR traceability)" \
        $(grep -qiP 'Maps.*To|FR-[A-Z]' "$FIRST_API" 2>/dev/null; echo $?)
fi

# ============================================================
# 9. SELF-REVIEW LOG
# ============================================================

# Self-Review rounds: either ### Round {N} headings or table rows with | {N} |
REVIEW_HEADING_N=$(count '^### Round [0-9]+')
# Extract self-review section to temp file, count table rows there
REVIEW_TMP=$(mktemp)
sed -n '/^## Self-Review/,/^## /p' "$DESIGN" 2>/dev/null > "$REVIEW_TMP" || true
REVIEW_TABLE_N=$(grep -cP '^\| [0-9]+ ' "$REVIEW_TMP" 2>/dev/null || true)
REVIEW_TABLE_N=$(echo "$REVIEW_TABLE_N" | head -1)
REVIEW_TABLE_N="${REVIEW_TABLE_N:-0}"
rm -f "$REVIEW_TMP"
REVIEW_ROUNDS="$REVIEW_HEADING_N"
if [ "$REVIEW_TABLE_N" -gt "$REVIEW_HEADING_N" ] 2>/dev/null; then
    REVIEW_ROUNDS="$REVIEW_TABLE_N"
fi
check FAIL "Self-Review: at least 1 round ($REVIEW_ROUNDS found)" \
    $([ "$REVIEW_ROUNDS" -ge 1 ] && echo 0 || echo 1)

check WARN "Self-Review: at least 2 rounds ($REVIEW_ROUNDS found)" \
    $([ "$REVIEW_ROUNDS" -ge 2 ] && echo 0 || echo 1)

# ============================================================
# 10. ARCHITECTURE.MD
# ============================================================

if file_exists "architecture.md"; then
    ARCH="$DESIGN_DIR/architecture.md"
    check FAIL "architecture.md: C4 Level 1 / System Context" \
        $(grep -qiP '(C4 Level 1|System Context)' "$ARCH" 2>/dev/null; echo $?)
    check FAIL "architecture.md: C4 Level 2 / Container" \
        $(grep -qiP '(C4 Level 2|Container)' "$ARCH" 2>/dev/null; echo $?)
fi

# ============================================================
# 11. DATA-MODEL.MD
# ============================================================

if file_exists "data-model.md"; then
    DM="$DESIGN_DIR/data-model.md"
    check FAIL "data-model.md: Entity definitions present" \
        $(grep -qiP '(Entity|Properties|## .*(Entity|Table|Schema))' "$DM" 2>/dev/null; echo $?)
    check WARN "data-model.md: Migration Strategy" \
        $(grep -qiP '(Migration|Rollback)' "$DM" 2>/dev/null; echo $?)
fi

# ============================================================
# 12. PER-FEATURE DOCS
# ============================================================

# Check for api-surface files (flat or in features/)
API_FILES=$(find "$DESIGN_DIR" -name "api-surface.md" 2>/dev/null | wc -l)
check FAIL "At least 1 api-surface.md ($API_FILES found)" \
    $([ "$API_FILES" -ge 1 ] && echo 0 || echo 1)

# Check for test-plan files
TEST_FILES=$(find "$DESIGN_DIR" -name "test-plan.md" 2>/dev/null | wc -l)
check FAIL "At least 1 test-plan.md ($TEST_FILES found)" \
    $([ "$TEST_FILES" -ge 1 ] && echo 0 || echo 1)

# Check api-surface content (sample first one found)
FIRST_API=$(find "$DESIGN_DIR" -name "api-surface.md" 2>/dev/null | head -1)
if [ -n "$FIRST_API" ]; then
    check FAIL "api-surface: Endpoints table (Verb | Route | Purpose)" \
        $(grep -qiP 'Verb.*Route.*Purpose' "$FIRST_API" 2>/dev/null || \
         grep -qiP 'Method.*Route.*Purpose' "$FIRST_API" 2>/dev/null || \
         grep -qiP 'POST.*\/api\/' "$FIRST_API" 2>/dev/null; echo $?)
    check WARN "api-surface: Response Codes section" \
        $(grep -qiP '(Response Code|Success Code)' "$FIRST_API" 2>/dev/null; echo $?)
    check WARN "api-surface: Contracts / DTO section" \
        $(grep -qiP '(Contract|DTO)' "$FIRST_API" 2>/dev/null; echo $?)
    check WARN "api-surface: Validation Rules section" \
        $(grep -qiP 'Validation' "$FIRST_API" 2>/dev/null; echo $?)
    check WARN "api-surface: Backend section" \
        $(grep -qiP '(Backend|Command Flow|Queries)' "$FIRST_API" 2>/dev/null; echo $?)
fi

# Check test-plan content (sample first one found)
FIRST_TEST=$(find "$DESIGN_DIR" -name "test-plan.md" 2>/dev/null | head -1)
if [ -n "$FIRST_TEST" ]; then
    TEST_CASES=$(grep -cP '^\| [0-9]+ \|' "$FIRST_TEST" 2>/dev/null || echo 0)
    check WARN "test-plan: at least 20 test cases ($TEST_CASES found)" \
        $([ "$TEST_CASES" -ge 20 ] && echo 0 || echo 1)
    check WARN "test-plan: Source column (UC/FR traceability)" \
        $(grep -qiP 'Source' "$FIRST_TEST" 2>/dev/null; echo $?)
fi

# ============================================================
# RESULTS
# ============================================================

CHECKLIST_PCT=0
if [ "$TOTAL" -gt 0 ]; then
    CHECKLIST_PCT=$(( (PASS * 100) / TOTAL ))
fi

echo "=== EVALUATE DESIGN: ${TEST_CASE} ==="
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
