#!/usr/bin/env bash
# Test: CSO (Comprehensive Summary Override) compliance
# Every skill description must start with "Use when" and contain NO workflow summaries.
set -uo pipefail

PASS=0
FAIL=0
SKILLS_DIR="$(cd "$(dirname "$0")/../skills" && pwd)"

for skill_dir in "$SKILLS_DIR"/*/; do
  skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || continue
  name=$(basename "$skill_dir")

  # Extract description from YAML frontmatter
  desc=$(sed -n '/^description:/,/^[a-z]/p' "$skill_file" | head -20 | grep -v '^[a-z]' | sed 's/^description: >//' | tr '\n' ' ' | sed 's/^  *//')

  # Check 1: Description starts with "Use when" or "Use after"
  if echo "$desc" | grep -qiE '^\s*Use (when|after|for|before)'; then
    PASS=$((PASS + 1))
  else
    echo "FAIL [CSO-trigger] $name: description doesn't start with 'Use when/after'"
    echo "  Got: $(echo "$desc" | head -c 80)..."
    FAIL=$((FAIL + 1))
  fi

  # Check 2: Description should NOT contain workflow verbs
  workflow_verbs="Generates|Produces|Launches|Creates|Transforms|Captures|Maps|Decomposes|Consolidates|Investigates"
  if echo "$desc" | grep -qE "$workflow_verbs"; then
    match=$(echo "$desc" | grep -oE "$workflow_verbs" | head -1)
    echo "FAIL [CSO-summary] $name: description contains workflow verb '$match'"
    FAIL=$((FAIL + 1))
  else
    PASS=$((PASS + 1))
  fi
done

echo ""
echo "CSO Compliance: $PASS passed, $FAIL failed"
exit $((FAIL > 0 ? 1 : 0))
