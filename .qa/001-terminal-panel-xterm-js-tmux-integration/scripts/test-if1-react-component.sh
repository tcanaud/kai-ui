#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Interface — React component rendering xterm.js
# Criterion: IF1 — "React component rendering xterm.js in the terminal panel slot"
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[IF1] Testing: React component at src/app/components/panels/terminal-panel.tsx"

PANEL_FILE="$PROJECT_DIR/src/app/components/panels/terminal-panel.tsx"

# 1. Verify file exists at agreed path
if [ ! -f "$PANEL_FILE" ]; then
  echo "FAIL: Interface file not found" >&2
  echo "  Expected: $PANEL_FILE" >&2
  echo "  Actual: file does not exist" >&2
  exit 1
fi

# 2. Verify it exports TerminalPanel component
if ! grep -q 'export function TerminalPanel\|export const TerminalPanel' "$PANEL_FILE"; then
  echo "FAIL: TerminalPanel not exported" >&2
  echo "  Expected: exported TerminalPanel component" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 3. Verify it's a client component (required for xterm.js)
if ! grep -q '"use client"' "$PANEL_FILE"; then
  echo "FAIL: Missing 'use client' directive" >&2
  echo "  Expected: 'use client' at top of file" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 4. Verify it uses useTerminal hook (xterm.js integration)
if ! grep -q 'useTerminal' "$PANEL_FILE"; then
  echo "FAIL: useTerminal hook not used" >&2
  exit 1
fi

echo "PASS: IF1 — React component verified (exported, client component, xterm.js via useTerminal)"
exit 0
