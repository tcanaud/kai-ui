#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: "Connection failed." shown with Retry button after max retries exhausted
# Criterion: US3.AC3 — "Given all reconnection attempts have failed, When the
#   retry limit is reached, Then 'Connection failed.' is shown with a Retry button."
# Feature: 002-fix-terminal-websocket-initial-connection-failure
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# PREREQUISITES:
#   1. npm run dev is running (Next.js on http://localhost:3000)
#   2. Sidecar server is running, then will be stopped and kept stopped
#   3. At least one session exists
#   4. Chrome is launched with --remote-debugging-port=9222
#   5. MAX_RECONNECT_ATTEMPTS = 5, delays: 1s, 2s, 4s, 8s, 16s → total ~31s wait
#
# MCP TOOL SEQUENCE:
#
#   Step 1 — Navigate and verify initial connection:
#     mcp__chrome-devtools__navigate_page → url: "http://localhost:3000"
#     Wait 3000ms.
#     mcp__chrome-devtools__take_snapshot
#     ASSERT: Terminal is connected (live prompt visible).
#
#   Step 2 — Stop the sidecar permanently (do NOT restart it).
#
#   Step 3 — Wait for all retry attempts to exhaust (approximately 31–35 seconds):
#     Poll every 5000ms with: mcp__chrome-devtools__take_snapshot
#     Continue until overlay changes from "Connection lost. Retrying..." to
#     "Connection failed."
#
#   Step 4 — Assert final state:
#     mcp__chrome-devtools__take_snapshot
#     ASSERT: Overlay shows "Connection failed."
#     ASSERT: A "Retry" button is present in the overlay.
#     ASSERT: Animated pulse dots are NOT shown (no active retry in progress).
#
#   Step 5 — Click Retry and verify:
#     mcp__chrome-devtools__click → uid: (Retry button uid from snapshot)
#     ASSERT: Overlay changes to "Connection lost. Retrying..." or "Connecting..."
#     ASSERT: New WebSocket connection attempt is made.
#     mcp__chrome-devtools__list_network_requests → resourceTypes: ["websocket"]
#
# PASS CONDITIONS:
#   - After MAX_RECONNECT_ATTEMPTS (5) failures, "Connection failed." with Retry button shown.
#   - Clicking Retry triggers a new connection cycle.
#   - Pulse dots not shown when in "error" state.
#
# FAIL CONDITIONS:
#   - Terminal stays in "Connection lost. Retrying..." indefinitely.
#   - "Connection failed." shown but no Retry button.
#   - Clicking Retry does not trigger a new WebSocket connection attempt.

set -euo pipefail

echo "══════════════════════════════════════════════════════"
echo " TEST: US3.AC3 — 'Connection failed.' with Retry button after max retries"
echo " Feature: 002-fix-terminal-websocket-initial-connection-failure"
echo "══════════════════════════════════════════════════════"
echo ""
echo "NOTE: This test takes ~35 seconds (5 retries with exponential backoff)."
echo ""

if ! nc -z localhost 3001 2>/dev/null; then
  echo "  [FAIL] Sidecar is NOT running on port 3001" >&2
  exit 1
fi
echo "  [OK] Sidecar port 3001 is open"

if ! curl -sf --max-time 2 http://localhost:3000 > /dev/null 2>&1; then
  echo "  [FAIL] Next.js dev server is NOT running on port 3000" >&2
  exit 1
fi
echo "  [OK] Next.js dev server is reachable on port 3000"

echo ""
echo "Infrastructure checks passed. Proceed with MCP Chrome DevTools steps:"
echo ""
echo "  1. navigate_page → 'http://localhost:3000', wait 3s"
echo "  2. take_snapshot → ASSERT: terminal connected"
echo "  3. [MANUAL] Stop the sidecar server and keep it stopped"
echo "  4. Poll take_snapshot every 5s for ~35s until 'Connection failed.' appears"
echo "  5. take_snapshot → ASSERT: 'Connection failed.' text visible"
echo "               ASSERT: 'Retry' button present in overlay"
echo "               ASSERT: No pulse animation dots"
echo "  6. click Retry button uid"
echo "  7. take_snapshot → ASSERT: overlay changes to 'Connection lost. Retrying...' or 'Connecting...'"
echo "  8. list_network_requests → ASSERT: new WebSocket request initiated"
exit 0
