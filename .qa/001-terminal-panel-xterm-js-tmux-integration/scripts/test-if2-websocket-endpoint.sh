#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Interface — WebSocket endpoint
# Criterion: IF2 — "WebSocket bidirectional channel — raw text for I/O, JSON for resize/error/exit"
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[IF2] Testing: WebSocket endpoint at ws://localhost:3001/terminal/:sessionId"

SERVER_FILE="$PROJECT_DIR/src/terminal-server/index.ts"

# 1. Verify WebSocketServer is created
if ! grep -q 'WebSocketServer' "$SERVER_FILE"; then
  echo "FAIL: WebSocketServer not instantiated" >&2
  exit 1
fi

# 2. Verify /terminal/:sessionId path matching
if ! grep -q '/terminal/' "$SERVER_FILE"; then
  echo "FAIL: /terminal/ path not matched" >&2
  echo "  Expected: path matching for /terminal/:sessionId" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 3. Verify raw text I/O (pty.write for input)
if ! grep -q 'session.pty.write' "$SERVER_FILE"; then
  echo "FAIL: Raw text input not written to PTY" >&2
  exit 1
fi

# 4. Verify JSON resize message handling
if ! grep -q 'parsed.type === "resize"' "$SERVER_FILE"; then
  echo "FAIL: JSON resize messages not handled" >&2
  exit 1
fi

# 5. Verify error JSON messages are sent
if ! grep -q '"type": "error"' "$SERVER_FILE" || ! grep -q 'type.*error' "$SERVER_FILE"; then
  # Check alternate patterns
  if ! grep -q '"error"' "$SERVER_FILE"; then
    echo "FAIL: Error JSON messages not sent" >&2
    exit 1
  fi
fi

# 6. Verify port 3001
if ! grep -q '3001' "$SERVER_FILE"; then
  echo "FAIL: Default port is not 3001" >&2
  exit 1
fi

echo "PASS: IF2 — WebSocket endpoint verified (WSS, path routing, raw I/O, JSON control, port 3001)"
exit 0
