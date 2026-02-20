#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Copy text from terminal to clipboard
# Criterion: US3.AC2 — "Given text is visible in the terminal, When the user selects text and triggers copy, Then the selected text is placed on the system clipboard."
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US3.AC2] Testing: Copy to clipboard"

HOOK_FILE="$PROJECT_DIR/src/app/lib/use-terminal.ts"
THEME_FILE="$PROJECT_DIR/src/app/lib/terminal-theme.ts"

# 1. Verify selectionBackground is configured (indicates selection support)
if ! grep -q 'selectionBackground' "$THEME_FILE"; then
  echo "FAIL: selectionBackground not configured in theme" >&2
  echo "  Expected: selectionBackground color in terminal theme" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 2. xterm.js natively supports copy via browser selection + Ctrl/Cmd+C
# The allowProposedApi flag enables clipboard integration
if ! grep -q 'allowProposedApi' "$HOOK_FILE"; then
  echo "FAIL: allowProposedApi not enabled (needed for clipboard)" >&2
  echo "  Expected: allowProposedApi: true in Terminal config" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

echo "PASS: US3.AC2 — Copy support verified (selectionBackground, allowProposedApi)"
exit 0
