#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: "Connecting..." shown during initial connection phase
# Criterion: US3.AC1 — "Given the terminal is making its initial connection,
#   When the connection has not yet succeeded, Then 'Connecting...' is shown."
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
# NOTE: This test captures the brief "Connecting..." state. It must be observed
# immediately after navigation (within ~200ms), before the connection succeeds.
# Use Chrome's CPU throttling to slow down the connection if needed.
#
# MCP TOOL SEQUENCE:
#
#   Step 1 — (Optional) Apply CPU throttling to make "Connecting..." observable:
#     mcp__chrome-devtools__emulate → cpuThrottlingRate: 4
#
#   Step 2 — Navigate to the application:
#     mcp__chrome-devtools__navigate_page → url: "http://localhost:3000", ignoreCache: true
#
#   Step 3 — Take snapshot immediately (within ~100–300ms of navigation):
#     mcp__chrome-devtools__take_snapshot
#     ASSERT: If terminal panel is not yet connected, overlay shows "Connecting..."
#     ASSERT: Overlay does NOT show "Disconnected. Reconnecting..."
#     ASSERT: Overlay does NOT show "Connection lost. Retrying..."
#
#   Step 4 — Take screenshot for visual confirmation:
#     mcp__chrome-devtools__take_screenshot
#
#   Step 5 — Remove CPU throttling:
#     mcp__chrome-devtools__emulate → cpuThrottlingRate: 1
#
#   Step 6 — Wait for connection to complete and verify:
#     mcp__chrome-devtools__wait_for → text: (terminal content, e.g., a prompt char)
#     OR poll with take_snapshot until overlay is gone.
#
# PASS CONDITIONS:
#   - During the initial connection phase, only "Connecting..." (or no overlay
#     if connection is near-instantaneous) is shown.
#   - Never "Disconnected. Reconnecting..." or "Connection lost. Retrying..."
#     during this phase.
#
# FAIL CONDITIONS:
#   - "Disconnected. Reconnecting..." shown during initial phase.
#   - "Connection lost. Retrying..." shown during initial phase.
#   - No overlay shown at all but connection not yet established.

set -euo pipefail

echo "══════════════════════════════════════════════════════"
echo " TEST: US3.AC1 — 'Connecting...' shown during initial connection"
echo " Feature: 002-fix-terminal-websocket-initial-connection-failure"
echo "══════════════════════════════════════════════════════"
echo ""

# Infrastructure checks
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
echo "  1. emulate → cpuThrottlingRate: 4  (slow down to capture transient state)"
echo "  2. navigate_page → 'http://localhost:3000', ignoreCache: true"
echo "  3. take_snapshot immediately"
echo "     ASSERT: overlay text is 'Connecting...' (if not yet connected)"
echo "     ASSERT: NOT 'Disconnected. Reconnecting...'"
echo "     ASSERT: NOT 'Connection lost. Retrying...'"
echo "  4. take_screenshot (visual confirmation)"
echo "  5. emulate → cpuThrottlingRate: 1  (restore)"
echo "  6. Poll take_snapshot until overlay is gone"
exit 0
