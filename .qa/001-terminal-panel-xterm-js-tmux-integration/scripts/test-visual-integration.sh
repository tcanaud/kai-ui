#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Terminal visual integration with panel UI
# Criterion: US4.AC3 — "Given the terminal is embedded in the panel slot, When viewed alongside other panels, Then the terminal visually integrates with the panel header bar, borders, and surrounding UI elements."
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US4.AC3] Testing: Visual integration with panel UI"

PANEL_FILE="$PROJECT_DIR/src/app/components/panels/terminal-panel.tsx"

# 1. Verify terminal is wrapped in PanelSlot component
if ! grep -q 'PanelSlot' "$PANEL_FILE"; then
  echo "FAIL: Terminal not wrapped in PanelSlot" >&2
  echo "  Expected: <PanelSlot type=\"terminal\" ...>" >&2
  echo "  Actual: PanelSlot not found" >&2
  exit 1
fi

# 2. Verify terminal background matches theme
if ! grep -q '#0a0a0f' "$PANEL_FILE"; then
  echo "FAIL: Terminal container background doesn't match cyberpunk dark" >&2
  echo "  Expected: background: #0a0a0f" >&2
  echo "  Actual: not found in panel" >&2
  exit 1
fi

# 3. Verify full width/height filling
if ! grep -q 'w-full h-full' "$PANEL_FILE"; then
  echo "FAIL: Terminal does not fill panel slot" >&2
  echo "  Expected: w-full h-full classes" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

echo "PASS: US4.AC3 — Visual integration verified (PanelSlot wrapper, matching bg, full fill)"
exit 0
