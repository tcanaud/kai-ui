#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: ANSI colors mapped to cyberpunk palette
# Criterion: US4.AC2 — "Given the terminal displays colored output, When ANSI colors are rendered, Then they map to the cyberpunk palette variants (neon cyan, neon violet, etc.)."
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US4.AC2] Testing: ANSI color mapping to cyberpunk palette"

THEME_FILE="$PROJECT_DIR/src/app/lib/terminal-theme.ts"

# Verify all 16 ANSI colors are defined
MISSING=()
for COLOR in black red green yellow blue magenta cyan white brightBlack brightRed brightGreen brightYellow brightBlue brightMagenta brightCyan brightWhite; do
  if ! grep -q "$COLOR" "$THEME_FILE"; then
    MISSING+=("$COLOR")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "FAIL: Missing ANSI color definitions: ${MISSING[*]}" >&2
  echo "  Expected: All 16 ANSI colors defined in theme" >&2
  echo "  Actual: ${#MISSING[@]} missing" >&2
  exit 1
fi

# Verify cyberpunk-specific colors are present
if ! grep -q '#00f0ff' "$THEME_FILE"; then
  echo "FAIL: Neon cyan (#00f0ff) not in palette" >&2
  exit 1
fi

if ! grep -q '#8b5cf6\|#a78bfa' "$THEME_FILE"; then
  echo "FAIL: Violet tones not in palette" >&2
  exit 1
fi

echo "PASS: US4.AC2 — All 16 ANSI colors mapped to cyberpunk palette"
exit 0
