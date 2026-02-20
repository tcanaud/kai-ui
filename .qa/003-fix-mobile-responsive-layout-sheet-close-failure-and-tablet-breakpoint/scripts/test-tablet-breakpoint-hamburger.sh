#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Tablet 768px shows hamburger, not desktop sidebar
# Criterion: US2.AC1 — "Given the viewport width is 768px, When the page loads, Then the hamburger button is visible and the desktop sidebar is hidden."
# Feature: 003-fix-mobile-responsive-layout-sheet-close-failure-and-tablet-breakpoint
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies that the desktop sidebar uses `lg:flex` (hidden below 1024px) and the
# hamburger trigger uses `lg:hidden` — meaning at 768px (md breakpoint) the sidebar
# is hidden and the hamburger is visible.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US2.AC1] Testing: Desktop sidebar hidden and hamburger visible at tablet (768px)"

SHELL_FILE="$PROJECT_DIR/src/app/components/layout/responsive-shell.tsx"
MOBILE_NAV_FILE="$PROJECT_DIR/src/app/components/layout/mobile-nav.tsx"

# 1. Desktop sidebar must use lg: prefix (hidden below 1024px — covers 768px tablet)
if ! grep -q "lg:flex" "$SHELL_FILE"; then
  echo "FAIL: Desktop sidebar does not use lg:flex — it may be visible at tablet widths" >&2
  echo "  Expected: className including 'hidden lg:flex' on the sidebar wrapper" >&2
  echo "  Actual: lg:flex not found in $SHELL_FILE" >&2
  exit 1
fi

if ! grep -q "hidden lg:" "$SHELL_FILE"; then
  echo "FAIL: Desktop sidebar wrapper does not have 'hidden' class — it will always be visible" >&2
  echo "  Expected: 'hidden lg:flex' (or similar) on sidebar wrapper div" >&2
  echo "  Actual: 'hidden lg:' pattern not found in $SHELL_FILE" >&2
  exit 1
fi

# 2. Hamburger trigger must use lg:hidden (hidden at 1024px+, visible below)
if ! grep -q "lg:hidden" "$MOBILE_NAV_FILE"; then
  echo "FAIL: Hamburger button does not use lg:hidden — it may be visible alongside the desktop sidebar at wide viewports" >&2
  echo "  Expected: className including 'lg:hidden' on the hamburger Button" >&2
  echo "  Actual: lg:hidden not found in $MOBILE_NAV_FILE" >&2
  exit 1
fi

# 3. No md: breakpoint on the desktop sidebar (which would make it appear at 768px)
if grep -q "md:flex" "$SHELL_FILE"; then
  echo "FAIL: Desktop sidebar uses md:flex — it will be visible at 768px (tablet)" >&2
  echo "  Expected: no md:flex on the sidebar wrapper" >&2
  echo "  Actual: md:flex found in $SHELL_FILE" >&2
  exit 1
fi

echo "PASS: US2.AC1 — Desktop sidebar hidden below lg (1024px); hamburger visible at 768px"
exit 0
