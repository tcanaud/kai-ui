#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: "Connection lost. Retrying..." shown during reconnect, not "Disconnected. Reconnecting..."
# Criterion: US2.AC2 — "Given a reconnection attempt is in progress, When the
#   sidecar is not yet available, Then the 'Connection lost. Retrying...' message
#   is shown — not 'Disconnected. Reconnecting...' — to clearly distinguish from
#   an initial connection failure."
# Feature: 002-fix-terminal-websocket-initial-connection-failure
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# PREREQUISITES:
#   1. npm run dev is running (Next.js on http://localhost:3000)
#   2. Sidecar server is running and you can stop it
#   3. At least one session exists, terminal has connected at least once
#   4. Chrome is launched with --remote-debugging-port=9222
#
# MCP TOOL SEQUENCE:
#
#   Step 1 — Navigate and confirm initial connection:
#     mcp__chrome-devtools__navigate_page → url: "http://localhost:3000"
#     Wait 3000ms.
#     mcp__chrome-devtools__take_snapshot
#     ASSERT: Terminal is connected (content visible, no error overlay).
#
#   Step 2 — Stop the sidecar (manual action in a separate terminal).
#
#   Step 3 — Within 2s of sidecar stopping, take snapshot:
#     mcp__chrome-devtools__take_snapshot
#     ASSERT: Overlay contains exactly "Connection lost. Retrying..."
#     ASSERT: Overlay does NOT contain "Disconnected. Reconnecting..."
#
#   Step 4 — Confirm the reconnecting state persists while sidecar is down:
#     Wait 3000ms.
#     mcp__chrome-devtools__take_snapshot
#     ASSERT: Overlay still shows "Connection lost. Retrying..." (not "Connection failed."
#             unless retry limit was reached).
#
# PASS CONDITIONS:
#   - After a live connection drops, overlay shows "Connection lost. Retrying..."
#   - The forbidden message "Disconnected. Reconnecting..." is never shown.
#
# FAIL CONDITIONS:
#   - Overlay shows "Disconnected. Reconnecting..." after a connection drop.
#   - No overlay shown at all when sidecar is unavailable.
#   - Wrong message shown (e.g., "Connecting..." during a reconnection).

set -euo pipefail

echo "══════════════════════════════════════════════════════"
echo " TEST: US2.AC2 — Correct message during reconnection attempt"
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
echo "  1. navigate_page → 'http://localhost:3000', wait 3s"
echo "  2. take_snapshot → ASSERT: terminal is connected (no overlay)"
echo "  3. [MANUAL] Stop the sidecar server"
echo "  4. take_snapshot immediately → ASSERT: 'Connection lost. Retrying...'"
echo "  5. ASSERT: text is NOT 'Disconnected. Reconnecting...'"
echo "  6. Wait 3s, take_snapshot → ASSERT: still reconnecting (not failed yet)"
exit 0
