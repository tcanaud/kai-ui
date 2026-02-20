#!/usr/bin/env node
// ──────────────────────────────────────────────────────
// Test: Terminal auto-reconnects after sidecar restart — no page reload required
// Criterion: US2.AC1 — "Given the terminal is connected and the sidecar is restarted,
//   When the sidecar becomes available again, Then the terminal reconnects and displays
//   a live shell prompt without requiring a page reload."
// Feature: 002-fix-terminal-websocket-initial-connection-failure
// Generated: 2026-02-20T00:00:00Z
// ──────────────────────────────────────────────────────
//
// Prerequisites:
//   - Chrome running with --remote-debugging-port=9222
//   - kai-ui dev server running on http://localhost:3000
//   - Sidecar server running and healthy on ws://localhost:3001
//   - The sidecar process must be restartable via: npm run dev:sidecar (adjust as needed)
//
// This test requires manual coordination: it will pause and prompt you to restart the sidecar.
//
// Run: node test-reconnect-after-sidecar-restart.mjs

import http from "node:http";
import readline from "node:readline";

const CHROME_DEBUG_PORT = 9222;
const APP_URL = "http://localhost:3000";
const RECONNECT_TIMEOUT_MS = 15000;

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
  const events = [];

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
    } else if (msg.method) {
      events.push(msg);
    }
  });

  await new Promise((r) => ws.on("open", r));
  await send("Page.enable");
  await send("Runtime.enable");

  // 1. Navigate and confirm initial connection
  console.log("Step 1: Navigating to app...");
  await send("Page.navigate", { url: APP_URL });
  await new Promise((r) => setTimeout(r, 4000));

  const initialState = await send("Runtime.evaluate", {
    expression: `document.body.innerText`,
    returnByValue: true,
  });
  const initialText = initialState?.result?.value ?? "";
  const isInitiallyConnected = !initialText.includes("Connection failed") &&
                                !initialText.includes("Connecting...");

  if (!isInitiallyConnected) {
    console.error("FAIL: Terminal did not reach connected state before sidecar restart test.");
    console.error(`Page content included: ${initialText.substring(0, 200)}`);
    ws.close();
    process.exit(1);
  }
  console.log("  OK: Terminal is connected.");

  // 2. Prompt user to restart sidecar
  await prompt("\nStep 2: Please restart the sidecar server now, then press Enter to continue...");

  // 3. Verify "Connection lost. Retrying..." appears (not "Disconnected. Reconnecting...")
  console.log("Step 3: Verifying reconnection overlay message...");
  let correctOverlaySeen = false;
  let wrongOverlaySeen = false;
  const observeStart = Date.now();

  while (Date.now() - observeStart < 5000) {
    const result = await send("Runtime.evaluate", {
      expression: `document.body.innerText`,
      returnByValue: true,
    });
    const text = result?.result?.value ?? "";
    if (text.includes("Connection lost. Retrying...")) {
      correctOverlaySeen = true;
    }
    if (text.includes("Disconnected. Reconnecting...")) {
      wrongOverlaySeen = true;
    }
    await new Promise((r) => setTimeout(r, 200));
  }

  if (wrongOverlaySeen) {
    console.error("FAIL");
    console.error(`Expected: "Connection lost. Retrying..." shown during reconnection`);
    console.error(`Actual:   "Disconnected. Reconnecting..." was shown — wrong state label`);
    ws.close();
    process.exit(1);
  }

  // 4. Wait for reconnection to succeed
  console.log("Step 4: Waiting for reconnection...");
  let reconnected = false;
  const reconnectStart = Date.now();

  while (Date.now() - reconnectStart < RECONNECT_TIMEOUT_MS) {
    await new Promise((r) => setTimeout(r, 500));
    const result = await send("Runtime.evaluate", {
      expression: `
        (() => {
          const rows = document.querySelectorAll('.xterm-rows > div');
          const text = document.body.innerText;
          const hasBlockingOverlay = text.includes('Connection lost') ||
            text.includes('Connection failed') ||
            text.includes('Connecting...');
          return rows.length > 0 && !hasBlockingOverlay;
        })()
      `,
      returnByValue: true,
    });
    if (result?.result?.value === true) {
      reconnected = true;
      break;
    }
  }

  ws.close();

  if (!reconnected) {
    console.error("FAIL");
    console.error(`Expected: Terminal reconnects and shows live prompt within ${RECONNECT_TIMEOUT_MS}ms`);
    console.error(`Actual:   Terminal did not reconnect within timeout after sidecar restart`);
    process.exit(1);
  }

  console.log("PASS: Terminal auto-reconnected after sidecar restart without page reload.");
  process.exit(0);
}

runTest().catch((err) => {
  console.error("FAIL: Unexpected error:", err.message);
  process.exit(1);
});
