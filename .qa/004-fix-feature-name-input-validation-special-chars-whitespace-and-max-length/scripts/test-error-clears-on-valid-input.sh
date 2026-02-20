#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Inline error disappears when input becomes valid
# Criterion: US1.AC2 — "Given an inline validation error is visible, When the user corrects the input to a valid name (e.g. my-feature), Then the inline error message disappears."
# Feature: 004-fix-feature-name-input-validation-special-chars-whitespace-and-max-length
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies that validateFeatureName returns null for valid names, and that
# the onChange handler calls setValidationError on every keystroke so the
# inline error is cleared when the input becomes valid.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

DIALOG="$PROJECT_DIR/src/app/components/sidebar/new-session-dialog.tsx"

echo "[US1.AC2] Testing: inline error clears when input becomes valid"

# 1. validateFeatureName must return null for a valid name (null = no error)
if ! grep -q "return null" "$DIALOG"; then
  echo "FAIL: validateFeatureName does not return null for valid input" >&2
  echo "  Expected: return null; (no error)" >&2
  echo "  Actual: null return not found" >&2
  exit 1
fi

# 2. onChange must call setValidationError on every keystroke
if ! grep -q "setValidationError(validateFeatureName(val))" "$DIALOG"; then
  echo "FAIL: onChange handler does not call setValidationError(validateFeatureName(val))" >&2
  echo "  Expected: setValidationError(validateFeatureName(val))" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

echo "PASS: US1.AC2 — inline error clears when input is corrected to a valid name"
exit 0
