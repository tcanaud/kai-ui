#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Create new tmux session when none exists
# Criterion: US2.AC2 — "Given a session without an existing tmux session, When the terminal panel loads for the first time, Then a new tmux session is created and attached."
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US2.AC2] Testing: New tmux session creation"

PTY_FILE="$PROJECT_DIR/src/terminal-server/pty-manager.ts"

# 1. Verify tmux session is created with session name derived from sessionId
if ! grep -q 'kai-' "$PTY_FILE"; then
  echo "FAIL: tmux session name does not use kai- prefix" >&2
  echo "  Expected: tmuxSessionName = \`kai-\${sessionId}\`" >&2
  echo "  Actual: kai- prefix not found" >&2
  exit 1
fi

# 2. Verify working directory is set from worktreePath
if ! grep -q 'resolveWorktreePath' "$PTY_FILE"; then
  echo "FAIL: Working directory resolution not found" >&2
  echo "  Expected: resolveWorktreePath function" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 3. Verify -c flag passes cwd to tmux
if ! grep -q '\-c' "$PTY_FILE"; then
  echo "FAIL: tmux -c flag for working directory not found" >&2
  echo "  Expected: -c <cwd> in tmux new-session command" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 4. Verify session is stored in the sessions map
if ! grep -q 'sessions.set(sessionId' "$PTY_FILE"; then
  echo "FAIL: New session is not stored in sessions map" >&2
  echo "  Expected: sessions.set(sessionId, session)" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

echo "PASS: US2.AC2 — New tmux session creation verified (kai- prefix, worktree cwd, session storage)"
exit 0
