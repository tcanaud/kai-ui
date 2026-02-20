#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Auto-attach to existing tmux session
# Criterion: US2.AC1 — "Given a session with an existing tmux session, When the terminal panel loads, Then it automatically attaches to the existing tmux session showing previous state."
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US2.AC1] Testing: Auto-attach to existing tmux session"

PTY_FILE="$PROJECT_DIR/src/terminal-server/pty-manager.ts"

# 1. Verify tmux new-session -A flag is used (attach if exists, create if not)
if ! grep -q 'tmux new-session -A' "$PTY_FILE"; then
  echo "FAIL: PTY does not use 'tmux new-session -A' for auto-attach" >&2
  echo "  Expected: tmux new-session -A -s <name> (creates or attaches)" >&2
  echo "  Actual: -A flag not found in tmux command" >&2
  exit 1
fi

# 2. Verify session lookup checks existing sessions before creating
if ! grep -q 'sessions.get(sessionId)' "$PTY_FILE"; then
  echo "FAIL: createSession does not check for existing session" >&2
  echo "  Expected: sessions.get(sessionId) lookup" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 3. Verify existing session is returned if found
if ! grep -q 'return existing' "$PTY_FILE"; then
  echo "FAIL: Existing session is not returned on re-connect" >&2
  echo "  Expected: return existing; when session already in map" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

echo "PASS: US2.AC1 — tmux auto-attach verified (new-session -A, session reuse)"
exit 0
