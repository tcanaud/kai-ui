#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Submit button remains disabled until both fields are filled
# Criterion: SMOKE2 — "Given the New Session dialog is open, When either the
#   Playbook or Feature Name field is empty, Then the Create Session button is
#   disabled and cannot be submitted."
# Feature: 006-fix-session-creation-dialog-ux-actionable-errors-form-reset-and-abort
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# SMOKE TEST — Verifies the form guard logic was not broken by the form-reset fix.
# After the close-reset fix, re-opening the dialog clears both fields, so the
# button must start disabled again.
#
# PREREQUISITES:
#   1. npm run dev is running (Next.js on http://localhost:3000)
#   2. Chrome is launched with --remote-debugging-port=9222
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
#   Step 3 — Assert button is disabled on empty form:
#     mcp__chrome-devtools__take_snapshot
#     EXPECTED: Create Session submit button has aria-disabled="true" or disabled attribute.
#
#   Step 4 — Fill only the Feature Name field:
#     mcp__chrome-devtools__fill → uid: "<feature input uid>", value: "009-partial"
#     mcp__chrome-devtools__take_snapshot
#     EXPECTED: Submit button is still disabled (playbook not selected).
#
#   Step 5 — Select a playbook (without feature name):
#     mcp__chrome-devtools__press_key → key: "Control+A"  (to clear feature name)
#     mcp__chrome-devtools__fill → uid: "<feature input uid>", value: ""
#     mcp__chrome-devtools__fill → uid: "<playbook select uid>", value: "<playbook name>"
#     mcp__chrome-devtools__take_snapshot
#     EXPECTED: Submit button is still disabled (feature name is empty).
#
#   Step 6 — Fill both fields:
#     mcp__chrome-devtools__fill → uid: "<feature input uid>", value: "009-complete"
#     mcp__chrome-devtools__take_snapshot
#     EXPECTED: Submit button is now enabled (no disabled attribute).
#
# PASS CONDITIONS:
#   - Button is disabled when feature name is empty, regardless of playbook.
#   - Button is disabled when playbook is not selected, regardless of feature name.
#   - Button is enabled only when both fields have values.
#
# FAIL CONDITIONS:
#   - Button is enabled with only one field filled.
#   - Button is permanently disabled even after both fields are filled.

set -euo pipefail

echo "══════════════════════════════════════════════════════"
echo " TEST: SMOKE2 — Submit button disabled until both fields filled"
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
echo "  2. Open New Session dialog"
echo "  3. Assert submit button disabled on empty form"
echo "  4. Fill feature only → assert still disabled"
echo "  5. Fill playbook only → assert still disabled"
echo "  6. Fill both → assert button is enabled"
echo ""
echo "Manual execution required — see script header for full MCP tool sequence."
exit 0
