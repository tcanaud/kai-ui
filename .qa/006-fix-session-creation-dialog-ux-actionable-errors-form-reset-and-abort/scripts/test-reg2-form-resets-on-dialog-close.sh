#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Form state is fully reset when the dialog is closed
# Criterion: REG2 — "Given the New Session dialog is open and the user has filled
#   in the Feature Name field and selected a Playbook, When the user closes the
#   dialog without submitting, Then re-opening the dialog shows empty fields with
#   no error banner and no loading spinner."
# Feature: 006-fix-session-creation-dialog-ux-actionable-errors-form-reset-and-abort
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# REGRESSION TEST — Bug: closing the dialog left stale form values (selectedPlaybook,
# featureName) and stale error state visible when the dialog was reopened.
#
# Fix location: src/app/components/sidebar/new-session-dialog.tsx
#   handleOpenChange now calls setSelectedPlaybook(""), setFeatureName(""),
#   setError(null), setLoading(false) when isOpen === false.
#
# PREREQUISITES:
#   1. npm run dev is running (Next.js on http://localhost:3000)
#   2. Chrome is launched with --remote-debugging-port=9222
#   3. At least one playbook exists
#
# MCP TOOL SEQUENCE:
#
#   Step 1 — Navigate to the application:
#     mcp__chrome-devtools__navigate_page → url: "http://localhost:3000"
#
#   Step 2 — Open the New Session dialog:
#     mcp__chrome-devtools__take_snapshot
#     mcp__chrome-devtools__click → uid: "<New Session button uid>"
#     mcp__chrome-devtools__wait_for → text: "Create Session"
#
#   Step 3 — Fill in the Feature Name field:
#     mcp__chrome-devtools__take_snapshot
#     mcp__chrome-devtools__fill → uid: "<feature input uid>", value: "999-stale-state-test"
#
#   Step 4 — Close the dialog using the X button or pressing Escape:
#     mcp__chrome-devtools__press_key → key: "Escape"
#
#   Step 5 — Wait for dialog to close (snapshot should no longer show "Create Session"):
#     mcp__chrome-devtools__take_snapshot
#     Assert: "Create Session" dialog title is not present in snapshot.
#
#   Step 6 — Re-open the dialog:
#     mcp__chrome-devtools__click → uid: "<New Session button uid>"
#     mcp__chrome-devtools__wait_for → text: "Create Session"
#
#   Step 7 — Take snapshot and assert form is clean:
#     mcp__chrome-devtools__take_snapshot
#     EXPECTED: Feature Name input value is empty (placeholder visible: "e.g., 018-new-feature")
#     EXPECTED: Playbook select shows placeholder "Select a playbook..."
#     EXPECTED: No error banner is visible
#     EXPECTED: Submit button shows "Create Session" (not "Creating...")
#     ACTUAL: Observe the snapshot output.
#
# PASS CONDITIONS:
#   - Feature Name field is empty on re-open.
#   - Playbook select shows the default placeholder.
#   - No error banner is rendered.
#   - No loading spinner is active (button text is "Create Session", not "Creating...").
#
# FAIL CONDITIONS:
#   - Feature Name field still contains "999-stale-state-test".
#   - Playbook select retains the previously selected value.
#   - An error banner is visible without the user having submitted.
#   - Loading spinner is still showing.

set -euo pipefail

echo "══════════════════════════════════════════════════════"
echo " TEST: REG2 — Form state resets when dialog is closed"
echo " Feature: 006-fix-session-creation-dialog-ux-actionable-errors-form-reset-and-abort"
echo "══════════════════════════════════════════════════════"
echo ""

# Verify Next.js is running
if ! curl -sf --max-time 2 http://localhost:3000 > /dev/null 2>&1; then
  echo "  [FAIL] Next.js dev server is NOT running on port 3000" >&2
  echo "  EXPECTED: HTTP 200 from http://localhost:3000" >&2
  echo "  ACTUAL: Connection refused or timeout on port 3000" >&2
  exit 1
fi
echo "  [OK] Next.js dev server is reachable on port 3000"
echo ""
echo "Infrastructure checks passed. Proceed with MCP Chrome DevTools steps:"
echo ""
echo "  1. Navigate to http://localhost:3000"
echo "  2. Open dialog, type '999-stale-state-test' in Feature Name, close with Escape"
echo "  3. Re-open dialog"
echo "  4. Assert: Feature Name is empty, playbook shows placeholder, no error, no spinner"
echo ""
echo "Manual execution required — see script header for full MCP tool sequence."
exit 0
