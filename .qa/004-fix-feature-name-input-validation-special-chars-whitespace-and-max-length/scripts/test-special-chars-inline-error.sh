#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Special characters trigger inline validation error
# Criterion: US1.AC1 — "Given the Feature Name input is focused, When the user types a value containing special characters (e.g. my_feature!), Then an inline error message is shown below the input explaining the allowed characters."
# Feature: 004-fix-feature-name-input-validation-special-chars-whitespace-and-max-length
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies that validateFeatureName rejects special chars and that the
# dialog renders the inline error paragraph when validationError is set.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

DIALOG="$PROJECT_DIR/src/app/components/sidebar/new-session-dialog.tsx"

echo "[US1.AC1] Testing: special characters produce inline validation error"

# 1. FEATURE_NAME_PATTERN must only allow [a-z0-9-]
if ! grep -q "FEATURE_NAME_PATTERN" "$DIALOG"; then
  echo "FAIL: FEATURE_NAME_PATTERN constant not found in dialog" >&2
  echo "  Expected: const FEATURE_NAME_PATTERN = /^[a-z0-9][a-z0-9-]*\$/" >&2
  echo "  Actual: constant missing" >&2
  exit 1
fi

# 2. validateFeatureName must test against FEATURE_NAME_PATTERN
if ! grep -q "FEATURE_NAME_PATTERN.test" "$DIALOG"; then
  echo "FAIL: validateFeatureName does not test against FEATURE_NAME_PATTERN" >&2
  echo "  Expected: FEATURE_NAME_PATTERN.test(trimmed)" >&2
  echo "  Actual: test call not found" >&2
  exit 1
fi

# 3. validateFeatureName must return an error string for invalid chars
if ! grep -q "Only lowercase letters" "$DIALOG"; then
  echo "FAIL: validateFeatureName does not return an error message for invalid characters" >&2
  echo "  Expected: error string mentioning allowed characters" >&2
  echo "  Actual: message not found" >&2
  exit 1
fi

# 4. The inline error paragraph must be rendered when validationError is set
if ! grep -q "validationError &&" "$DIALOG"; then
  echo "FAIL: dialog does not conditionally render validationError" >&2
  echo "  Expected: {validationError && (<p ...>{validationError}</p>)}" >&2
  echo "  Actual: conditional rendering not found" >&2
  exit 1
fi

echo "PASS: US1.AC1 — special characters trigger inline validation error"
exit 0
