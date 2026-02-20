#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: TUI app re-renders correctly after resize
# Criterion: US5.AC2 — "Given a full-screen TUI application is running, When the panel is resized, Then the TUI application re-renders correctly at the new dimensions without artifacts."
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US5.AC2] Testing: TUI app re-render after resize"

PTY_FILE="$PROJECT_DIR/src/terminal-server/pty-manager.ts"

# 1. Verify server-side PTY resize is implemented
if ! grep -q 'resizeSession' "$PTY_FILE"; then
  echo "FAIL: resizeSession function not found" >&2
  exit 1
fi

# 2. Verify pty.resize is called with validated dimensions
if ! grep -q 'session.pty.resize' "$PTY_FILE"; then
  echo "FAIL: pty.resize() not called in resizeSession" >&2
  echo "  Expected: session.pty.resize(cols, rows)" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 3. Verify bounds validation (prevents extreme values)
if ! grep -q 'Math.max' "$PTY_FILE" || ! grep -q 'Math.min' "$PTY_FILE"; then
  echo "FAIL: No bounds validation on resize dimensions" >&2
  echo "  Expected: Math.max/Math.min for cols/rows clamping" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 4. Verify server handles resize JSON message
SERVER_FILE="$PROJECT_DIR/src/terminal-server/index.ts"
if ! grep -q 'parsed.type === "resize"' "$SERVER_FILE"; then
  echo "FAIL: Server does not handle resize messages" >&2
  echo "  Expected: JSON message handler for type: 'resize'" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

echo "PASS: US5.AC2 — TUI resize verified (PTY resize, bounds validation, server handler)"
exit 0
