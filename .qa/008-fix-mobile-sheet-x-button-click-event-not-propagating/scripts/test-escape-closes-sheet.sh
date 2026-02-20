#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Escape key still closes the mobile sheet (no regression)
# Criterion: US2.AC1 — "Given the mobile nav sheet is open, When the user presses the Escape key, Then the sheet closes and only the hamburger button is visible."
# Feature: 008-fix-mobile-sheet-x-button-click-event-not-propagating
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies that the fix for the X button click event does not accidentally suppress
# the Escape key dismiss that Radix Dialog provides natively.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US2.AC1] Testing: Escape key dismiss is not suppressed by the X button fix"

SHEET_FILE="$PROJECT_DIR/src/components/ui/sheet.tsx"
MOBILE_NAV_FILE="$PROJECT_DIR/src/app/components/layout/mobile-nav.tsx"

# 1. Sheet must use the Radix Dialog primitive (which handles Escape natively)
if ! grep -q "Dialog as SheetPrimitive" "$SHEET_FILE"; then
  echo "FAIL: Sheet does not use Radix Dialog primitive — Escape key handling is uncertain" >&2
  echo "  Expected: import { Dialog as SheetPrimitive } from 'radix-ui'" >&2
  echo "  Actual: not found in $SHEET_FILE" >&2
  exit 1
fi

# 2. No onEscapeKeyDown preventDefault in SheetContent
if grep -q "onEscapeKeyDown.*preventDefault" "$SHEET_FILE"; then
  echo "FAIL: SheetContent suppresses Escape key via onEscapeKeyDown preventDefault" >&2
  echo "  Expected: no onEscapeKeyDown preventDefault in $SHEET_FILE" >&2
  echo "  Actual: found — sheet will not close on Escape" >&2
  exit 1
fi

# 3. No onEscapeKeyDown preventDefault in MobileNav
if grep -q "onEscapeKeyDown.*preventDefault" "$MOBILE_NAV_FILE"; then
  echo "FAIL: MobileNav suppresses Escape key on the Sheet" >&2
  echo "  Expected: no onEscapeKeyDown preventDefault in $MOBILE_NAV_FILE" >&2
  echo "  Actual: found — sheet will not close on Escape" >&2
  exit 1
fi

# 4. MobileNav onOpenChange is wired — Radix will call it with false when Escape is pressed
if ! grep -q "onOpenChange={setOpen}" "$MOBILE_NAV_FILE"; then
  echo "FAIL: MobileNav does not wire onOpenChange={setOpen} — Escape dismiss will not update React state" >&2
  echo "  Expected: <Sheet open={open} onOpenChange={setOpen}>" >&2
  echo "  Actual: not found in $MOBILE_NAV_FILE" >&2
  exit 1
fi

echo "PASS: US2.AC1 — Escape key dismiss not suppressed; Radix primitive handles it natively"
exit 0
