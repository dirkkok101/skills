# Skill Tests

Prompt-based tests that verify skill triggering, CSO compliance, and structural integrity.

## Running Tests

```bash
# All tests
bash tests/run-all.sh

# Individual test suites
bash tests/test-cso-compliance.sh     # Description trigger-only compliance
bash tests/test-structural-integrity.sh # Required sections present
bash tests/test-references.sh          # Shared reference links valid
```

## Test Philosophy

These are deterministic structural tests — they verify the skill files themselves, not agent behavior. Agent behavior is validated through production runs (see CHRONICLE.md).
