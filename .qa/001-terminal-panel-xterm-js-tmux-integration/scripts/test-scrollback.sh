#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Scrollback buffer support
# Criterion: US3.AC1 — "Given the terminal has output exceeding the visible area, When the user scrolls up, Then previous output is visible and the user can scroll through the full scrollback buffer."
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US3.AC1] Testing: Scrollback buffer"

HOOK_FILE="$PROJECT_DIR/src/app/lib/use-terminal.ts"

# 1. Verify scrollback is configured
if ! grep -q 'scrollback:' "$HOOK_FILE"; then
  echo "FAIL: scrollback option not set in Terminal config" >&2
  echo "  Expected: scrollback: <number> in Terminal options" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 2. Verify scrollback value is substantial (at least 1000)
SCROLLBACK=$(grep -o 'scrollback: [0-9]*' "$HOOK_FILE" | grep -o '[0-9]*' || echo "0")
if [ "$SCROLLBACK" -lt 1000 ]; then
  echo "FAIL: Scrollback buffer too small" >&2
  echo "  Expected: scrollback >= 1000" >&2
  echo "  Actual: scrollback = $SCROLLBACK" >&2
  exit 1
fi

echo "PASS: US3.AC1 — Scrollback buffer configured ($SCROLLBACK lines)"
exit 0
