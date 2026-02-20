#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Terminal auto-reconnects after sidecar restart without page reload
# Criterion: US2.AC1 — "Given the terminal is connected and the sidecar is
#   restarted, When the sidecar becomes available again, Then the terminal
#   reconnects and displays a live shell prompt without requiring a page reload."
# Feature: 002-fix-terminal-websocket-initial-connection-failure
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# PREREQUISITES:
#   1. npm run dev is running (Next.js on http://localhost:3000)
#   2. Sidecar server is running on ws://localhost:3001 AND you have access
#      to restart it (know the start command)
#   3. At least one session exists
#   4. Chrome is launched with --remote-debugging-port=9222
#
# MCP TOOL SEQUENCE:
#
#   Step 1 — Navigate and confirm initial connection:
#     mcp__chrome-devtools__navigate_page → url: "http://localhost:3000"
#     Wait 3000ms.
#     mcp__chrome-devtools__take_snapshot
#     ASSERT: Terminal is in connected state (content visible, no overlay or
#             "Connecting..." overlay gone).
#
#   Step 2 — Restart the sidecar (done in a separate terminal, NOT via MCP):
#     Kill the sidecar process and restart it.
#     The sidecar should be unavailable for ~2–5 seconds then come back up.
#
#   Step 3 — During sidecar downtime, verify reconnection overlay:
#     mcp__chrome-devtools__take_snapshot (taken within ~1–2s of sidecar going down)
#     ASSERT: Terminal shows "Connection lost. Retrying..." overlay.
#     ASSERT: Terminal does NOT show "Connection failed." (not yet at retry limit).
#
#   Step 4 — After sidecar restarts, wait for reconnection:
#     Wait up to 15000ms (exponential backoff: 1s, 2s, 4s delays).
#     Poll every 2000ms with: mcp__chrome-devtools__take_snapshot
#     Stop when overlay disappears or shell prompt visible.
#
#   Step 5 — Assert final state:
#     mcp__chrome-devtools__take_snapshot
#     ASSERT: Terminal shows live content (shell prompt).
#     ASSERT: No overlay is displayed (connection restored).
#
#   Step 6 — Confirm no page reload occurred:
#     mcp__chrome-devtools__list_network_requests → resourceTypes: ["document"]
#     ASSERT: Only one document request (the original page load, not a reload).
#
# PASS CONDITIONS:
#   - "Connection lost. Retrying..." shown during sidecar downtime.
#   - Terminal auto-reconnects and shows live prompt after sidecar restarts.
#   - No manual page reload required.
#
# FAIL CONDITIONS:
#   - Terminal shows "Disconnected. Reconnecting..." instead of
#     "Connection lost. Retrying..." during downtime.
#   - Terminal does not recover after sidecar restarts (stays in error state).
#   - User must reload the page to restore the terminal.

set -euo pipefail

echo "══════════════════════════════════════════════════════"
echo " TEST: US2.AC1 — Auto-reconnect after sidecar restart"
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
echo "  3. [MANUAL] Restart the sidecar server"
echo "  4. take_snapshot within 2s of restart → ASSERT: 'Connection lost. Retrying...'"
echo "  5. Poll every 2s (up to 15s) → Wait for terminal to reconnect"
echo "  6. take_snapshot → ASSERT: live shell prompt visible, no overlay"
echo "  7. list_network_requests (document) → ASSERT: only 1 document request (no reload)"
exit 0
