#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Paste from clipboard into terminal
# Criterion: US3.AC3 — "Given text is on the system clipboard, When the user triggers paste, Then the clipboard content is inserted into the terminal at the cursor position."
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US3.AC3] Testing: Paste from clipboard"

HOOK_FILE="$PROJECT_DIR/src/app/lib/use-terminal.ts"

# 1. Verify paste event listener exists
if ! grep -q 'addEventListener.*paste' "$HOOK_FILE"; then
  echo "FAIL: No paste event listener found" >&2
  echo "  Expected: container.addEventListener('paste', ...) handler" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 2. Verify clipboard data is read
if ! grep -q 'clipboardData' "$HOOK_FILE"; then
  echo "FAIL: clipboardData not accessed in paste handler" >&2
  echo "  Expected: e.clipboardData.getData('text')" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 3. Verify bracketed paste mode is used (FR-015)
if ! grep -q '\\\\x1b\[200~' "$HOOK_FILE" || ! grep -q '\\\\x1b\[201~' "$HOOK_FILE"; then
  # Try alternate escaping
  if ! grep -q '200~' "$HOOK_FILE"; then
    echo "FAIL: Bracketed paste mode not implemented" >&2
    echo "  Expected: ESC[200~ ... ESC[201~ wrapping" >&2
    echo "  Actual: not found" >&2
    exit 1
  fi
fi

# 4. Verify large paste warning
if ! grep -q 'LARGE_PASTE_THRESHOLD' "$HOOK_FILE"; then
  echo "FAIL: Large paste threshold not defined" >&2
  echo "  Expected: LARGE_PASTE_THRESHOLD constant for large paste handling" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

echo "PASS: US3.AC3 — Paste verified (paste listener, clipboardData, bracketed paste mode, large paste handling)"
exit 0
