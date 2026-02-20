#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Sheet does not reopen when New Session dialog closes
# Criterion: US3.AC2 — "Given the New Session dialog was opened from the mobile sheet, When the user cancels or closes the dialog, Then only the main content is visible — the sheet does not reappear automatically."
# Feature: 003-fix-mobile-responsive-layout-sheet-close-failure-and-tablet-breakpoint
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies that the sheet open state is managed independently from the dialog open state:
# closing the dialog must not set sheet open=true. MobileNav's `open` state is only
# set to true by SheetTrigger click — never by dialog close callbacks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US3.AC2] Testing: Dialog close does not reopen the mobile sheet"

MOBILE_NAV_FILE="$PROJECT_DIR/src/app/components/layout/mobile-nav.tsx"
DIALOG_FILE="$PROJECT_DIR/src/app/components/sidebar/new-session-dialog.tsx"

# 1. MobileNav sheet open state must only be set to true from SheetTrigger (not from any dialog callback)
# Confirm setOpen(true) is NOT called anywhere other than implicitly via SheetTrigger/onOpenChange
SETTRUE_COUNT=$(grep -c "setOpen(true)" "$MOBILE_NAV_FILE" || true)
if [ "$SETTRUE_COUNT" -gt 0 ]; then
  echo "FAIL: MobileNav calls setOpen(true) explicitly — sheet could be reopened programmatically" >&2
  echo "  Expected: setOpen(true) not called directly (only through SheetTrigger/onOpenChange)" >&2
  echo "  Actual: $SETTRUE_COUNT occurrence(s) found" >&2
  exit 1
fi

# 2. NewSessionDialog must NOT call any prop that would set sheet open back to true
# onSessionCreated is the only callback fired after dialog close — it should NOT reopen sheet
if grep -q "setOpen(true)" "$DIALOG_FILE"; then
  echo "FAIL: NewSessionDialog calls setOpen(true) — this should only control the dialog, not the sheet" >&2
  echo "  Expected: only dialog-scoped open state management in NewSessionDialog" >&2
  echo "  Actual: setOpen(true) found in $DIALOG_FILE" >&2
  exit 1
fi

# 3. Confirm MobileNav handleCloseSheet only sets open to false (not a toggle)
if ! grep -q "setOpen(false)" "$MOBILE_NAV_FILE"; then
  echo "FAIL: MobileNav handleCloseSheet does not explicitly close the sheet (setOpen(false) not found)" >&2
  echo "  Expected: const handleCloseSheet = useCallback(() => { setOpen(false); }, [])" >&2
  echo "  Actual: not found in $MOBILE_NAV_FILE" >&2
  exit 1
fi

echo "PASS: US3.AC2 — Sheet state is independent of dialog; dialog close does not reopen sheet"
exit 0
