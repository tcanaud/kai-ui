#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Whitespace-only input keeps submit button disabled
# Criterion: US2.AC1 — "Given the Feature Name input contains only whitespace (e.g. '   '), When the form is rendered, Then the Create Session button is disabled."
# Feature: 004-fix-feature-name-input-validation-special-chars-whitespace-and-max-length
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies that the submit button disabled expression uses featureName.trim()
# so that whitespace-only strings evaluate as falsy and keep the button disabled.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

DIALOG="$PROJECT_DIR/src/app/components/sidebar/new-session-dialog.tsx"

echo "[US2.AC1] Testing: whitespace-only input keeps submit button disabled"

# 1. The button disabled prop must include featureName.trim() check
if ! grep -q "featureName.trim()" "$DIALOG"; then
  echo "FAIL: submit button disabled condition does not use featureName.trim()" >&2
  echo "  Expected: !featureName.trim() in disabled prop" >&2
  echo "  Actual: featureName.trim() not found" >&2
  exit 1
fi

# 2. The button disabled prop must also gate on validationError
if ! grep -q "!!validationError" "$DIALOG"; then
  echo "FAIL: submit button disabled condition does not include !!validationError" >&2
  echo "  Expected: !!validationError in disabled prop" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

echo "PASS: US2.AC1 — whitespace-only input keeps submit button disabled"
exit 0
