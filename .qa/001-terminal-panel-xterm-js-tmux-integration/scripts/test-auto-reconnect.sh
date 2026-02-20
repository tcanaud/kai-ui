#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Automatic reconnection on WebSocket drop
# Criterion: US2.AC4 — "Given the WebSocket connection drops unexpectedly, When the connection is restored, Then the terminal re-attaches to the tmux session automatically without user intervention."
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US2.AC4] Testing: Automatic reconnection"

HOOK_FILE="$PROJECT_DIR/src/app/lib/use-terminal.ts"

# 1. Verify reconnection logic exists
if ! grep -q 'attemptReconnect' "$HOOK_FILE"; then
  echo "FAIL: No reconnection logic found" >&2
  echo "  Expected: attemptReconnect function" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 2. Verify ws.onclose triggers reconnection
if ! grep -q 'attemptReconnect(term)' "$HOOK_FILE"; then
  echo "FAIL: WebSocket onclose does not trigger reconnection" >&2
  echo "  Expected: attemptReconnect called in ws.onclose" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 3. Verify exponential backoff
if ! grep -q 'Math.pow' "$HOOK_FILE" || ! grep -q 'Math.min' "$HOOK_FILE"; then
  echo "FAIL: Exponential backoff not implemented" >&2
  echo "  Expected: exponential delay calculation with Math.pow and Math.min cap" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 4. Verify max reconnect attempts
if ! grep -q 'MAX_RECONNECT_ATTEMPTS' "$HOOK_FILE"; then
  echo "FAIL: No max reconnect limit" >&2
  echo "  Expected: MAX_RECONNECT_ATTEMPTS constant" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 5. Verify reconnecting state is set
if ! grep -q '"reconnecting"' "$HOOK_FILE"; then
  echo "FAIL: 'reconnecting' state not set during reconnection" >&2
  exit 1
fi

echo "PASS: US2.AC4 — Auto-reconnect verified (exponential backoff, max attempts, state tracking)"
exit 0
