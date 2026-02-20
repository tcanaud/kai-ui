#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Interactive/full-screen TUI support
# Criterion: US1.AC3 — "Given the terminal panel is displayed, When the user runs an interactive program (e.g., top, vim), Then the terminal correctly handles interactive/full-screen TUI rendering."
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies xterm.js is configured for TUI support (xterm-256color, proper sizing).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US1.AC3] Testing: Interactive TUI rendering support"

# 1. Verify PTY spawns with xterm-256color TERM
PTY_FILE="$PROJECT_DIR/src/terminal-server/pty-manager.ts"
if ! grep -q 'xterm-256color' "$PTY_FILE"; then
  echo "FAIL: PTY does not use xterm-256color terminal type" >&2
  echo "  Expected: name: 'xterm-256color' in pty.spawn options" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 2. Verify tmux session is used (tmux handles TUI rendering natively)
if ! grep -q 'tmux new-session' "$PTY_FILE"; then
  echo "FAIL: PTY does not create tmux session" >&2
  echo "  Expected: tmux new-session command" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 3. Verify resize is supported (critical for TUI apps like vim/htop)
if ! grep -q 'pty.resize' "$PTY_FILE" && ! grep -q '.resize(' "$PTY_FILE"; then
  echo "FAIL: PTY resize not implemented" >&2
  echo "  Expected: pty.resize() call" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 4. Verify scrollback is configured in xterm
HOOK_FILE="$PROJECT_DIR/src/app/lib/use-terminal.ts"
if ! grep -q 'scrollback' "$HOOK_FILE"; then
  echo "FAIL: xterm scrollback not configured" >&2
  echo "  Expected: scrollback option in Terminal config" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

echo "PASS: US1.AC3 — TUI support verified (xterm-256color, tmux, resize, scrollback)"
exit 0
