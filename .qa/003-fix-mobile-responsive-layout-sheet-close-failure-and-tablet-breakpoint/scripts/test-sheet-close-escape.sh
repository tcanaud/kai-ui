#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Mobile sheet Escape key dismiss is not suppressed
# Criterion: US1.AC3 — "Given the mobile nav sheet is open, When the user presses the Escape key, Then the sheet closes and only the hamburger button is visible."
# Feature: 003-fix-mobile-responsive-layout-sheet-close-failure-and-tablet-breakpoint
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies that no onEscapeKeyDown preventDefault is present in SheetContent or MobileNav
# that would block the Radix Dialog Escape key close behaviour.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US1.AC3] Testing: Sheet Escape key close is not suppressed"

SHEET_FILE="$PROJECT_DIR/src/components/ui/sheet.tsx"
MOBILE_NAV_FILE="$PROJECT_DIR/src/app/components/layout/mobile-nav.tsx"

# 1. No onEscapeKeyDown preventDefault in SheetContent
if grep -q "onEscapeKeyDown.*preventDefault" "$SHEET_FILE"; then
  echo "FAIL: SheetContent suppresses Escape key — sheet will not close on Escape" >&2
  echo "  Expected: no onEscapeKeyDown preventDefault in SheetContent" >&2
  echo "  Actual: found in $SHEET_FILE" >&2
  exit 1
fi

# 2. No onEscapeKeyDown preventDefault in MobileNav
if grep -q "onEscapeKeyDown.*preventDefault" "$MOBILE_NAV_FILE"; then
  echo "FAIL: MobileNav suppresses Escape key on the Sheet" >&2
  echo "  Expected: no onEscapeKeyDown preventDefault in MobileNav" >&2
  echo "  Actual: found in $MOBILE_NAV_FILE" >&2
  exit 1
fi

# 3. Sheet uses Radix Dialog primitive (which handles Escape natively)
if ! grep -q "Dialog as SheetPrimitive" "$SHEET_FILE"; then
  echo "FAIL: Sheet does not use Radix Dialog primitive — Escape key handling uncertain" >&2
  echo "  Expected: import { Dialog as SheetPrimitive } from 'radix-ui'" >&2
  echo "  Actual: not found in $SHEET_FILE" >&2
  exit 1
fi

echo "PASS: US1.AC3 — Escape key close not suppressed; Radix primitive handles it natively"
exit 0
