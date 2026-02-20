#!/usr/bin/env node
// ──────────────────────────────────────────────────────
// Test: Shift+Tab moves browser focus to the previous focusable element
// Criterion: US1.AC2 — "Given the terminal is focused, When the user presses Shift+Tab,
//   Then browser focus moves to the previous focusable element."
// Feature: 005-fix-terminal-tab-key-focus-trap-wcag-2-1-2-keyboard-escape
// Generated: 2026-02-20T00:00:00Z
// ──────────────────────────────────────────────────────
//
// Prerequisites:
//   - Chrome running with --remote-debugging-port=9222
//   - kai-ui dev server running on http://localhost:3000
//   - Sidecar server running on ws://localhost:3001
//
// Run: node test-shift-tab-moves-focus-to-previous-element.mjs

import http from "node:http";

const CHROME_DEBUG_PORT = 9222;
const APP_URL = "http://localhost:3000";

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

  await send("Page.navigate", { url: APP_URL });
  await new Promise((r) => setTimeout(r, 3000));

  // Focus the terminal
  const focusResult = await send("Runtime.evaluate", {
    expression: `
      (() => {
        const el = document.querySelector('.xterm-helper-textarea');
        if (!el) return { ok: false, reason: 'xterm-helper-textarea not found' };
        el.focus();
        return { ok: true };
      })()
    `,
    returnByValue: true,
  });

  if (!focusResult?.result?.value?.ok) {
    process.stderr.write("FAIL: Could not focus terminal\n");
    ws.close();
    process.exit(1);
  }

  // Record what element had focus before (so we can verify it changed)
  const beforeResult = await send("Runtime.evaluate", {
    expression: `document.activeElement?.tagName + '.' + (document.activeElement?.className ?? '')`,
    returnByValue: true,
  });
  const beforeFocus = beforeResult?.result?.value ?? "unknown";

  // Press Shift+Tab (modifiers: 8 = Shift in CDP)
  await send("Input.dispatchKeyEvent", {
    type: "keyDown",
    key: "Tab",
    code: "Tab",
    keyCode: 9,
    modifiers: 8, // Shift
  });
  await send("Input.dispatchKeyEvent", {
    type: "keyUp",
    key: "Tab",
    code: "Tab",
    keyCode: 9,
    modifiers: 8,
  });

  await new Promise((r) => setTimeout(r, 300));

  const afterResult = await send("Runtime.evaluate", {
    expression: `
      (() => {
        const active = document.activeElement;
        const insideTerminal = active?.closest('.xterm') !== null || active?.classList.contains('xterm-helper-textarea');
        return {
          activeDesc: (active?.tagName ?? 'none') + '.' + (active?.className ?? ''),
          insideTerminal,
        };
      })()
    `,
    returnByValue: true,
  });

  ws.close();

  const afterData = afterResult?.result?.value;
  if (!afterData) {
    process.stderr.write("FAIL: Could not evaluate focus state after Shift+Tab\n");
    process.exit(1);
  }

  if (afterData.insideTerminal) {
    process.stderr.write("FAIL: Shift+Tab did not move focus out of terminal\n");
    process.stderr.write(`Expected: focus leaves .xterm on Shift+Tab\n`);
    process.stderr.write(`Actual:   focus stayed inside terminal (${afterData.activeDesc})\n`);
    process.exit(1);
  }

  if (afterData.activeDesc === beforeFocus) {
    process.stderr.write("FAIL: Focus element did not change after Shift+Tab\n");
    process.stderr.write(`Expected: a different element receives focus\n`);
    process.stderr.write(`Actual:   same element before and after: ${beforeFocus}\n`);
    process.exit(1);
  }

  console.log(`PASS: Shift+Tab moved focus from terminal (${beforeFocus}) to ${afterData.activeDesc}`);
  process.exit(0);
}

runTest().catch((err) => {
  process.stderr.write(`FAIL: Unexpected error: ${err.message}\n`);
  process.exit(1);
});
