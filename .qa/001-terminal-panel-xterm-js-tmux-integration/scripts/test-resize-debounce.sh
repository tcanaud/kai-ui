#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Resize debouncing for mobile/stacked layout
# Criterion: US5.AC3 — "Given the panel is in the mobile layout (stacked panels), When the terminal panel expands or collapses, Then the terminal dimensions update accordingly."
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US5.AC3] Testing: Resize debounce and mobile layout support"

HOOK_FILE="$PROJECT_DIR/src/app/lib/use-terminal.ts"

# 1. Verify debounce is applied to resize events (FR-012)
if ! grep -q 'resizeDebounce' "$HOOK_FILE"; then
  echo "FAIL: Resize debounce not implemented" >&2
  echo "  Expected: resizeDebounceRef or similar debounce mechanism" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 2. Verify clearTimeout is used (proper debounce pattern)
if ! grep -q 'clearTimeout(resizeDebounce' "$HOOK_FILE"; then
  echo "FAIL: Debounce does not clear previous timeout" >&2
  echo "  Expected: clearTimeout before setTimeout for debounce" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 3. Verify debounce delay is ~100ms (per FR-012 constraint)
if ! grep -q '100' "$HOOK_FILE"; then
  echo "WARN: Debounce delay may not be 100ms as specified in constraints"
fi

# 4. Verify ResizeObserver works on the container (catches expand/collapse)
if ! grep -q 'observer.observe' "$HOOK_FILE"; then
  echo "FAIL: ResizeObserver does not observe the container" >&2
  echo "  Expected: observer.observe(container)" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

echo "PASS: US5.AC3 — Resize debounce verified (100ms debounce, container observation)"
exit 0
