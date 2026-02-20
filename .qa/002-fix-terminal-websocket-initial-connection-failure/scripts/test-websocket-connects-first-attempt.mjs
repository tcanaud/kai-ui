#!/usr/bin/env node
// ──────────────────────────────────────────────────────
// Test: WebSocket connection established on first attempt — no reconnection loop entered
// Criterion: US1.AC3 — "Given the sidecar server is running and a session is pre-selected
//   on load, When the terminal panel mounts, Then the WebSocket connection is established
//   successfully on the first attempt without falling into the reconnection loop."
// Feature: 002-fix-terminal-websocket-initial-connection-failure
// Generated: 2026-02-20T00:00:00Z
// ──────────────────────────────────────────────────────
//
// Prerequisites:
//   - Chrome running with --remote-debugging-port=9222
//   - kai-ui dev server running on http://localhost:3000
//   - Sidecar server running and healthy on ws://localhost:3001
//
// Run: node test-websocket-connects-first-attempt.mjs

import http from "node:http";

const CHROME_DEBUG_PORT = 9222;
const APP_URL = "http://localhost:3000";
const OBSERVATION_WINDOW_MS = 5000;

// These overlays indicate reconnection loop was entered (should NOT appear on first load)
const RECONNECT_TEXTS = ["Connection lost. Retrying...", "Disconnected. Reconnecting..."];

function cdpRequest(path) {
  return new Promise((resolve, reject) => {
    http.get({ hostname: "localhost", port: CHROME_DEBUG_PORT, path }, (res) => {
      let data = "";
      res.on("data", (c) => (data += c));
      res.on("end", () => resolve(JSON.parse(data)));
    }).on("error", reject);
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
  const networkWsEvents = [];

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
      // Track WebSocket network events to count connection attempts
      if (msg.method === "Network.webSocketCreated" ||
          msg.method === "Network.webSocketClosed" ||
          msg.method === "Network.webSocketFrameError") {
        networkWsEvents.push(msg);
      }
    }
  });

  await new Promise((r) => ws.on("open", r));
  await send("Page.enable");
  await send("Network.enable");
  await send("Runtime.enable");

  await send("Page.navigate", { url: APP_URL });

  // Observe for OBSERVATION_WINDOW_MS
  await new Promise((r) => setTimeout(r, OBSERVATION_WINDOW_MS));

  // Check 1: No reconnect overlay text appeared in the DOM during observation
  const pageTextResult = await send("Runtime.evaluate", {
    expression: `document.body.innerText`,
    returnByValue: true,
  });
  const pageText = pageTextResult?.result?.value ?? "";

  ws.close();

  const reconnectTextFound = RECONNECT_TEXTS.find((t) => pageText.includes(t));
  if (reconnectTextFound) {
    console.error("FAIL");
    console.error(`Expected: No reconnection overlay text visible after initial load`);
    console.error(`Actual:   Found "${reconnectTextFound}" in the page — reconnection loop was entered`);
    process.exit(1);
  }

  // Check 2: Count WebSocket connections to sidecar — should be exactly 1
  const sidecarWsCreations = networkWsEvents.filter(
    (e) => e.method === "Network.webSocketCreated" &&
           e.params?.url?.includes("localhost:3001")
  );

  if (sidecarWsCreations.length === 0) {
    console.error("FAIL");
    console.error(`Expected: At least 1 WebSocket connection to localhost:3001`);
    console.error(`Actual:   0 WebSocket connections detected — terminal may not have connected at all`);
    process.exit(1);
  }

  if (sidecarWsCreations.length > 1) {
    console.error("FAIL");
    console.error(`Expected: Exactly 1 WebSocket connection attempt on initial load`);
    console.error(`Actual:   ${sidecarWsCreations.length} WebSocket connections — reconnection loop likely entered`);
    process.exit(1);
  }

  console.log(`PASS: WebSocket connected in exactly 1 attempt and no reconnection overlay appeared.`);
  process.exit(0);
}

runTest().catch((err) => {
  console.error("FAIL: Unexpected error:", err.message);
  process.exit(1);
});
