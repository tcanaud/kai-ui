#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: No WebSocket attempt when session ID not yet resolved
# Criterion: EC2 — "What happens when a session ID is not yet resolved at the
#   time the terminal panel mounts? The terminal must wait until a valid session
#   ID is available before attempting any connection."
# Feature: 002-fix-terminal-websocket-initial-connection-failure
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# PREREQUISITES:
#   1. npm run dev is running (Next.js on http://localhost:3000)
#   2. Sidecar server is running on ws://localhost:3001
#   3. Network throttling available via MCP emulate
#   4. Chrome is launched with --remote-debugging-port=9222
#
# APPROACH: Simulate slow session API response using network throttling
# to observe whether the terminal tries to connect before session ID is known.
#
# MCP TOOL SEQUENCE:
#
#   Step 1 — Apply network throttling to slow down API calls:
#     mcp__chrome-devtools__emulate → networkConditions: "Slow 3G"
#
#   Step 2 — Navigate to the application:
#     mcp__chrome-devtools__navigate_page → url: "http://localhost:3000", ignoreCache: true
#
#   Step 3 — Immediately monitor WebSocket requests (before API response):
#     mcp__chrome-devtools__list_network_requests → resourceTypes: ["websocket"]
#     ASSERT: No WebSocket request to ws://localhost:3001/terminal/* has been
#             initiated yet (session ID not yet available).
#
#   Step 4 — Take snapshot within 500ms:
#     mcp__chrome-devtools__take_snapshot
#     ASSERT: Terminal panel is NOT attempting a connection with an empty/null session ID.
#     ASSERT: If overlay visible, it shows nothing or "Connecting..." only after session resolves.
#
#   Step 5 — Restore network conditions:
#     mcp__chrome-devtools__emulate → networkConditions: "No emulation"
#
#   Step 6 — Wait for session API to respond and terminal to connect:
#     Wait 5000ms.
#     mcp__chrome-devtools__list_network_requests → resourceTypes: ["websocket"]
#     ASSERT: WebSocket request appears only after session data was fetched.
#     mcp__chrome-devtools__take_snapshot
#     ASSERT: Terminal connects successfully.
#
# PASS CONDITIONS:
#   - No WebSocket request to an empty or "undefined" session ID endpoint.
#   - WebSocket connection only initiated after session data is available.
#   - Terminal connects successfully once session is resolved.
#
# FAIL CONDITIONS:
#   - WebSocket request to ws://localhost:3001/terminal/undefined or
#     ws://localhost:3001/terminal/ before session data loads.
#   - Terminal enters error state due to premature connection attempt.

set -euo pipefail

echo "══════════════════════════════════════════════════════"
echo " TEST: EC2 — No WebSocket attempt with unresolved session ID"
echo " Feature: 002-fix-terminal-websocket-initial-connection-failure"
echo "══════════════════════════════════════════════════════"
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
echo "  1. emulate → networkConditions: 'Slow 3G'  (simulate slow session API)"
echo "  2. navigate_page → 'http://localhost:3000', ignoreCache: true"
echo "  3. list_network_requests → resourceTypes: ['websocket']"
echo "     ASSERT: NO WebSocket request yet (session not loaded)"
echo "     ASSERT: No request to 'ws://localhost:3001/terminal/undefined'"
echo "  4. take_snapshot"
echo "     ASSERT: No premature connection attempt visible"
echo "  5. emulate → networkConditions: 'No emulation'"
echo "  6. Wait 5s for session to load"
echo "  7. list_network_requests → resourceTypes: ['websocket']"
echo "     ASSERT: WebSocket request appears (with valid session ID, not 'undefined')"
echo "  8. take_snapshot → ASSERT: terminal connected"
exit 0
