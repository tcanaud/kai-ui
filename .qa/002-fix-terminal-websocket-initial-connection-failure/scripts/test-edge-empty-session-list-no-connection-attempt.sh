#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Empty session list — no terminal connection attempted, empty state shown
# Criterion: EC3 — "What happens if the session list is empty on first load? No
#   terminal connection should be attempted and no error state should be shown
#   — only the empty state prompting the user to create a session."
# Feature: 002-fix-terminal-websocket-initial-connection-failure
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# PREREQUISITES:
#   1. npm run dev is running (Next.js on http://localhost:3000)
#   2. Sidecar server is running on ws://localhost:3001
#   3. NO sessions exist (empty session list)
#   4. Chrome is launched with --remote-debugging-port=9222
#
# MCP TOOL SEQUENCE:
#
#   Step 1 — Navigate to the application:
#     mcp__chrome-devtools__navigate_page → url: "http://localhost:3000"
#
#   Step 2 — Take snapshot after page loads (wait 2000ms):
#     mcp__chrome-devtools__take_snapshot
#     ASSERT: Terminal panel is NOT rendered.
#     ASSERT: An empty state UI is shown (e.g., "Create a session" prompt).
#     ASSERT: No "Connecting...", "Disconnected", or error overlay visible.
#
#   Step 3 — Verify no WebSocket attempts:
#     mcp__chrome-devtools__list_network_requests → resourceTypes: ["websocket"]
#     ASSERT: Zero WebSocket requests to ws://localhost:3001/terminal/*
#
#   Step 4 — Check console for errors:
#     mcp__chrome-devtools__list_console_messages
#     ASSERT: No WebSocket-related errors in console.
#     ASSERT: No "Cannot connect: no session" type errors.
#
# PASS CONDITIONS:
#   - Terminal panel not rendered when session list is empty.
#   - No WebSocket connection attempted.
#   - No error overlay or message related to connection state.
#   - Empty state UI shown instead.
#
# FAIL CONDITIONS:
#   - Terminal panel renders with an error state (connection failed).
#   - WebSocket request made to an undefined or empty session ID.
#   - Console shows WebSocket errors.

set -euo pipefail

echo "══════════════════════════════════════════════════════"
echo " TEST: EC3 — Empty session list, no terminal connection attempted"
echo " Feature: 002-fix-terminal-websocket-initial-connection-failure"
echo "══════════════════════════════════════════════════════"
echo ""
echo "NOTE: This test requires NO sessions to exist in the application."
echo "      Ensure all sessions are deleted before running."
echo ""

if ! nc -z localhost 3001 2>/dev/null; then
  echo "  [WARN] Sidecar is not running — this is acceptable for this test"
  echo "         (no connection should be attempted regardless)"
fi

if ! curl -sf --max-time 2 http://localhost:3000 > /dev/null 2>&1; then
  echo "  [FAIL] Next.js dev server is NOT running on port 3000" >&2
  exit 1
fi
echo "  [OK] Next.js dev server is reachable on port 3000"

echo ""
echo "Infrastructure checks passed. Proceed with MCP Chrome DevTools steps:"
echo ""
echo "  1. navigate_page → 'http://localhost:3000'"
echo "  2. Wait 2000ms"
echo "  3. take_snapshot"
echo "     ASSERT: Terminal panel NOT rendered"
echo "     ASSERT: Empty state / 'Create a session' UI visible"
echo "     ASSERT: No connection overlay ('Connecting...', 'Connection failed.', etc.)"
echo "  4. list_network_requests → resourceTypes: ['websocket']"
echo "     ASSERT: ZERO WebSocket requests"
echo "  5. list_console_messages"
echo "     ASSERT: No WebSocket errors in console"
exit 0
