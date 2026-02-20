#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Closing the dialog while a session creation request is in-flight aborts the request
# Criterion: REG3 — "Given the user has submitted the New Session form and the API
#   request is in-flight (loading spinner visible), When the user closes the dialog,
#   Then the in-flight fetch request is aborted and no error is displayed after close."
# Feature: 006-fix-session-creation-dialog-ux-actionable-errors-form-reset-and-abort
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# REGRESSION TEST — Bug: closing the dialog mid-request left dangling state updates
# (setError, setLoading) that could fire after unmount or re-open, causing stale
# error banners or console warnings.
#
# Fix location: src/app/components/sidebar/new-session-dialog.tsx
#   - abortControllerRef.current?.abort() called in handleOpenChange when isOpen === false
#   - catch block: if (controller.signal.aborted) return — suppresses error display
#   - finally block: guarded by !controller.signal.aborted — prevents stale setLoading(false)
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
#   Step 2 — Inject a slow fetch interceptor (2 second delay on POST /api/sessions):
#     mcp__chrome-devtools__evaluate_script → function: () => {
#       window.__origFetch = window.fetch;
#       window.fetch = async (input, init) => {
#         if (typeof input === 'string' && input.includes('/api/sessions') && init?.method === 'POST') {
#           return new Promise((resolve, reject) => {
#             const timeout = setTimeout(() => {
#               resolve(new Response(JSON.stringify({ session: {}, output: '' }), {
#                 status: 200, headers: { 'Content-Type': 'application/json' }
#               }));
#             }, 2000);
#             init?.signal?.addEventListener('abort', () => {
#               clearTimeout(timeout);
#               reject(new DOMException('AbortError', 'AbortError'));
#             });
#           });
#         }
#         return window.__origFetch(input, init);
#       };
#     }
#
#   Step 3 — Open the New Session dialog:
#     mcp__chrome-devtools__take_snapshot
#     mcp__chrome-devtools__click → uid: "<New Session button uid>"
#     mcp__chrome-devtools__wait_for → text: "Create Session"
#
#   Step 4 — Fill in form fields and submit:
#     mcp__chrome-devtools__take_snapshot
#     mcp__chrome-devtools__fill → uid: "<feature input uid>", value: "009-abort-test"
#     mcp__chrome-devtools__fill → uid: "<playbook select uid>", value: "<playbook name>"
#     mcp__chrome-devtools__click → uid: "<Create Session submit button uid>"
#
#   Step 5 — Assert loading spinner is visible (request is in-flight):
#     mcp__chrome-devtools__wait_for → text: "Creating..."
#     mcp__chrome-devtools__take_snapshot
#     EXPECTED: Submit button shows "Creating..." with spinner icon.
#
#   Step 6 — Close the dialog while loading (press Escape):
#     mcp__chrome-devtools__press_key → key: "Escape"
#
#   Step 7 — Assert dialog closed and no error exists:
#     mcp__chrome-devtools__take_snapshot
#     EXPECTED: "Create Session" dialog title is no longer in the snapshot.
#     EXPECTED: No error banner appears in the sidebar or anywhere on the page.
#
#   Step 8 — Check console for unexpected errors:
#     mcp__chrome-devtools__list_console_messages
#     EXPECTED: No unhandled error or React state update warning in the console.
#
#   Step 9 — Re-open the dialog to confirm clean state:
#     mcp__chrome-devtools__click → uid: "<New Session button uid>"
#     mcp__chrome-devtools__wait_for → text: "Create Session"
#     mcp__chrome-devtools__take_snapshot
#     EXPECTED: Form is clean — no spinner, no error, empty fields.
#
#   Step 10 — Restore fetch:
#     mcp__chrome-devtools__evaluate_script → function: () => { window.fetch = window.__origFetch; }
#
# PASS CONDITIONS:
#   - Closing the dialog while the spinner is visible closes the dialog cleanly.
#   - No error banner appears after close.
#   - No React "Can't perform a state update on an unmounted component" warning
#     or similar console error.
#   - Re-opening the dialog shows a clean empty form.
#
# FAIL CONDITIONS:
#   - Dialog closes but an error banner briefly flashes.
#   - Console shows an unhandled AbortError or React state warning.
#   - Re-opened dialog retains stale loading state or shows an error.

set -euo pipefail

echo "══════════════════════════════════════════════════════"
echo " TEST: REG3 — Closing dialog aborts in-flight request cleanly"
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
echo "  2. Inject 2s slow fetch interceptor that respects AbortSignal"
echo "  3. Open dialog, fill form, submit — confirm 'Creating...' spinner"
echo "  4. Close dialog with Escape while spinner is visible"
echo "  5. Assert: dialog closed, no error banner, no console errors"
echo "  6. Re-open dialog and assert clean empty form"
echo ""
echo "Manual execution required — see script header for full MCP tool sequence."
exit 0
