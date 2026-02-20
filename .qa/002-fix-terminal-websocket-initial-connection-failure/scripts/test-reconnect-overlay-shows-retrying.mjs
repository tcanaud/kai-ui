#!/usr/bin/env node
// ──────────────────────────────────────────────────────
// Test: "Connection lost. Retrying..." shown during reconnection (not "Disconnected. Reconnecting...")
// Criterion: US2.AC2 — "Given a reconnection attempt is in progress, When the sidecar is
//   not yet available, Then the 'Connection lost. Retrying...' message is shown — not
//   'Disconnected. Reconnecting...' — to clearly distinguish from an initial connection failure."
// Feature: 002-fix-terminal-websocket-initial-connection-failure
// Generated: 2026-02-20T00:00:00Z
// ──────────────────────────────────────────────────────
//
// Prerequisites:
//   - Chrome running with --remote-debugging-port=9222
//   - kai-ui dev server running on http://localhost:3000
//   - Sidecar server running initially, then manually stopped during test
//
// Run: node test-reconnect-overlay-shows-retrying.mjs

import http from "node:http";
import readline from "node:readline";

const CHROME_DEBUG_PORT = 9222;
const APP_URL = "http://localhost:3000";

function cdpRequest(path) {
  return new Promise((resolve, reject) => {
    http.get({ hostname: "localhost", port: CHROME_DEBUG_PORT, path }, (res) => {
      let data = "";
      res.on("data", (c) => (data += c));
      res.on("end", () => resolve(JSON.parse(data)));
    }).on("error", reject);
  });
}

function prompt(question) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  return new Promise((resolve) => {
    rl.question(question, (answer) => { rl.close(); resolve(answer); });
  });
}

async function runTest() {
  const targets = await cdpRequest("/json");
  const page = targets.find((t) => t.type === "page");
  if (!page) {
    console.error("FAIL: No Chrome page target found.");
    process.exit(1);
  }

  const { default: WebSocket } = await import("ws");
  const ws = new WebSocket(page.webSocketDebuggerUrl);
  let msgId = 0;
  const pending = new Map();

  function send(method, params = {}) {
    return new Promise((resolve, reject) => {
      const id = ++msgId;
      pending.set(id, { resolve, reject });
      ws.send(JSON.stringify({ id, method, params }));
    });
  }

  ws.on("message", (raw) => {
    const msg = JSON.parse(raw.toString());
    if (msg.id && pending.has(msg.id)) {
      const { resolve, reject } = pending.get(msg.id);
      pending.delete(msg.id);
      if (msg.error) reject(new Error(msg.error.message));
      else resolve(msg.result);
    }
  });

  await new Promise((r) => ws.on("open", r));
  await send("Page.enable");
  await send("Runtime.enable");

  // 1. Load app and confirm connected
  console.log("Step 1: Loading app and confirming initial connection...");
  await send("Page.navigate", { url: APP_URL });
  await new Promise((r) => setTimeout(r, 4000));

  const initial = await send("Runtime.evaluate", {
    expression: `
      (() => {
        const rows = document.querySelectorAll('.xterm-rows > div');
        const text = document.body.innerText;
        return rows.length > 0 && !text.includes('Connecting...') && !text.includes('Connection failed');
      })()
    `,
    returnByValue: true,
  });

  if (!initial?.result?.value) {
    console.error("FAIL: Terminal not in connected state before test. Cannot proceed.");
    ws.close();
    process.exit(1);
  }
  console.log("  OK: Terminal connected.");

  // 2. Prompt to stop sidecar
  await prompt("\nStep 2: Please STOP the sidecar server now, then press Enter...");

  // 3. Observe overlay within 6 seconds
  console.log("Step 3: Observing overlay during reconnection attempt...");
  let correctMessageSeen = false;
  let wrongMessageSeen = false;
  const start = Date.now();

  while (Date.now() - start < 6000) {
    const result = await send("Runtime.evaluate", {
      expression: `document.body.innerText`,
      returnByValue: true,
    });
    const text = result?.result?.value ?? "";

    if (text.includes("Connection lost. Retrying...")) {
      correctMessageSeen = true;
    }
    if (text.includes("Disconnected. Reconnecting...")) {
      wrongMessageSeen = true;
    }
    await new Promise((r) => setTimeout(r, 200));
  }

  ws.close();

  if (wrongMessageSeen) {
    console.error("FAIL");
    console.error(`Expected: "Connection lost. Retrying..." shown when reconnecting after drop`);
    console.error(`Actual:   "Disconnected. Reconnecting..." appeared — this label is reserved for initial connection and must not appear here`);
    process.exit(1);
  }

  if (!correctMessageSeen) {
    console.error("FAIL");
    console.error(`Expected: "Connection lost. Retrying..." shown during reconnection`);
    console.error(`Actual:   Message was never shown — sidecar may still be running or reconnection state was not reached`);
    process.exit(1);
  }

  console.log('PASS: "Connection lost. Retrying..." was shown correctly during reconnection.');
  process.exit(0);
}

runTest().catch((err) => {
  console.error("FAIL: Unexpected error:", err.message);
  process.exit(1);
});
