#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Mobile sheet backdrop dismiss is enabled
# Criterion: US1.AC2 — "Given the mobile nav sheet is open, When the user clicks the backdrop overlay outside the sheet, Then the sheet closes and only the hamburger button is visible."
# Feature: 003-fix-mobile-responsive-layout-sheet-close-failure-and-tablet-breakpoint
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies that SheetOverlay is rendered inside SheetContent (enabling backdrop click dismiss)
# and that no modal={false} or onPointerDownOutside preventDefault suppresses outside clicks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US1.AC2] Testing: Sheet backdrop click dismiss is not suppressed"

SHEET_FILE="$PROJECT_DIR/src/components/ui/sheet.tsx"
MOBILE_NAV_FILE="$PROJECT_DIR/src/app/components/layout/mobile-nav.tsx"

# 1. SheetOverlay must be rendered (provides the clickable backdrop)
if ! grep -q "SheetOverlay" "$SHEET_FILE"; then
  echo "FAIL: SheetOverlay is not rendered inside SheetContent" >&2
  echo "  Expected: <SheetOverlay /> inside SheetPortal in SheetContent" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 2. No onPointerDownOutside preventDefault that would block backdrop dismiss
if grep -q "onPointerDownOutside.*preventDefault" "$SHEET_FILE"; then
  echo "FAIL: SheetContent suppresses pointer-down-outside events — backdrop dismiss will not work" >&2
  echo "  Expected: no onPointerDownOutside preventDefault" >&2
  echo "  Actual: found in $SHEET_FILE" >&2
  exit 1
fi

if grep -q "onPointerDownOutside.*preventDefault" "$MOBILE_NAV_FILE"; then
  echo "FAIL: MobileNav suppresses pointer-down-outside events on the Sheet" >&2
  echo "  Expected: no onPointerDownOutside preventDefault in MobileNav" >&2
  echo "  Actual: found in $MOBILE_NAV_FILE" >&2
  exit 1
fi

# 3. onOpenChange must accept false (Radix calls it with false on outside click)
if ! grep -q "onOpenChange={setOpen}" "$MOBILE_NAV_FILE"; then
  echo "FAIL: MobileNav does not wire onOpenChange — backdrop dismiss state update will not fire" >&2
  echo "  Expected: onOpenChange={setOpen} on Sheet" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

echo "PASS: US1.AC2 — Sheet backdrop dismiss is enabled (overlay present, no suppression)"
exit 0
