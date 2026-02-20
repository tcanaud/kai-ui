#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: "Connection lost. Retrying..." shown when reconnection in progress
# Criterion: US3.AC2 — "Given the terminal was connected and the connection
#   dropped, When a reconnection attempt is in progress, Then 'Connection lost.
#   Retrying...' is shown."
# Feature: 002-fix-terminal-websocket-initial-connection-failure
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# PREREQUISITES:
#   1. npm run dev is running (Next.js on http://localhost:3000)
#   2. Sidecar server is running and can be stopped
#   3. At least one session exists
#   4. Chrome is launched with --remote-debugging-port=9222
#
# MCP TOOL SEQUENCE:
#
#   Step 1 — Navigate and verify initial connection:
#     mcp__chrome-devtools__navigate_page → url: "http://localhost:3000"
#     Wait 3000ms.
#     mcp__chrome-devtools__take_snapshot
#     ASSERT: Terminal is connected (no overlay, or overlay gone).
#
#   Step 2 — Stop the sidecar (in a separate terminal).
#
#   Step 3 — Take snapshot within 2s of sidecar stopping:
#     mcp__chrome-devtools__take_snapshot
#     ASSERT: Overlay shows "Connection lost. Retrying..."
#     ASSERT: NOT "Disconnected. Reconnecting..."
#     ASSERT: NOT "Connection failed."
#
#   Step 4 — Confirm message is semantically correct:
#     mcp__chrome-devtools__take_screenshot (visual record)
#
# PASS CONDITIONS:
#   - "Connection lost. Retrying..." appears after a live connection drops.
#   - Animated pulse dots visible (indicating active retry, not final failure).
#
# FAIL CONDITIONS:
#   - "Disconnected. Reconnecting..." shown instead.
#   - "Connection failed." shown immediately without retrying.
#   - No overlay shown (user has no feedback about the lost connection).

set -euo pipefail

echo "══════════════════════════════════════════════════════"
echo " TEST: US3.AC2 — 'Connection lost. Retrying...' on connection drop"
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
echo "  1. navigate_page → 'http://localhost:3000', wait 3s"
echo "  2. take_snapshot → ASSERT: terminal connected (no overlay)"
echo "  3. [MANUAL] Stop the sidecar server"
echo "  4. take_snapshot within 2s"
echo "     ASSERT: 'Connection lost. Retrying...' is visible"
echo "     ASSERT: NOT 'Disconnected. Reconnecting...'"
echo "     ASSERT: NOT 'Connection failed.'"
echo "  5. take_screenshot for visual record"
exit 0
