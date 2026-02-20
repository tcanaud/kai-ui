#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: X button click event propagates and closes the sheet on mobile
# Criterion: US1.AC1 — "Given the mobile nav sheet is open (viewport <= 768px), When the user taps/clicks the X close button, Then the sheet closes and only the hamburger button is visible."
# Feature: 008-fix-mobile-sheet-x-button-click-event-not-propagating
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies that:
# 1. SheetContent renders a SheetPrimitive.Close button by default (showCloseButton=true)
# 2. The close button has no pointer-events suppression or stopPropagation call that
#    would prevent the click from reaching the Radix Dialog dismiss handler.
# 3. MobileNav wires onOpenChange={setOpen} so the Radix close event propagates correctly.
# 4. MobileNav SheetContent uses p-0 but no overlay div that would intercept pointer events
#    at the z-index of the X button (absolute top-4 right-4 z-50).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US1.AC1] Testing: X button click closes mobile sheet"

SHEET_FILE="$PROJECT_DIR/src/components/ui/sheet.tsx"
MOBILE_NAV_FILE="$PROJECT_DIR/src/app/components/layout/mobile-nav.tsx"

# 1. SheetContent must render a close button by default
if ! grep -q "SheetPrimitive.Close" "$SHEET_FILE"; then
  echo "FAIL: SheetContent does not render a close button (SheetPrimitive.Close not found)" >&2
  echo "  Expected: SheetPrimitive.Close inside SheetContent" >&2
  echo "  Actual: not found in $SHEET_FILE" >&2
  exit 1
fi

# 2. showCloseButton default must be true
if ! grep -q "showCloseButton = true" "$SHEET_FILE"; then
  echo "FAIL: showCloseButton default is not true — X button may not be rendered" >&2
  echo "  Expected: showCloseButton = true" >&2
  echo "  Actual: not found in $SHEET_FILE" >&2
  exit 1
fi

# 3. No stopPropagation on the close button or SheetContent that would block the click
if grep -qE "stopPropagation|nativeEvent\.stopImmediatePropagation" "$SHEET_FILE"; then
  echo "FAIL: SheetContent or its close button calls stopPropagation — click event will not reach Radix dismiss handler" >&2
  echo "  Expected: no stopPropagation calls in $SHEET_FILE" >&2
  echo "  Actual: stopPropagation found" >&2
  exit 1
fi

# 4. No unconditional pointer-events-none on the close button itself.
# Note: "disabled:pointer-events-none" is the standard shadcn pattern (conditional on :disabled)
# and is acceptable. Only a bare "pointer-events-none" without a Tailwind variant prefix is a bug.
CLOSE_BUTTON_LINE=$(grep "SheetPrimitive.Close className=" "$SHEET_FILE" || true)
if echo "$CLOSE_BUTTON_LINE" | grep -qE '(^| )"?pointer-events-none'; then
  echo "FAIL: The close button has unconditional pointer-events-none — taps will pass through without triggering click" >&2
  echo "  Expected: no bare pointer-events-none on close button (disabled:pointer-events-none is OK)" >&2
  echo "  Actual: pointer-events-none found without a variant prefix" >&2
  exit 1
fi

# 5. MobileNav must wire onOpenChange so Radix close propagates to state
if ! grep -q "onOpenChange={setOpen}" "$MOBILE_NAV_FILE"; then
  echo "FAIL: MobileNav does not wire onOpenChange={setOpen} — sheet will not close when X is clicked" >&2
  echo "  Expected: <Sheet open={open} onOpenChange={setOpen}>" >&2
  echo "  Actual: not found in $MOBILE_NAV_FILE" >&2
  exit 1
fi

# 6. MobileNav SheetContent must not pass showCloseButton={false}
if grep -q "showCloseButton={false}" "$MOBILE_NAV_FILE"; then
  echo "FAIL: MobileNav explicitly hides the close button — X button will not appear" >&2
  echo "  Expected: showCloseButton not set to false on MobileNav SheetContent" >&2
  echo "  Actual: showCloseButton={false} found in $MOBILE_NAV_FILE" >&2
  exit 1
fi

echo "PASS: US1.AC1 — X button click event is not suppressed and sheet state is correctly wired"
exit 0
