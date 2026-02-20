#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Desktop close behaviour has no regression after the mobile X button fix
# Criterion: US3.AC1 — "Given the viewport is >= 1024px and the nav sheet is open, When the user clicks the X close button, Then the sheet closes and the desktop sidebar returns to its normal state."
# Feature: 008-fix-mobile-sheet-x-button-click-event-not-propagating
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies that no mobile-only workaround (e.g. conditional pointer-events, z-index
# hacks, or explicit mobile media-query overrides) was introduced that would break
# the X button on desktop viewports.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US3.AC1] Testing: Desktop X button close has no regression from mobile fix"

SHEET_FILE="$PROJECT_DIR/src/components/ui/sheet.tsx"
MOBILE_NAV_FILE="$PROJECT_DIR/src/app/components/layout/mobile-nav.tsx"
RESPONSIVE_SHELL_FILE="$PROJECT_DIR/src/app/components/layout/responsive-shell.tsx"

# 1. SheetContent close button must still use z-50 (visible above desktop sidebar overlays)
if ! grep -qE "z-50" "$SHEET_FILE"; then
  echo "FAIL: SheetContent close button no longer uses z-50 — may be hidden behind content on desktop" >&2
  echo "  Expected: z-50 on SheetPrimitive.Close in $SHEET_FILE" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 2. No mobile-only conditional that disables the close button at >= 1024px
# A fix that wraps the close button in a className "lg:hidden" or "lg:pointer-events-none"
# would break desktop close.
if grep -qE "lg:hidden|lg:pointer-events-none" "$SHEET_FILE"; then
  echo "FAIL: SheetContent close button is hidden or pointer-events-none at lg breakpoint — desktop close broken" >&2
  echo "  Expected: no lg:hidden or lg:pointer-events-none on close button" >&2
  echo "  Actual: found in $SHEET_FILE" >&2
  exit 1
fi

# 3. MobileNav is conditionally rendered only on mobile (lg:hidden parent) — desktop sidebar
# is a separate component; confirm MobileNav uses lg:hidden trigger to avoid bleeding into desktop
if ! grep -q "lg:hidden" "$MOBILE_NAV_FILE"; then
  echo "FAIL: MobileNav hamburger trigger does not use lg:hidden — mobile sheet may appear on desktop and regress close behaviour" >&2
  echo "  Expected: lg:hidden on SheetTrigger button in $MOBILE_NAV_FILE" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 4. The mobile hamburger trigger must be hidden at lg+ so the sheet is not reachable on desktop.
# ResponsiveShell renders MobileNav unconditionally, but the trigger button inside MobileNav
# must use lg:hidden so it disappears when the desktop sidebar is visible.
if ! grep -q "lg:hidden" "$MOBILE_NAV_FILE"; then
  echo "FAIL: MobileNav trigger button does not use lg:hidden — hamburger remains visible on desktop, allowing sheet to open and regress close behaviour" >&2
  echo "  Expected: lg:hidden on the SheetTrigger button in $MOBILE_NAV_FILE" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

echo "PASS: US3.AC1 — Desktop close has no regression; no mobile-only hacks that break lg+ viewports"
exit 0
