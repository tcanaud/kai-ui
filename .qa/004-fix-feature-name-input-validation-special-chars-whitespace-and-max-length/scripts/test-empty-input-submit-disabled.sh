#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Empty input keeps submit button disabled
# Criterion: US2.AC2 — "Given the Feature Name input is empty, When the form is rendered, Then the Create Session button is disabled."
# Feature: 004-fix-feature-name-input-validation-special-chars-whitespace-and-max-length
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies the initial state: featureName defaults to "" and the button disabled
# expression uses !featureName.trim() which is truthy for an empty string.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

DIALOG="$PROJECT_DIR/src/app/components/sidebar/new-session-dialog.tsx"

echo "[US2.AC2] Testing: empty input keeps submit button disabled"

# 1. featureName initial state must be empty string
if ! grep -q 'featureName, setFeatureName] = useState("")' "$DIALOG"; then
  echo "FAIL: featureName initial state is not empty string" >&2
  echo "  Expected: useState(\"\")" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 2. The button disabled prop must include !featureName.trim()
if ! grep -qE '!\s*featureName\.trim\(\)' "$DIALOG"; then
  echo "FAIL: button disabled expression does not include !featureName.trim()" >&2
  echo "  Expected: !featureName.trim() evaluates truthy for empty string" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

echo "PASS: US2.AC2 — empty feature name keeps submit button disabled"
exit 0
