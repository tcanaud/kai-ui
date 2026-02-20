#!/usr/bin/env node
// ──────────────────────────────────────────────────────
// Test: ConnectionState enum contract — useTerminal hook exports correct type shape
// Criterion: IF1 — "useTerminal hook — ConnectionState enum: idle | connecting | connected |
//   disconnected | reconnecting | error"
// Feature: 002-fix-terminal-websocket-initial-connection-failure
// Generated: 2026-02-20T00:00:00Z
// ──────────────────────────────────────────────────────
//
// Prerequisites: None (static analysis only — no running server required)
//
// Run: node test-connection-state-enum-contract.mjs

import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const HOOK_PATH = resolve(
  new URL(".", import.meta.url).pathname,
  "../../../src/app/lib/use-terminal.ts"
);

// Normalize the path for this package
const NORMALIZED_PATH = "/Users/thibaudcanaud/__WORKSPACE__/__PERSO__/kai/packages/kai-ui/src/app/lib/use-terminal.ts";

const REQUIRED_STATES = ["idle", "connecting", "connected", "disconnected", "reconnecting", "error"];

function runTest() {
  let source;
  try {
    source = readFileSync(NORMALIZED_PATH, "utf-8");
  } catch (err) {
    console.error("FAIL");
    console.error(`Expected: use-terminal.ts exists at ${NORMALIZED_PATH}`);
    console.error(`Actual:   File not found — ${err.message}`);
    process.exit(1);
  }

  // Check ConnectionState type is exported
  if (!source.includes("export type ConnectionState")) {
    console.error("FAIL");
    console.error(`Expected: "export type ConnectionState" in use-terminal.ts`);
    console.error(`Actual:   Not found — ConnectionState is not exported`);
    process.exit(1);
  }

  // Check all required states are present in the type definition
  const missing = REQUIRED_STATES.filter((state) => !source.includes(`"${state}"`));
  if (missing.length > 0) {
    console.error("FAIL");
    console.error(`Expected: ConnectionState includes all of: ${REQUIRED_STATES.join(", ")}`);
    console.error(`Actual:   Missing states: ${missing.join(", ")}`);
    process.exit(1);
  }

  // Check useTerminal is exported
  if (!source.includes("export function useTerminal")) {
    console.error("FAIL");
    console.error(`Expected: "export function useTerminal" in use-terminal.ts`);
    console.error(`Actual:   useTerminal function not found or not exported`);
    process.exit(1);
  }

  // Check connectionState is returned from the hook
  if (!source.includes("connectionState")) {
    console.error("FAIL");
    console.error(`Expected: "connectionState" returned by useTerminal hook`);
    console.error(`Actual:   "connectionState" not found in hook source`);
    process.exit(1);
  }

  // Check retry function is returned
  if (!source.includes("retry")) {
    console.error("FAIL");
    console.error(`Expected: "retry" function returned by useTerminal hook`);
    console.error(`Actual:   "retry" not found in hook source`);
    process.exit(1);
  }

  console.log(`PASS: ConnectionState enum contract satisfied — all states present: ${REQUIRED_STATES.join(", ")}`);
  process.exit(0);
}

runTest();
