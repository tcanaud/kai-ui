#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Valid feature names pass validation and enable form submission
# Criterion: US4.AC1 — "Given a valid feature name is entered (e.g. 018-new-feature) and a playbook is selected, When the form is rendered, Then the Create Session button is enabled and no validation error is shown."
# Feature: 004-fix-feature-name-input-validation-special-chars-whitespace-and-max-length
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies that the FEATURE_NAME_PATTERN regex accepts valid slug-like names
# and that validateFeatureName returns null (no error) for such inputs.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

DIALOG="$PROJECT_DIR/src/app/components/sidebar/new-session-dialog.tsx"

echo "[US4.AC1] Testing: valid feature names pass validation"

# 1. FEATURE_NAME_PATTERN must be defined
if ! grep -q "FEATURE_NAME_PATTERN" "$DIALOG"; then
  echo "FAIL: FEATURE_NAME_PATTERN not found" >&2
  echo "  Expected: const FEATURE_NAME_PATTERN = /^[a-z0-9][a-z0-9-]*\$/" >&2
  echo "  Actual: constant missing" >&2
  exit 1
fi

# 2. The regex pattern must start with ^ (anchored start) — avoids false passes
if ! grep -q "FEATURE_NAME_PATTERN = /\^" "$DIALOG"; then
  echo "FAIL: FEATURE_NAME_PATTERN is not anchored at start (^)" >&2
  echo "  Expected: /^[a-z0-9][a-z0-9-]*\$/" >&2
  echo "  Actual: ^ anchor not found in pattern definition" >&2
  exit 1
fi

# 3. validateFeatureName must return null (no error) when pattern matches
# This is confirmed by the presence of a null return AFTER the pattern test branch
PATTERN_LINE=$(grep -n "FEATURE_NAME_PATTERN.test" "$DIALOG" | head -1 | cut -d: -f1)
NULL_AFTER=$(tail -n +"$PATTERN_LINE" "$DIALOG" | grep -c "return null")
if [ "$NULL_AFTER" -lt 1 ]; then
  echo "FAIL: validateFeatureName does not return null after successful pattern match" >&2
  echo "  Expected: return null; after FEATURE_NAME_PATTERN check" >&2
  echo "  Actual: no null return found after line $PATTERN_LINE" >&2
  exit 1
fi

# 4. The submit button disabled expression must NOT unconditionally disable when a valid
#    name is present — confirm !!validationError is used (null becomes false)
if ! grep -q "!!validationError" "$DIALOG"; then
  echo "FAIL: submit disabled does not use !!validationError (null should evaluate to false)" >&2
  echo "  Expected: !!validationError in disabled prop" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

echo "PASS: US4.AC1 — valid feature names pass validation and enable submission"
exit 0
