#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Successful session creation still works end-to-end after the fix
# Criterion: SMOKE1 — "Given the New Session dialog is open and the API is healthy,
#   When the user fills in a valid Playbook and Feature Name and submits,
#   Then the session is created, the dialog closes, and the session list refreshes."
# Feature: 006-fix-session-creation-dialog-ux-actionable-errors-form-reset-and-abort
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# SMOKE TEST — Verifies the happy path is not broken by the 3 bug fixes.
#
# PREREQUISITES:
#   1. npm run dev is running (Next.js on http://localhost:3000)
#   2. Sidecar server is running and healthy
#   3. Chrome is launched with --remote-debugging-port=9222
#   4. At least one playbook is available
#
# MCP TOOL SEQUENCE:
#
#   Step 1 — Navigate to the application:
#     mcp__chrome-devtools__navigate_page → url: "http://localhost:3000"
#
#   Step 2 — Note the current number of sessions in the sidebar (baseline).
#     mcp__chrome-devtools__take_snapshot
#     Count session list items visible in sidebar.
#
#   Step 3 — Open the New Session dialog:
#     mcp__chrome-devtools__click → uid: "<New Session button uid>"
#     mcp__chrome-devtools__wait_for → text: "Create Session"
#
#   Step 4 — Fill in both fields:
#     mcp__chrome-devtools__take_snapshot
#     mcp__chrome-devtools__fill → uid: "<playbook select uid>", value: "<valid playbook name>"
#     mcp__chrome-devtools__fill → uid: "<feature input uid>", value: "006-smoke-test"
#
#   Step 5 — Submit the form:
#     mcp__chrome-devtools__click → uid: "<Create Session button uid>"
#
#   Step 6 — Assert loading state:
#     mcp__chrome-devtools__wait_for → text: "Creating..."
#
#   Step 7 — Wait for dialog to close (success path):
#     Wait up to 10 seconds for the dialog to close (poll with take_snapshot).
#     EXPECTED: Dialog with "Create Session" title is no longer in the snapshot.
#
#   Step 8 — Assert session list updated:
#     mcp__chrome-devtools__take_snapshot
#     EXPECTED: Sidebar session list has one more item than the baseline count.
#
#   Step 9 — Assert no error banner anywhere:
#     EXPECTED: No error text is visible in the UI.
#
# PASS CONDITIONS:
#   - Dialog closes automatically after successful creation.
#   - Sidebar session list shows the newly created session.
#   - No error banner is displayed.
#   - No console errors.
#
# FAIL CONDITIONS:
#   - Dialog stays open after API returns 200.
#   - Session list does not refresh.
#   - An error banner appears despite API success.

set -euo pipefail

echo "══════════════════════════════════════════════════════"
echo " TEST: SMOKE1 — Happy path: successful session creation"
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

# Check sidecar is reachable
if nc -z localhost 3001 2>/dev/null; then
  echo "  [OK] Sidecar port 3001 is open"
else
  echo "  [WARN] Sidecar port 3001 not detected — test may not complete full happy path"
fi

echo ""
echo "Infrastructure checks passed. Proceed with MCP Chrome DevTools steps:"
echo ""
echo "  1. Navigate to http://localhost:3000"
echo "  2. Count current session list items (baseline)"
echo "  3. Open dialog, select playbook, enter '006-smoke-test', submit"
echo "  4. Assert 'Creating...' spinner, then dialog closes"
echo "  5. Assert session list count increased by 1"
echo "  6. Assert no console errors"
echo ""
echo "Manual execution required — see script header for full MCP tool sequence."
exit 0
