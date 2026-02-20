#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: "Disconnected. Reconnecting..." overlay is never shown on initial load
# Criterion: US1.AC2 — "Given the sidecar server is running and healthy, When a
#   user navigates to the application URL, Then the 'Disconnected. Reconnecting...'
#   overlay is never displayed during the initial connection sequence."
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
#   Step 1 — Navigate (hard reload) to trigger fresh initial load:
#     mcp__chrome-devtools__navigate_page → url: "http://localhost:3000", ignoreCache: true
#
#   Step 2 — Immediately take snapshot (within ~100ms of navigation):
#     mcp__chrome-devtools__take_snapshot
#     ASSERT: Snapshot does NOT contain the text "Disconnected. Reconnecting..."
#
#   Step 3 — Take snapshot at ~500ms:
#     Wait 500ms, then: mcp__chrome-devtools__take_snapshot
#     ASSERT: Snapshot does NOT contain "Disconnected. Reconnecting..."
#
#   Step 4 — Take snapshot at ~1000ms:
#     Wait 500ms, then: mcp__chrome-devtools__take_snapshot
#     ASSERT: Snapshot does NOT contain "Disconnected. Reconnecting..."
#
#   Step 5 — Take snapshot at ~2000ms:
#     Wait 1000ms, then: mcp__chrome-devtools__take_snapshot
#     ASSERT: Snapshot does NOT contain "Disconnected. Reconnecting..."
#
#   Step 6 — Verify no console messages contain "Disconnected":
#     mcp__chrome-devtools__list_console_messages
#     ASSERT: No console message contains "Disconnected. Reconnecting..."
#
# NOTE: "Connecting..." IS allowed to appear briefly. Only "Disconnected. Reconnecting..."
# is forbidden during the initial connection sequence.
#
# PASS CONDITIONS:
#   - At no point during the 0–3000ms window does the overlay show
#     "Disconnected. Reconnecting..."
#   - "Connecting..." or no overlay at all are both acceptable.
#
# FAIL CONDITIONS:
#   - Any snapshot within the first 3s contains "Disconnected. Reconnecting..."

set -euo pipefail

echo "══════════════════════════════════════════════════════"
echo " TEST: US1.AC2 — No 'Disconnected. Reconnecting...' on initial load"
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
echo "  2. take_snapshot immediately → ASSERT: no 'Disconnected. Reconnecting...'"
echo "  3. (wait 500ms) take_snapshot → ASSERT: no 'Disconnected. Reconnecting...'"
echo "  4. (wait 500ms) take_snapshot → ASSERT: no 'Disconnected. Reconnecting...'"
echo "  5. (wait 1000ms) take_snapshot → ASSERT: no 'Disconnected. Reconnecting...'"
echo "  6. list_console_messages → ASSERT: no 'Disconnected' in messages"
echo ""
echo "ALLOWED overlays: 'Connecting...' or no overlay at all."
echo "FORBIDDEN overlay: 'Disconnected. Reconnecting...'"
exit 0
