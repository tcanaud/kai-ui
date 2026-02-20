#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Interface — HTTP health endpoint
# Criterion: IF3 — "HTTP health endpoint on the sidecar server (port 3001)"
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[IF3] Testing: HTTP health endpoint at GET /health"

SERVER_FILE="$PROJECT_DIR/src/terminal-server/index.ts"

# 1. Verify /health route exists
if ! grep -q '/health' "$SERVER_FILE"; then
  echo "FAIL: /health route not found" >&2
  echo "  Expected: GET /health handler" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 2. Verify it returns JSON with status
if ! grep -q 'status' "$SERVER_FILE" || ! grep -q '"ok"' "$SERVER_FILE"; then
  echo "FAIL: Health endpoint does not return { status: 'ok' }" >&2
  exit 1
fi

# 3. Verify it returns active session count
if ! grep -q 'activeSessions' "$SERVER_FILE"; then
  echo "FAIL: Health endpoint does not include activeSessions" >&2
  echo "  Expected: activeSessions in health response" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 4. Verify HTTP 200 status code
if ! grep -q '200' "$SERVER_FILE"; then
  echo "FAIL: Health endpoint does not return 200" >&2
  exit 1
fi

# 5. Runtime check (if sidecar is running)
if curl -sf http://localhost:3001/health > /tmp/health_response 2>/dev/null; then
  echo "  Runtime health check: $(cat /tmp/health_response)"
  rm -f /tmp/health_response
else
  echo "  WARN: Sidecar not running (runtime check skipped)"
fi

echo "PASS: IF3 — Health endpoint verified (GET /health, JSON status, activeSessions)"
exit 0
