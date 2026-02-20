#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Cyberpunk palette applied to terminal
# Criterion: US4.AC1 — "Given the terminal panel is displayed, When the user views the terminal, Then the terminal background, foreground, and cursor colors match the kai cyberpunk palette."
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US4.AC1] Testing: Cyberpunk palette colors"

THEME_FILE="$PROJECT_DIR/src/app/lib/terminal-theme.ts"

if [ ! -f "$THEME_FILE" ]; then
  echo "FAIL: terminal-theme.ts not found" >&2
  exit 1
fi

# 1. Verify dark background (cyberpunk dark)
if ! grep -q 'background.*#0a0a0f' "$THEME_FILE"; then
  echo "FAIL: Background is not cyberpunk dark (#0a0a0f)" >&2
  exit 1
fi

# 2. Verify cursor is neon cyan
if ! grep -q 'cursor.*#00f0ff' "$THEME_FILE"; then
  echo "FAIL: Cursor is not neon cyan (#00f0ff)" >&2
  exit 1
fi

# 3. Verify foreground is set
if ! grep -q 'foreground' "$THEME_FILE"; then
  echo "FAIL: Foreground color not defined" >&2
  exit 1
fi

# 4. Verify theme is imported and used in Terminal config
HOOK_FILE="$PROJECT_DIR/src/app/lib/use-terminal.ts"
if ! grep -q 'terminalTheme' "$HOOK_FILE"; then
  echo "FAIL: terminalTheme not imported/used in use-terminal.ts" >&2
  exit 1
fi

echo "PASS: US4.AC1 — Cyberpunk palette verified (dark bg, neon cyan cursor, theme applied)"
exit 0
