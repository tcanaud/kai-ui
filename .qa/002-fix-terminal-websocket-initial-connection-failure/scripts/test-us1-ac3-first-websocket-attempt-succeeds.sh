#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: WebSocket connects on first attempt without falling into reconnection loop
# Criterion: US1.AC3 — "Given the sidecar server is running and a session is
#   pre-selected on load, When the terminal panel mounts, Then the WebSocket
#   connection is established successfully on the first attempt without falling
#   into the reconnection loop."
# Feature: 002-fix-terminal-websocket-initial-connection-failure
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# PREREQUISITES:
#   1. npm run dev is running (Next.js on http://localhost:3000)
#   2. Sidecar server is running on ws://localhost:3001
#   3. At least one session exists
#   4. Chrome is launched with --remote-debugging-port=9222
#
# MCP TOOL SEQUENCE:
#
#   Step 1 — Navigate to the application:
#     mcp__chrome-devtools__navigate_page → url: "http://localhost:3000", ignoreCache: true
#
#   Step 2 — Monitor network requests for WebSocket connections:
#     mcp__chrome-devtools__list_network_requests → resourceTypes: ["websocket"]
#     Record the initial set of WebSocket requests.
#
#   Step 3 — Wait 3000ms for connection to establish.
#
#   Step 4 — Check WebSocket requests again:
#     mcp__chrome-devtools__list_network_requests → resourceTypes: ["websocket"]
#     ASSERT: Exactly ONE WebSocket connection is established (status 101 Switching Protocols).
#     ASSERT: No subsequent WebSocket connections exist (which would indicate reconnection
#             loop — multiple WS requests to the same endpoint).
#
#   Step 5 — Check console for reconnection log messages:
#     mcp__chrome-devtools__list_console_messages
#     ASSERT: No console messages indicate reconnection attempts (e.g., "reconnect",
#             "retry", attempt count messages).
#
#   Step 6 — Take snapshot and verify state:
#     mcp__chrome-devtools__take_snapshot
#     ASSERT: Terminal panel is in "connected" state (no overlay visible, or terminal
#             content is visible).
#
# PASS CONDITIONS:
#   - Only one WebSocket upgrade request to ws://localhost:3001/terminal/{sessionId}
#   - That single connection has status 101 (established)
#   - No evidence of reconnection loop (multiple WS requests or reconnect log messages)
#   - Terminal panel shows content (not reconnecting overlay)
#
# FAIL CONDITIONS:
#   - Multiple WebSocket connections to the same endpoint (reconnection loop)
#   - WebSocket connection has non-101 status
#   - Console shows reconnection attempt messages
#   - Terminal stuck in "reconnecting" state

set -euo pipefail

echo "══════════════════════════════════════════════════════"
echo " TEST: US1.AC3 — First WebSocket attempt succeeds, no reconnection loop"
echo " Feature: 002-fix-terminal-websocket-initial-connection-failure"
echo "══════════════════════════════════════════════════════"
echo ""

# Infrastructure checks
if ! nc -z localhost 3001 2>/dev/null; then
  echo "  [FAIL] Sidecar is NOT running on port 3001" >&2
  echo "  EXPECTED: Sidecar listening on ws://localhost:3001" >&2
  echo "  ACTUAL: Connection refused on port 3001" >&2
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
echo "  1. navigate_page → url: 'http://localhost:3000', ignoreCache: true"
echo "  2. list_network_requests → resourceTypes: ['websocket'] (baseline)"
echo "  3. Wait ~3000ms"
echo "  4. list_network_requests → resourceTypes: ['websocket']"
echo "     ASSERT: Exactly 1 WebSocket connection, status 101"
echo "     ASSERT: No duplicate WS requests to the same /terminal/{id} endpoint"
echo "  5. list_console_messages"
echo "     ASSERT: No reconnection attempt log messages"
echo "  6. take_snapshot"
echo "     ASSERT: No reconnection overlay visible in terminal panel"
exit 0
