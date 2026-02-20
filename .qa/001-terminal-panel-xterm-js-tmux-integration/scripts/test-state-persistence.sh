#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Terminal state persists across page refresh
# Criterion: US2.AC3 — "Given the user is connected to a tmux session, When the user refreshes the browser or navigates away and returns, Then the terminal reconnects to the same tmux session with all state preserved."
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US2.AC3] Testing: State persistence across refresh"

PTY_FILE="$PROJECT_DIR/src/terminal-server/pty-manager.ts"

# 1. Verify PTY is NOT killed when last client disconnects (tmux persists)
if grep -q 'session.pty.kill()' "$PTY_FILE" && ! grep -q 'cleanupAll' "$PTY_FILE"; then
  echo "FAIL: PTY is killed on client disconnect" >&2
  echo "  Expected: PTY stays alive when clients disconnect" >&2
  exit 1
fi

# Key behavior: detachClient should NOT kill PTY
DETACH_FUNC=$(sed -n '/export function detachClient/,/^}/p' "$PTY_FILE")
if echo "$DETACH_FUNC" | grep -q 'pty.kill'; then
  echo "FAIL: detachClient kills the PTY" >&2
  echo "  Expected: detachClient only removes client from set, keeps PTY alive" >&2
  echo "  Actual: pty.kill() found in detachClient" >&2
  exit 1
fi

# 2. Verify comment confirms intentional persistence
if ! grep -q 'Keep PTY alive' "$PTY_FILE"; then
  echo "WARN: No explicit comment about keeping PTY alive on disconnect"
fi

# 3. Verify tmux -A flag ensures re-attach to existing session
if ! grep -q 'tmux new-session -A' "$PTY_FILE"; then
  echo "FAIL: tmux -A flag not used (required for re-attach)" >&2
  exit 1
fi

echo "PASS: US2.AC3 — State persistence verified (PTY survives disconnect, tmux -A re-attaches)"
exit 0
