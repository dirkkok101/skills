#!/bin/bash
# score.sh — Combined scorer: 60% checklist + 40% semantic similarity
# Usage: score.sh <generated-prd> <ground-truth-prd> <test-case-id> [scope]
#
# Runs both evaluate.sh and semantic-diff.sh, combines into a single score.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GENERATED="$1"
GROUND_TRUTH="$2"
TEST_CASE="$3"
SCOPE="${4:-COMPREHENSIVE}"

# Run both scorers (allow non-zero exit from sub-scripts)
EVAL_OUTPUT=$("$SCRIPT_DIR/evaluate.sh" "$GENERATED" "$GROUND_TRUTH" "$TEST_CASE" "$SCOPE" 2>&1) || true
SEMANTIC_OUTPUT=$("$SCRIPT_DIR/semantic-diff.sh" "$GENERATED" "$GROUND_TRUTH" 2>&1) || true

# Extract scores
CHECKLIST_SCORE=$(echo "$EVAL_OUTPUT" | grep '^CHECKLIST_SCORE:' | awk '{print $2}')
SEMANTIC_SCORE=$(echo "$SEMANTIC_OUTPUT" | grep '^SEMANTIC_SCORE:' | awk '{print $2}')

CHECKLIST_SCORE=${CHECKLIST_SCORE:-0}
SEMANTIC_SCORE=${SEMANTIC_SCORE:-0}

# Combined: 60% checklist + 40% semantic
COMBINED=$(( (CHECKLIST_SCORE * 60 + SEMANTIC_SCORE * 40) / 100 ))

# Output full details
echo "$EVAL_OUTPUT"
echo ""
echo "$SEMANTIC_OUTPUT"
echo ""
echo "=== COMBINED SCORE ==="
echo "CHECKLIST: ${CHECKLIST_SCORE}%"
echo "SEMANTIC: ${SEMANTIC_SCORE}%"
echo "COMBINED: ${COMBINED}%"
echo ""
echo "SCORE: ${COMBINED}"
