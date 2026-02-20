#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: API error details from data.details are surfaced in the dialog error banner
# Criterion: REG1 — "Given the session creation API returns a non-OK response with
#   a JSON body containing a 'details' field, When the user submits the form,
#   Then the error banner displays the text from data.details (not a generic fallback)."
# Feature: 006-fix-session-creation-dialog-ux-actionable-errors-form-reset-and-abort
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# REGRESSION TEST — Bug: error messages showed a generic string instead of the
# actual details from the API error response (data.details).
#
# Fix location: src/app/lib/sessions.ts
#   Before: throw new Error(data.error || "Failed to create session")
#   After:  throw new Error(data.details || data.error || "Failed to create session")
#
# PREREQUISITES:
#   1. npm run dev is running (Next.js on http://localhost:3000)
#   2. Chrome is launched with --remote-debugging-port=9222
#   3. At least one playbook exists (to enable form submission)
#
# MCP TOOL SEQUENCE:
#
#   Step 1 — Navigate to the application:
#     mcp__chrome-devtools__navigate_page → url: "http://localhost:3000"
#
#   Step 2 — Intercept the /api/sessions POST to return a controlled error:
#     mcp__chrome-devtools__evaluate_script → function: () => {
#       window.__origFetch = window.fetch;
#       window.fetch = async (input, init) => {
#         if (typeof input === 'string' && input.includes('/api/sessions') && init?.method === 'POST') {
#           return new Response(
#             JSON.stringify({ error: "Generic error", details: "Playbook 'hotfix2' requires feature branch to exist" }),
#             { status: 422, headers: { 'Content-Type': 'application/json' } }
#           );
#         }
#         return window.__origFetch(input, init);
#       };
#     }
#
#   Step 3 — Take a snapshot to find the "New Session" button:
#     mcp__chrome-devtools__take_snapshot
#
#   Step 4 — Click the "New Session" button (uid from snapshot):
#     mcp__chrome-devtools__click → uid: "<uid of New Session button>"
#
#   Step 5 — Wait for the dialog to open:
#     mcp__chrome-devtools__wait_for → text: "Create Session"
#
#   Step 6 — Fill in the Feature Name field and select a playbook:
#     mcp__chrome-devtools__take_snapshot  (to get field uids)
#     mcp__chrome-devtools__fill → uid: "<feature input uid>", value: "009-test-feature"
#     mcp__chrome-devtools__fill → uid: "<playbook select uid>", value: "<any playbook name>"
#
#   Step 7 — Click the "Create Session" submit button:
#     mcp__chrome-devtools__click → uid: "<Create Session button uid>"
#
#   Step 8 — Wait for the error banner to appear:
#     mcp__chrome-devtools__wait_for → text: "Playbook 'hotfix2' requires feature branch to exist"
#
#   Step 9 — Take a snapshot and assert the error text:
#     mcp__chrome-devtools__take_snapshot
#     EXPECTED: Error banner contains "Playbook 'hotfix2' requires feature branch to exist"
#     ACTUAL: Observe the snapshot output.
#
#   Step 10 — Restore fetch:
#     mcp__chrome-devtools__evaluate_script → function: () => { window.fetch = window.__origFetch; }
#
# PASS CONDITIONS:
#   - Error banner displays "Playbook 'hotfix2' requires feature branch to exist"
#     (the value from data.details), NOT "Generic error" (data.error) or
#     "Failed to create session" (generic fallback).
#
# FAIL CONDITIONS:
#   - Error banner shows "Generic error" — indicates data.details was ignored.
#   - Error banner shows "Failed to create session" — indicates full regression.
#   - No error banner appears at all.

set -euo pipefail

echo "══════════════════════════════════════════════════════"
echo " TEST: REG1 — Error banner surfaces data.details from API"
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
echo "  2. Inject fetch interceptor that returns 422 with { error: 'Generic error', details: 'Playbook...' }"
echo "  3. Open New Session dialog, fill form, submit"
echo "  4. Assert error banner shows the value from data.details"
echo ""
echo "Manual execution required — see script header for full MCP tool sequence."
exit 0
