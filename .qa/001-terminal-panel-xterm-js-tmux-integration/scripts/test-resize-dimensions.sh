#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Terminal resizes with browser window
# Criterion: US5.AC1 — "Given the terminal panel is displayed, When the browser window is resized, Then the terminal adjusts its column and row count to fill the panel and notifies the backend of the new dimensions."
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US5.AC1] Testing: Dynamic resize with dimension notification"

HOOK_FILE="$PROJECT_DIR/src/app/lib/use-terminal.ts"

# 1. Verify ResizeObserver is used
if ! grep -q 'ResizeObserver' "$HOOK_FILE"; then
  echo "FAIL: ResizeObserver not used for detecting panel resize" >&2
  echo "  Expected: new ResizeObserver(...)" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 2. Verify FitAddon is loaded (adjusts cols/rows)
if ! grep -q 'FitAddon' "$HOOK_FILE"; then
  echo "FAIL: FitAddon not used" >&2
  echo "  Expected: FitAddon for auto-fitting terminal to container" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 3. Verify fit() is called on resize
if ! grep -q 'fitAddon.fit()' "$HOOK_FILE"; then
  echo "FAIL: fitAddon.fit() not called on resize" >&2
  exit 1
fi

# 4. Verify resize message is sent to backend
if ! grep -q '"resize"' "$HOOK_FILE"; then
  echo "FAIL: Resize message not sent to backend" >&2
  echo "  Expected: JSON message with type: 'resize'" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 5. Verify cols and rows are sent
if ! grep -q 'cols.*term.cols' "$HOOK_FILE" || ! grep -q 'rows.*term.rows' "$HOOK_FILE"; then
  # Check alternate pattern
  if ! grep -q 'term.cols' "$HOOK_FILE" || ! grep -q 'term.rows' "$HOOK_FILE"; then
    echo "FAIL: Terminal dimensions not included in resize message" >&2
    exit 1
  fi
fi

echo "PASS: US5.AC1 — Resize verified (ResizeObserver, FitAddon, dimension notification to backend)"
exit 0
