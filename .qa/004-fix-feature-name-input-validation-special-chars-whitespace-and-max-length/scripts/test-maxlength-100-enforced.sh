#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Feature Name input enforces maxLength=100
# Criterion: US3.AC1 — "Given the Feature Name input, When the user types or pastes more than 100 characters, Then the input value is capped at 100 characters (excess characters are not accepted)."
# Feature: 004-fix-feature-name-input-validation-special-chars-whitespace-and-max-length
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies that the Input element has maxLength={100} set, which causes the
# browser to reject any characters beyond the 100-character limit natively.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

DIALOG="$PROJECT_DIR/src/app/components/sidebar/new-session-dialog.tsx"

echo "[US3.AC1] Testing: feature name input has maxLength={100}"

# 1. Input must have maxLength={100}
if ! grep -q "maxLength={100}" "$DIALOG"; then
  echo "FAIL: Input does not have maxLength={100}" >&2
  echo "  Expected: maxLength={100} on <Input id=\"feature\" ...>" >&2
  echo "  Actual: not found in $DIALOG" >&2
  exit 1
fi

echo "PASS: US3.AC1 — feature name input enforces maxLength={100}"
exit 0
