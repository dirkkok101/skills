#!/usr/bin/env bash
# Run all skill tests
set -uo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
TOTAL_PASS=0
TOTAL_FAIL=0

echo "========================================="
echo "  Skill Test Suite"
echo "========================================="
echo ""

for test in "$DIR"/test-*.sh; do
  name=$(basename "$test" .sh | sed 's/test-//')
  echo "--- $name ---"
  if bash "$test"; then
    echo "  ✓ PASSED"
  else
    echo "  ✗ FAILED"
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
  fi
  echo ""
done

echo "========================================="
if [ "$TOTAL_FAIL" -eq 0 ]; then
  echo "  All test suites passed"
else
  echo "  $TOTAL_FAIL test suite(s) failed"
fi
echo "========================================="
exit $((TOTAL_FAIL > 0 ? 1 : 0))
