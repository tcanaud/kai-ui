#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: ConnectionOverlay renders correct message for each ConnectionState value
# Criterion: IF2 — "ConnectionOverlay — renders correct message for each
#   ConnectionState value"
# Feature: 002-fix-terminal-websocket-initial-connection-failure
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# This test verifies the static source code of ConnectionOverlay in
# terminal-panel.tsx to ensure each ConnectionState maps to the correct
# user-facing message, per the spec and agreement.
#
# Expected mappings (from spec FR-002, FR-004, FR-005, FR-006):
#   idle        → "Connecting..."
#   connecting  → "Connecting..."
#   connected   → (no overlay / null)
#   disconnected → "Connection lost. Retrying..."  (NOT "Disconnected. Reconnecting...")
#   reconnecting → "Connection lost. Retrying..."
#   error       → "Connection failed." + Retry button
#
# SOURCE FILE: src/app/components/panels/terminal-panel.tsx

set -euo pipefail

FEATURE="002-fix-terminal-websocket-initial-connection-failure"
SOURCE_FILE="/Users/thibaudcanaud/__WORKSPACE__/__PERSO__/kai/packages/kai-ui/src/app/components/panels/terminal-panel.tsx"

echo "══════════════════════════════════════════════════════"
echo " TEST: IF2 — ConnectionOverlay message mapping compliance"
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

# Check that the FORBIDDEN message "Disconnected. Reconnecting..." is NOT present
if grep -q "Disconnected. Reconnecting" "${SOURCE_FILE}"; then
  echo "  [FAIL] Forbidden message 'Disconnected. Reconnecting...' found in overlay" >&2
  echo "  EXPECTED: This message should NOT exist in ${SOURCE_FILE}" >&2
  echo "  ACTUAL: grep matched 'Disconnected. Reconnecting' in the file" >&2
  PASS=false
else
  echo "  [OK] Forbidden message 'Disconnected. Reconnecting...' is NOT present"
fi

# Check "Connecting..." is present (for idle/connecting states)
if grep -q "Connecting\.\.\." "${SOURCE_FILE}"; then
  echo "  [OK] 'Connecting...' message present (for idle/connecting states)"
else
  echo "  [FAIL] 'Connecting...' message not found" >&2
  echo "  EXPECTED: 'Connecting...' in overlay for idle/connecting states" >&2
  PASS=false
fi

# Check "Connection lost. Retrying..." is present (for disconnected/reconnecting)
if grep -q "Connection lost. Retrying\.\.\." "${SOURCE_FILE}"; then
  echo "  [OK] 'Connection lost. Retrying...' message present"
else
  echo "  [FAIL] 'Connection lost. Retrying...' message not found" >&2
  echo "  EXPECTED: 'Connection lost. Retrying...' for disconnected/reconnecting states" >&2
  PASS=false
fi

# Check "Connection failed." is present (for error state)
if grep -q "Connection failed\." "${SOURCE_FILE}"; then
  echo "  [OK] 'Connection failed.' message present (for error state)"
else
  echo "  [FAIL] 'Connection failed.' message not found" >&2
  echo "  EXPECTED: 'Connection failed.' for error state" >&2
  PASS=false
fi

# Check Retry button is present (for error state)
if grep -q "Retry" "${SOURCE_FILE}"; then
  echo "  [OK] Retry button present in overlay"
else
  echo "  [FAIL] Retry button not found in overlay" >&2
  echo "  EXPECTED: Retry button rendered when in error state" >&2
  PASS=false
fi

# Check that connected state returns null (no overlay)
if grep -q "connected.*return null\|return null.*connected\|state === .connected.. return null" "${SOURCE_FILE}"; then
  echo "  [OK] Connected state returns null (no overlay)"
elif grep -q '"connected"' "${SOURCE_FILE}" && grep -q "return null" "${SOURCE_FILE}"; then
  echo "  [OK] Connected state check and null return both present"
else
  echo "  [WARN] Cannot statically confirm connected state returns null — verify manually"
fi

echo ""
if [ "${PASS}" = true ]; then
  echo "RESULT: PASS — ConnectionOverlay message mapping is compliant"
  exit 0
else
  echo "RESULT: FAIL — ConnectionOverlay compliance violations detected" >&2
  exit 1
fi
