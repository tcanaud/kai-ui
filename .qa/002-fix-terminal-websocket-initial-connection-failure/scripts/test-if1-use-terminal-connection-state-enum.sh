#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: useTerminal hook — ConnectionState enum has all required values
# Criterion: IF1 — "useTerminal hook — ConnectionState enum:
#   idle | connecting | connected | disconnected | reconnecting | error"
# Feature: 002-fix-terminal-websocket-initial-connection-failure
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# This is a static interface compliance test. It verifies that the
# ConnectionState type exported from use-terminal.ts contains exactly
# the required union members.
#
# SOURCE FILE: src/app/lib/use-terminal.ts

set -euo pipefail

FEATURE="002-fix-terminal-websocket-initial-connection-failure"
SOURCE_FILE="/Users/thibaudcanaud/__WORKSPACE__/__PERSO__/kai/packages/kai-ui/src/app/lib/use-terminal.ts"

echo "══════════════════════════════════════════════════════"
echo " TEST: IF1 — ConnectionState enum interface compliance"
echo " Feature: ${FEATURE}"
echo "══════════════════════════════════════════════════════"
echo ""

# Check source file exists
if [ ! -f "${SOURCE_FILE}" ]; then
  echo "  [FAIL] Source file not found: ${SOURCE_FILE}" >&2
  echo "  EXPECTED: File exists" >&2
  echo "  ACTUAL: File not found" >&2
  exit 1
fi
echo "  [OK] Source file found: ${SOURCE_FILE}"

PASS=true

# Check each required ConnectionState member
REQUIRED_STATES=("idle" "connecting" "connected" "disconnected" "reconnecting" "error")

for state in "${REQUIRED_STATES[@]}"; do
  if grep -q "\"${state}\"" "${SOURCE_FILE}"; then
    echo "  [OK] ConnectionState includes '${state}'"
  else
    echo "  [FAIL] ConnectionState is missing '${state}'" >&2
    echo "  EXPECTED: '${state}' in ConnectionState union type" >&2
    echo "  ACTUAL: '${state}' not found in ${SOURCE_FILE}" >&2
    PASS=false
  fi
done

# Check ConnectionState type is exported
if grep -q "export type ConnectionState" "${SOURCE_FILE}"; then
  echo "  [OK] ConnectionState is exported"
else
  echo "  [FAIL] ConnectionState is not exported" >&2
  echo "  EXPECTED: 'export type ConnectionState' in ${SOURCE_FILE}" >&2
  PASS=false
fi

# Check useTerminal hook is exported
if grep -q "export function useTerminal" "${SOURCE_FILE}"; then
  echo "  [OK] useTerminal hook is exported"
else
  echo "  [FAIL] useTerminal hook is not exported" >&2
  PASS=false
fi

# Check hook returns connectionState
if grep -q "connectionState" "${SOURCE_FILE}"; then
  echo "  [OK] useTerminal returns connectionState"
else
  echo "  [FAIL] useTerminal does not expose connectionState" >&2
  PASS=false
fi

echo ""
if [ "${PASS}" = true ]; then
  echo "RESULT: PASS — ConnectionState enum interface is compliant"
  exit 0
else
  echo "RESULT: FAIL — Interface compliance violations detected" >&2
  exit 1
fi
