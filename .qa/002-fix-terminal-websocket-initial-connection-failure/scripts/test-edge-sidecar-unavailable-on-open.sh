#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Sidecar not running at app open — shows "Connection failed." after retries
# Criterion: EC1 — "What happens when the sidecar is not running at all when the
#   app is opened? The terminal should show 'Connection failed.' with a Retry
#   button after exhausting retries, not an indefinite reconnecting loop."
# Feature: 002-fix-terminal-websocket-initial-connection-failure
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# PREREQUISITES:
#   1. npm run dev is running (Next.js on http://localhost:3000)
#   2. Sidecar server is NOT running (port 3001 closed)
#   3. At least one session exists
#   4. Chrome is launched with --remote-debugging-port=9222
#
# MCP TOOL SEQUENCE:
#
#   Step 1 — Verify sidecar is NOT running before starting:
#     (Bash check: nc -z localhost 3001 should fail)
#
#   Step 2 — Navigate to the application:
#     mcp__chrome-devtools__navigate_page → url: "http://localhost:3000"
#
#   Step 3 — Take snapshot immediately:
#     mcp__chrome-devtools__take_snapshot
#     ASSERT: Overlay shows "Connecting..." (initial state).
#     ASSERT: NOT "Disconnected. Reconnecting..."
#
#   Step 4 — Poll every 5s until "Connection failed." appears (max ~35s):
#     mcp__chrome-devtools__take_snapshot
#     Track overlay progression: "Connecting..." → "Connection lost. Retrying..." → "Connection failed."
#     NOTE: After first failed attempt, state transitions to reconnecting mode.
#           The exact sequence depends on implementation.
#
#   Step 5 — Assert final state:
#     ASSERT: "Connection failed." is shown.
#     ASSERT: Retry button is present.
#     ASSERT: Loop has terminated (not spinning indefinitely).
#
# PASS CONDITIONS:
#   - "Connecting..." shown on initial attempt (not "Disconnected. Reconnecting...").
#   - After MAX_RECONNECT_ATTEMPTS, "Connection failed." with Retry button shown.
#   - No indefinite loop.
#
# FAIL CONDITIONS:
#   - "Disconnected. Reconnecting..." shown during very first connection attempt.
#   - Terminal loops indefinitely without reaching "Connection failed." state.
#   - No Retry button shown on failure.

set -euo pipefail

echo "══════════════════════════════════════════════════════"
echo " TEST: EC1 — Sidecar unavailable at app open"
echo " Feature: 002-fix-terminal-websocket-initial-connection-failure"
echo "══════════════════════════════════════════════════════"
echo ""
echo "NOTE: This test requires the sidecar to be STOPPED before running."
echo ""

# Verify sidecar is NOT running (required for this test)
if nc -z localhost 3001 2>/dev/null; then
  echo "  [SKIP] Sidecar IS running on port 3001." >&2
  echo "  This test requires the sidecar to be stopped." >&2
  echo "  Stop the sidecar and re-run this test." >&2
  exit 1
fi
echo "  [OK] Sidecar is NOT running on port 3001 (expected for this test)"

if ! curl -sf --max-time 2 http://localhost:3000 > /dev/null 2>&1; then
  echo "  [FAIL] Next.js dev server is NOT running on port 3000" >&2
  exit 1
fi
echo "  [OK] Next.js dev server is reachable on port 3000"

echo ""
echo "Prerequisites confirmed. Proceed with MCP Chrome DevTools steps:"
echo ""
echo "  1. navigate_page → 'http://localhost:3000'"
echo "  2. take_snapshot immediately"
echo "     ASSERT: overlay is 'Connecting...' (NOT 'Disconnected. Reconnecting...')"
echo "  3. Poll take_snapshot every 5s for up to 35s"
echo "     Track: 'Connecting...' → (may transition) → 'Connection failed.'"
echo "  4. take_snapshot when 'Connection failed.' appears"
echo "     ASSERT: 'Connection failed.' text visible"
echo "     ASSERT: 'Retry' button present"
echo "     ASSERT: No pulse animation (terminated, not active)"
exit 0
