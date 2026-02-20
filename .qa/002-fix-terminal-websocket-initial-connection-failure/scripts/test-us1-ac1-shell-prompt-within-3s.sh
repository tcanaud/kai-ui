#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Terminal displays live shell prompt within 3 seconds on initial load
# Criterion: US1.AC1 — "Given the sidecar server is running and healthy, When a
#   user navigates to the application URL in their browser, Then the terminal
#   panel displays a live shell prompt within 3 seconds of the page becoming
#   interactive."
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
# EXECUTION: This script uses MCP Chrome DevTools via Claude Code.
# Run this file to receive step-by-step instructions and assertions.
# Each step's expected vs actual outcome must be verified.
#
# MCP TOOL SEQUENCE:
#
#   Step 1 — Navigate to the application:
#     mcp__chrome-devtools__navigate_page → url: "http://localhost:3000"
#
#   Step 2 — Record the navigation timestamp (T0).
#
#   Step 3 — Poll for terminal content within 3000ms:
#     Repeat every 500ms up to 6 times:
#       mcp__chrome-devtools__list_console_messages
#       mcp__chrome-devtools__take_snapshot
#     Stop when snapshot contains a terminal element with visible text content
#     (shell prompt characters like '$', '#', '>', or similar).
#
#   Step 4 — Assert: A shell prompt is visible in the terminal panel.
#     EXPECTED: Terminal panel contains a shell prompt character within 3000ms of navigation.
#     ACTUAL: Observe the snapshot output.
#
#   Step 5 — Assert: No WebSocket error in console.
#     mcp__chrome-devtools__list_console_messages
#     EXPECTED: No console errors related to WebSocket connection failure.
#     ACTUAL: Inspect console messages.
#
# PASS CONDITIONS:
#   - Shell prompt visible in terminal panel within 3 seconds of page load.
#   - No connection error messages in the browser console.
#
# FAIL CONDITIONS:
#   - Terminal panel shows no content after 3 seconds.
#   - Console contains WebSocket error messages.
#   - Terminal xterm canvas is blank after 3 seconds.

set -euo pipefail

echo "══════════════════════════════════════════════════════"
echo " TEST: US1.AC1 — Shell prompt visible within 3s"
echo " Feature: 002-fix-terminal-websocket-initial-connection-failure"
echo "══════════════════════════════════════════════════════"
echo ""
echo "This test requires MCP Chrome DevTools. Execute the MCP tool sequence"
echo "described in this script header using Claude Code."
echo ""
echo "PREREQUISITES CHECK:"
echo "  [ ] npm run dev running on http://localhost:3000"
echo "  [ ] Sidecar running on ws://localhost:3001"
echo "  [ ] At least one session exists"
echo "  [ ] Chrome --remote-debugging-port=9222"
echo ""

# Verify sidecar is reachable via HTTP upgrade check
if curl -sf --max-time 2 http://localhost:3001 > /dev/null 2>&1; then
  echo "  [OK] Sidecar is reachable on port 3001"
elif curl -sf --max-time 2 http://localhost:3001/health > /dev/null 2>&1; then
  echo "  [OK] Sidecar health endpoint is reachable"
else
  # WebSocket-only server — try connection attempt (ECONNREFUSED = not running)
  if ! nc -z localhost 3001 2>/dev/null; then
    echo "  [FAIL] Sidecar is NOT running on port 3001" >&2
    echo "  EXPECTED: Sidecar listening on ws://localhost:3001" >&2
    echo "  ACTUAL: Connection refused on port 3001" >&2
    exit 1
  else
    echo "  [OK] Sidecar port 3001 is open"
  fi
fi

# Verify Next.js is running
if ! curl -sf --max-time 2 http://localhost:3000 > /dev/null 2>&1; then
  echo "  [FAIL] Next.js dev server is NOT running on port 3000" >&2
  echo "  EXPECTED: HTTP 200 from http://localhost:3000" >&2
  echo "  ACTUAL: Connection refused or timeout on port 3000" >&2
  exit 1
fi
echo "  [OK] Next.js dev server is reachable on port 3000"

echo ""
echo "Infrastructure checks passed. Proceed with MCP Chrome DevTools steps:"
echo ""
echo "  1. mcp__chrome-devtools__navigate_page → url: 'http://localhost:3000'"
echo "  2. Wait up to 3000ms, polling every 500ms with take_snapshot"
echo "  3. Assert terminal panel shows shell prompt characters"
echo "  4. Assert no WebSocket errors in console messages"
echo ""
echo "Manual execution required — see script header for full MCP tool sequence."
exit 0
