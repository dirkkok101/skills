#!/usr/bin/env bash
# Test: Structural integrity of all skill files
# Verifies required sections, frontmatter, and file structure.
set -uo pipefail

PASS=0
FAIL=0
SKILLS_DIR="$(cd "$(dirname "$0")/../skills" && pwd)"

for skill_dir in "$SKILLS_DIR"/*/; do
  skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || continue
  name=$(basename "$skill_dir")

  # Skip _shared (not a skill)
  [ "$name" = "_shared" ] && continue
  # Skip autoresearch-prd (not a standard skill)
  [ "$name" = "autoresearch-prd" ] && continue

  # Check 1: YAML frontmatter exists
  if head -1 "$skill_file" | grep -q '^---$'; then
    PASS=$((PASS + 1))
  else
    echo "FAIL [frontmatter] $name: missing YAML frontmatter"
    FAIL=$((FAIL + 1))
  fi

  # Check 2: name field exists
  if grep -q '^name:' "$skill_file"; then
    PASS=$((PASS + 1))
  else
    echo "FAIL [name] $name: missing 'name:' in frontmatter"
    FAIL=$((FAIL + 1))
  fi

  # Check 3: description field exists
  if grep -q '^description:' "$skill_file"; then
    PASS=$((PASS + 1))
  else
    echo "FAIL [description] $name: missing 'description:' in frontmatter"
    FAIL=$((FAIL + 1))
  fi

  # Check 4: Has a version line or VERSIONS.md link
  if grep -q 'Skill Version\|VERSIONS.md' "$skill_file"; then
    PASS=$((PASS + 1))
  else
    echo "FAIL [version] $name: no version indicator found"
    FAIL=$((FAIL + 1))
  fi

  # Check 5: VERSIONS.md exists if referenced
  if grep -q 'VERSIONS.md' "$skill_file" && [ ! -f "$skill_dir/VERSIONS.md" ]; then
    echo "FAIL [versions-file] $name: references VERSIONS.md but file doesn't exist"
    FAIL=$((FAIL + 1))
  else
    PASS=$((PASS + 1))
  fi

  # Check 6: No project-specific hardcoded references
  if grep -qiE 'nxgn|NxGN|capstone' "$skill_file"; then
    line=$(grep -niE 'nxgn|NxGN|capstone' "$skill_file" | head -1)
    echo "FAIL [project-specific] $name: contains project-specific reference"
    echo "  $line"
    FAIL=$((FAIL + 1))
  else
    PASS=$((PASS + 1))
  fi

  # Check 7: File size reasonable (warn if >1500 lines)
  lines=$(wc -l < "$skill_file")
  if [ "$lines" -gt 1500 ]; then
    echo "WARN [size] $name: $lines lines (consider extraction)"
    # Not a fail, just a warning
    PASS=$((PASS + 1))
  else
    PASS=$((PASS + 1))
  fi
done

echo ""
echo "Structural Integrity: $PASS passed, $FAIL failed"
exit $((FAIL > 0 ? 1 : 0))
