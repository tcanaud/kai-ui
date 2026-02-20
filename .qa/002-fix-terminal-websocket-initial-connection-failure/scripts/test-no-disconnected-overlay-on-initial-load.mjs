#!/usr/bin/env node
// ──────────────────────────────────────────────────────
// Test: "Disconnected. Reconnecting..." overlay NEVER appears on initial page load
// Criterion: US1.AC2 — "Given the sidecar server is running and healthy, When a user
//   navigates to the application URL, Then the 'Disconnected. Reconnecting...' overlay
//   is never displayed during the initial connection sequence."
// Feature: 002-fix-terminal-websocket-initial-connection-failure
// Generated: 2026-02-20T00:00:00Z
// ──────────────────────────────────────────────────────
//
// Prerequisites:
//   - Chrome running with --remote-debugging-port=9222
//   - kai-ui dev server running on http://localhost:3000
//   - Sidecar server running and healthy on ws://localhost:3001
//
// Run: node test-no-disconnected-overlay-on-initial-load.mjs

import http from "node:http";

const CHROME_DEBUG_PORT = 9222;
const APP_URL = "http://localhost:3000";
const OBSERVATION_WINDOW_MS = 5000; // watch for 5 seconds after navigation
const FORBIDDEN_TEXT = "Disconnected. Reconnecting...";

function cdpRequest(path, method = "GET", body = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: "localhost",
      port: CHROME_DEBUG_PORT,
      path,
      method,
      headers: body ? { "Content-Type": "application/json" } : {},
    };
    const req = http.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        try {
          resolve(JSON.parse(data));
        } catch {
          resolve(data);
        }
      });
    });
    req.on("error", reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function getWebSocketDebuggerUrl() {
  const targets = await cdpRequest("/json");
  const page = targets.find((t) => t.type === "page");
  if (!page) throw new Error("No page target found in Chrome DevTools");
  return page.webSocketDebuggerUrl;
}

async function runTest() {
  // 1. Connect to Chrome via CDP WebSocket
  const wsUrl = await getWebSocketDebuggerUrl();

  const { default: WebSocket } = await import("ws").catch(() => {
    // Fallback: use built-in if ws is not available
    return { default: null };
  });

  if (!WebSocket) {
    // Use Node.js built-in WebSocket (Node 22+) or fail gracefully
    console.error("FAIL: 'ws' package not found. Install it or use Node 22+.");
    process.exit(1);
  }

  const ws = new WebSocket(wsUrl);
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

  await new Promise((resolve) => ws.on("open", resolve));

  // 2. Enable DOM and Runtime
  await send("DOM.enable");
  await send("Runtime.enable");

  // 3. Navigate to app URL (fresh load)
  await send("Page.enable");
  await send("Page.navigate", { url: APP_URL });

  // Wait for load event
  await new Promise((resolve) => {
    const check = setInterval(() => {
      const loadEvent = events.find((e) => e.method === "Page.loadEventFired");
      if (loadEvent) {
        clearInterval(check);
        resolve();
      }
    }, 100);
    setTimeout(() => {
      clearInterval(check);
      resolve(); // proceed anyway after 10s
    }, 10000);
  });

  // 4. Poll the DOM for the forbidden text during the observation window
  let forbiddenFound = false;
  const start = Date.now();

  while (Date.now() - start < OBSERVATION_WINDOW_MS) {
    const result = await send("Runtime.evaluate", {
      expression: `document.body.innerText.includes(${JSON.stringify(FORBIDDEN_TEXT)})`,
      returnByValue: true,
    });
    if (result?.result?.value === true) {
      forbiddenFound = true;
      break;
    }
    await new Promise((r) => setTimeout(r, 200));
  }

  ws.close();

  // 5. Assert
  if (forbiddenFound) {
    console.error("FAIL");
    console.error(`Expected: "${FORBIDDEN_TEXT}" is NEVER shown during initial connection`);
    console.error(`Actual:   "${FORBIDDEN_TEXT}" WAS found in the DOM`);
    process.exit(1);
  }

  console.log("PASS: 'Disconnected. Reconnecting...' was never displayed during initial page load.");
  process.exit(0);
}

runTest().catch((err) => {
  console.error("FAIL: Unexpected error:", err.message);
  process.exit(1);
});
