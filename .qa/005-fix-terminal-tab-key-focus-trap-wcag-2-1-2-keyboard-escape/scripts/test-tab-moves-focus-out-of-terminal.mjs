#!/usr/bin/env node
// ──────────────────────────────────────────────────────
// Test: Tab key moves browser focus out of the terminal
// Criterion: US1.AC1 — "Given the terminal is focused, When the user presses Tab,
//   Then browser focus moves to the next focusable element outside the terminal."
// Feature: 005-fix-terminal-tab-key-focus-trap-wcag-2-1-2-keyboard-escape
// Generated: 2026-02-20T00:00:00Z
// ──────────────────────────────────────────────────────
//
// Prerequisites:
//   - Chrome running with --remote-debugging-port=9222
//   - kai-ui dev server running on http://localhost:3000
//   - Sidecar server running on ws://localhost:3001
//
// Run: node test-tab-moves-focus-out-of-terminal.mjs

import http from "node:http";

const CHROME_DEBUG_PORT = 9222;
const APP_URL = "http://localhost:3000";
const TIMEOUT_MS = 10000;

function cdpRequest(path) {
  return new Promise((resolve, reject) => {
    http
      .get({ hostname: "localhost", port: CHROME_DEBUG_PORT, path }, (res) => {
        let data = "";
        res.on("data", (c) => (data += c));
        res.on("end", () => resolve(JSON.parse(data)));
      })
      .on("error", reject);
  });
}

async function runTest() {
  const targets = await cdpRequest("/json");
  const page = targets.find((t) => t.type === "page");
  if (!page) {
    process.stderr.write("FAIL: No Chrome page target found. Is Chrome running with --remote-debugging-port=9222?\n");
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

  // Navigate to the app
  await send("Page.navigate", { url: APP_URL });
  await new Promise((r) => setTimeout(r, 3000)); // wait for terminal to mount and connect

  // Step 1: Click the xterm textarea to focus the terminal
  const focusResult = await send("Runtime.evaluate", {
    expression: `
      (() => {
        const el = document.querySelector('.xterm-helper-textarea');
        if (!el) return { ok: false, reason: 'xterm-helper-textarea not found' };
        el.focus();
        return { ok: true, focused: document.activeElement === el || document.activeElement?.closest('.xterm') !== null };
      })()
    `,
    returnByValue: true,
  });

  const focusData = focusResult?.result?.value;
  if (!focusData?.ok) {
    process.stderr.write(`FAIL: Could not focus terminal — ${focusData?.reason ?? "unknown"}\n`);
    process.stderr.write(`Expected: xterm-helper-textarea element exists and is focusable\n`);
    process.stderr.write(`Actual:   ${JSON.stringify(focusData)}\n`);
    ws.close();
    process.exit(1);
  }

  // Step 2: Press Tab and check that focus has moved away from the terminal
  await send("Input.dispatchKeyEvent", {
    type: "keyDown",
    key: "Tab",
    code: "Tab",
    keyCode: 9,
    modifiers: 0,
  });
  await send("Input.dispatchKeyEvent", {
    type: "keyUp",
    key: "Tab",
    code: "Tab",
    keyCode: 9,
    modifiers: 0,
  });

  await new Promise((r) => setTimeout(r, 300));

  // Step 3: Verify focus is no longer inside the terminal
  const checkResult = await send("Runtime.evaluate", {
    expression: `
      (() => {
        const active = document.activeElement;
        const insideTerminal = active?.closest('.xterm') !== null || active?.classList.contains('xterm-helper-textarea');
        return {
          activeTagName: active?.tagName ?? 'none',
          activeClassName: active?.className ?? '',
          insideTerminal,
        };
      })()
    `,
    returnByValue: true,
  });

  ws.close();

  const checkData = checkResult?.result?.value;
  if (!checkData) {
    process.stderr.write("FAIL: Could not evaluate focus state after Tab press\n");
    process.exit(1);
  }

  if (checkData.insideTerminal) {
    process.stderr.write("FAIL: Tab key did not move focus out of terminal (WCAG 2.1.2 keyboard trap still present)\n");
    process.stderr.write(`Expected: document.activeElement is outside .xterm\n`);
    process.stderr.write(`Actual:   activeElement=${checkData.activeTagName}.${checkData.activeClassName} is still inside terminal\n`);
    process.exit(1);
  }

  console.log(`PASS: Tab key moved focus out of terminal. activeElement after Tab: ${checkData.activeTagName}.${checkData.activeClassName}`);
  process.exit(0);
}

runTest().catch((err) => {
  process.stderr.write(`FAIL: Unexpected error: ${err.message}\n`);
  process.exit(1);
});
