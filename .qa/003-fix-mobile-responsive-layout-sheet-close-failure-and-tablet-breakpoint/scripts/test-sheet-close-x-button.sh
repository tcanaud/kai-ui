#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Mobile sheet X close button is wired up
# Criterion: US1.AC1 — "Given the mobile nav sheet is open, When the user clicks the X close button inside the sheet, Then the sheet closes and only the hamburger button is visible."
# Feature: 003-fix-mobile-responsive-layout-sheet-close-failure-and-tablet-breakpoint
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies that SheetContent renders a close button (showCloseButton=true by default)
# and that MobileNav wires Sheet open state via onOpenChange.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US1.AC1] Testing: Sheet X close button is present and wired"

SHEET_FILE="$PROJECT_DIR/src/components/ui/sheet.tsx"
MOBILE_NAV_FILE="$PROJECT_DIR/src/app/components/layout/mobile-nav.tsx"

# 1. SheetContent must render a close button by default
if ! grep -q "SheetPrimitive.Close" "$SHEET_FILE"; then
  echo "FAIL: SheetContent does not render a close button (SheetPrimitive.Close not found)" >&2
  echo "  Expected: SheetPrimitive.Close inside SheetContent" >&2
  echo "  Actual: not found in $SHEET_FILE" >&2
  exit 1
fi

# 2. SheetContent default showCloseButton must be true
if ! grep -q "showCloseButton = true" "$SHEET_FILE"; then
  echo "FAIL: showCloseButton default is not true in SheetContent" >&2
  echo "  Expected: showCloseButton = true" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 3. MobileNav must pass onOpenChange to Sheet so the close button can update state
if ! grep -q "onOpenChange={setOpen}" "$MOBILE_NAV_FILE"; then
  echo "FAIL: MobileNav does not wire onOpenChange={setOpen} on Sheet" >&2
  echo "  Expected: <Sheet open={open} onOpenChange={setOpen}>" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

echo "PASS: US1.AC1 — Sheet X close button present and open state wired correctly"
exit 0
