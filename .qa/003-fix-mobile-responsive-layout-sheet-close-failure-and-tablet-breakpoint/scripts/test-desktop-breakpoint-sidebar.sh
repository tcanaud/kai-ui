#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Desktop 1024px+ shows sidebar, not hamburger
# Criterion: US2.AC2 — "Given the viewport width is 1024px or wider, When the page loads, Then the desktop sidebar is visible and the hamburger button is hidden."
# Feature: 003-fix-mobile-responsive-layout-sheet-close-failure-and-tablet-breakpoint
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies that at lg+ breakpoints the sidebar is displayed and the hamburger is hidden.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US2.AC2] Testing: Desktop sidebar visible and hamburger hidden at 1024px+"

SHELL_FILE="$PROJECT_DIR/src/app/components/layout/responsive-shell.tsx"
MOBILE_NAV_FILE="$PROJECT_DIR/src/app/components/layout/mobile-nav.tsx"

# 1. Desktop sidebar must use lg:flex (makes it visible at 1024px+)
if ! grep -q "lg:flex" "$SHELL_FILE"; then
  echo "FAIL: Desktop sidebar does not use lg:flex — it will not be visible at 1024px+" >&2
  echo "  Expected: className 'hidden lg:flex' (or 'lg:flex') on sidebar wrapper" >&2
  echo "  Actual: lg:flex not found in $SHELL_FILE" >&2
  exit 1
fi

# 2. Hamburger must use lg:hidden (hidden at 1024px+ when sidebar is shown)
if ! grep -q "lg:hidden" "$MOBILE_NAV_FILE"; then
  echo "FAIL: Hamburger button does not use lg:hidden — it will overlap with the desktop sidebar at 1024px+" >&2
  echo "  Expected: lg:hidden on hamburger Button className" >&2
  echo "  Actual: lg:hidden not found in $MOBILE_NAV_FILE" >&2
  exit 1
fi

# 3. MobileNav component is rendered in responsive shell (both coexist, CSS toggles visibility)
if ! grep -q "MobileNav" "$SHELL_FILE"; then
  echo "FAIL: MobileNav is not rendered in ResponsiveShell — hamburger is absent from DOM" >&2
  echo "  Expected: <MobileNav ... /> in responsive-shell.tsx" >&2
  echo "  Actual: MobileNav not found in $SHELL_FILE" >&2
  exit 1
fi

echo "PASS: US2.AC2 — Desktop sidebar visible at lg+ via lg:flex; hamburger hidden via lg:hidden"
exit 0
