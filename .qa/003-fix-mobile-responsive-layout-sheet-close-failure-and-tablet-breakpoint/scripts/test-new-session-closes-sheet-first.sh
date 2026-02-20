#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: New Session from mobile sheet closes sheet before dialog opens
# Criterion: US3.AC1 — "Given the mobile nav sheet is open, When the user taps 'New Session', Then the sheet closes before the New Session dialog opens (no simultaneous sheet + dialog)."
# Feature: 003-fix-mobile-responsive-layout-sheet-close-failure-and-tablet-breakpoint
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies that NewSessionDialog has an onBeforeOpen prop wired from MobileNav,
# and that MobileNav passes handleCloseSheet as onBeforeOpen so the sheet is
# dismissed synchronously before the dialog mounts.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US3.AC1] Testing: New Session closes the mobile sheet before opening dialog"

MOBILE_NAV_FILE="$PROJECT_DIR/src/app/components/layout/mobile-nav.tsx"
DIALOG_FILE="$PROJECT_DIR/src/app/components/sidebar/new-session-dialog.tsx"
SIDEBAR_FILE="$PROJECT_DIR/src/app/components/sidebar/session-sidebar.tsx"

# 1. NewSessionDialog must accept onBeforeOpen prop
if ! grep -q "onBeforeOpen" "$DIALOG_FILE"; then
  echo "FAIL: NewSessionDialog does not have an onBeforeOpen prop" >&2
  echo "  Expected: onBeforeOpen?: () => void in NewSessionDialogProps" >&2
  echo "  Actual: onBeforeOpen not found in $DIALOG_FILE" >&2
  exit 1
fi

# 2. NewSessionDialog must call onBeforeOpen when opening
if ! grep -q "onBeforeOpen?.()" "$DIALOG_FILE"; then
  echo "FAIL: NewSessionDialog does not call onBeforeOpen on open" >&2
  echo "  Expected: onBeforeOpen?.() called in handleOpenChange when isOpen=true" >&2
  echo "  Actual: not found in $DIALOG_FILE" >&2
  exit 1
fi

# 3. SessionSidebar must accept and thread onNavigate (or equivalent) down to NewSessionDialog
if ! grep -q "onNavigate" "$SIDEBAR_FILE"; then
  echo "FAIL: SessionSidebar does not accept an onNavigate prop to thread to NewSessionDialog" >&2
  echo "  Expected: onNavigate prop passed to NewSessionDialog as onBeforeOpen" >&2
  echo "  Actual: onNavigate not found in $SIDEBAR_FILE" >&2
  exit 1
fi

# 4. MobileNav must pass handleCloseSheet as onNavigate to SessionSidebar
if ! grep -q "onNavigate={handleCloseSheet}" "$MOBILE_NAV_FILE"; then
  echo "FAIL: MobileNav does not pass handleCloseSheet as onNavigate to SessionSidebar" >&2
  echo "  Expected: onNavigate={handleCloseSheet} on <SessionSidebar>" >&2
  echo "  Actual: not found in $MOBILE_NAV_FILE" >&2
  exit 1
fi

echo "PASS: US3.AC1 — onBeforeOpen chain verified: MobileNav.handleCloseSheet → SessionSidebar.onNavigate → NewSessionDialog.onBeforeOpen"
exit 0
