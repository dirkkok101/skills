#!/usr/bin/env bash
# Test: Shared reference links are valid
# Verifies that every reference to _shared/references/ or references/ actually exists.
set -uo pipefail

PASS=0
FAIL=0
SKILLS_DIR="$(cd "$(dirname "$0")/../skills" && pwd)"

for skill_dir in "$SKILLS_DIR"/*/; do
  skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || continue
  name=$(basename "$skill_dir")

  # Find all references to .md files in backticks or markdown links
  refs=$(grep -oE '\.\./\_shared/references/[a-z-]+\.md|\_shared/references/[a-z-]+\.md|references/[a-z-]+\.md' "$skill_file" 2>/dev/null || true)

  for ref in $refs; do
    # Resolve path relative to skill directory
    # Handle _shared/ paths (relative to skills/ not skill dir)
    if echo "$ref" | grep -q '_shared'; then
      full_path="$SKILLS_DIR/$(echo "$ref" | sed 's|^\.\./||')"
    else
      full_path="$skill_dir/$ref"
    fi
    if [ -f "$full_path" ]; then
      PASS=$((PASS + 1))
    else
      echo "FAIL [ref-missing] $name: references '$ref' but file doesn't exist"
      echo "  Expected: $full_path"
      FAIL=$((FAIL + 1))
    fi
  done
done

# Also check that all shared reference files are referenced by at least one skill
for ref_file in "$SKILLS_DIR"/_shared/references/*.md; do
  ref_name=$(basename "$ref_file")
  # Skip domain-specific references (they're loaded conditionally)
  case "$ref_name" in
    identity-auth.md|capstone-data.md|guardian-mobile.md|general-saas.md|ascii-conventions.md)
      continue ;;
  esac

  if grep -rlq "$ref_name" "$SKILLS_DIR"/*/SKILL.md 2>/dev/null; then
    PASS=$((PASS + 1))
  else
    echo "WARN [ref-orphan] _shared/references/$ref_name: not referenced by any skill"
    PASS=$((PASS + 1))  # Warning, not failure
  fi
done

echo ""
echo "Reference Validity: $PASS passed, $FAIL failed"
exit $((FAIL > 0 ? 1 : 0))
