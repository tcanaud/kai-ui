#!/usr/bin/env node
// ──────────────────────────────────────────────────────
// Test: ConnectionOverlay renders correct message for each ConnectionState value
// Criterion: IF2 — "ConnectionOverlay — renders correct message for each ConnectionState value"
// Feature: 002-fix-terminal-websocket-initial-connection-failure
// Generated: 2026-02-20T00:00:00Z
// ──────────────────────────────────────────────────────
//
// Prerequisites: None (static analysis of source only)
//
// Run: node test-connection-overlay-renders-correct-message.mjs

import { readFileSync } from "node:fs";

const PANEL_PATH = "/Users/thibaudcanaud/__WORKSPACE__/__PERSO__/kai/packages/kai-ui/src/app/components/panels/terminal-panel.tsx";

// Expected message mapping per ConnectionState
const EXPECTED_MAPPING = {
  idle: "Connecting...",
  connecting: "Connecting...",
  reconnecting: "Connection lost. Retrying...",
  disconnected: "Connection lost. Retrying...",
  error: "Connection failed.",
};

// States that must NOT show the old regression message
const FORBIDDEN_FOR_INITIAL = "Disconnected. Reconnecting...";

function runTest() {
  let source;
  try {
    source = readFileSync(PANEL_PATH, "utf-8");
  } catch (err) {
    console.error("FAIL");
    console.error(`Expected: terminal-panel.tsx exists at ${PANEL_PATH}`);
    console.error(`Actual:   File not found — ${err.message}`);
    process.exit(1);
  }

  // Assert the forbidden regression string is not present in source
  if (source.includes(FORBIDDEN_FOR_INITIAL)) {
    console.error("FAIL");
    console.error(`Expected: "${FORBIDDEN_FOR_INITIAL}" is NOT present in ConnectionOverlay source`);
    console.error(`Actual:   The string "${FORBIDDEN_FOR_INITIAL}" was found in terminal-panel.tsx — this is the regression bug text`);
    process.exit(1);
  }

  // Assert each expected message exists in the source
  const missingMessages = [];
  for (const [state, message] of Object.entries(EXPECTED_MAPPING)) {
    if (!source.includes(message)) {
      missingMessages.push(`${state} → "${message}"`);
    }
  }

  if (missingMessages.length > 0) {
    console.error("FAIL");
    console.error(`Expected: ConnectionOverlay contains messages for all states`);
    console.error(`Actual:   Missing message strings: ${missingMessages.join(", ")}`);
    process.exit(1);
  }

  // Assert ConnectionOverlay returns null when state is "connected"
  if (!source.includes(`state === "connected") return null`)) {
    console.error("FAIL");
    console.error(`Expected: ConnectionOverlay returns null when state is "connected"`);
    console.error(`Actual:   "state === \\"connected\\") return null" not found — overlay may render when connected`);
    process.exit(1);
  }

  // Assert Retry button is shown only for "error" state
  if (!source.includes("showRetry")) {
    console.error("FAIL");
    console.error(`Expected: showRetry flag used to conditionally render Retry button`);
    console.error(`Actual:   showRetry not found in component`);
    process.exit(1);
  }

  console.log("PASS: ConnectionOverlay renders correct messages for all states and no forbidden regression text present.");
  process.exit(0);
}

runTest();
