#!/usr/bin/env node
// ──────────────────────────────────────────────────────
// Test: Terminal panel displays a live shell prompt within 3 seconds of page load
// Criterion: US1.AC1 — "Given the sidecar server is running and healthy, When a user
//   navigates to the application URL in their browser, Then the terminal panel displays
//   a live shell prompt within 3 seconds of the page becoming interactive."
// Feature: 002-fix-terminal-websocket-initial-connection-failure
// Generated: 2026-02-20T00:00:00Z
// ──────────────────────────────────────────────────────
//
// Prerequisites:
//   - Chrome running with --remote-debugging-port=9222
//   - kai-ui dev server running on http://localhost:3000
//   - Sidecar server running and healthy on ws://localhost:3001
//
// Run: node test-shell-prompt-within-3s.mjs

import http from "node:http";

const CHROME_DEBUG_PORT = 9222;
const APP_URL = "http://localhost:3000";
const DEADLINE_MS = 3000;

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
    console.error("FAIL: No Chrome page target found. Is Chrome running with --remote-debugging-port=9222?");
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

  // Navigate and record the time when the page becomes interactive
  const navStart = Date.now();
  await send("Page.navigate", { url: APP_URL });

  // Wait for DOMContentLoaded
  await new Promise((resolve) => {
    const interval = setInterval(() => {
      if (events.find((e) => e.method === "Page.domContentEventFired")) {
        clearInterval(interval);
        resolve();
      }
    }, 50);
    setTimeout(() => { clearInterval(interval); resolve(); }, 8000);
  });

  const interactiveTime = Date.now();

  // Poll for xterm canvas or terminal row content (shell prompt indicator)
  // We check for the xterm viewport element which appears when the terminal has rendered
  let shellPromptAppeared = false;
  let elapsed = 0;

  while (elapsed < DEADLINE_MS + 500) {
    await new Promise((r) => setTimeout(r, 100));
    elapsed = Date.now() - interactiveTime;

    const result = await send("Runtime.evaluate", {
      expression: `
        (() => {
          // Check if xterm has rendered rows (shell prompt means content exists)
          const rows = document.querySelectorAll('.xterm-rows > div');
          if (rows.length === 0) return false;
          // Check ConnectionOverlay is not blocking (i.e., "connected" = no overlay)
          const overlayText = document.body.innerText;
          const hasConnectingOverlay = overlayText.includes('Connecting...') ||
            overlayText.includes('Connection lost') ||
            overlayText.includes('Connection failed');
          // Terminal rows exist and no blocking overlay = shell prompt visible
          return rows.length > 0 && !hasConnectingOverlay;
        })()
      `,
      returnByValue: true,
    });

    if (result?.result?.value === true) {
      shellPromptAppeared = true;
      break;
    }

    if (elapsed >= DEADLINE_MS) break;
  }

  ws.close();

  if (!shellPromptAppeared) {
    console.error("FAIL");
    console.error(`Expected: Live shell prompt visible within ${DEADLINE_MS}ms of page becoming interactive`);
    console.error(`Actual:   Terminal did not show a connected, prompt-ready state within ${DEADLINE_MS}ms (elapsed: ${elapsed}ms)`);
    process.exit(1);
  }

  console.log(`PASS: Live shell prompt appeared within ${elapsed}ms (deadline: ${DEADLINE_MS}ms).`);
  process.exit(0);
}

runTest().catch((err) => {
  console.error("FAIL: Unexpected error:", err.message);
  process.exit(1);
});
