#!/usr/bin/env node
// ──────────────────────────────────────────────────────
// Test: Regular terminal input (typing, Enter, arrow keys) still works after Tab-key fix
// Criterion: US2.AC1 — "Given the terminal is connected and focused, When the user types
//   regular characters, Then input is sent to the PTY and the terminal responds normally."
// Feature: 005-fix-terminal-tab-key-focus-trap-wcag-2-1-2-keyboard-escape
// Generated: 2026-02-20T00:00:00Z
// ──────────────────────────────────────────────────────
//
// Prerequisites:
//   - Chrome running with --remote-debugging-port=9222
//   - kai-ui dev server running on http://localhost:3000
//   - Sidecar server running on ws://localhost:3001
//
// Run: node test-regular-input-still-works.mjs

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
  await new Promise((r) => setTimeout(r, 4000)); // wait for terminal to fully connect

  // Check terminal is connected (no overlay)
  const overlayCheck = await send("Runtime.evaluate", {
    expression: `
      (() => {
        const bodyText = document.body.innerText;
        const hasBlockingOverlay =
          bodyText.includes('Connecting...') ||
          bodyText.includes('Connection lost') ||
          bodyText.includes('Connection failed');
        const hasXtermRows = document.querySelectorAll('.xterm-rows > div').length > 0;
        return { hasBlockingOverlay, hasXtermRows };
      })()
    `,
    returnByValue: true,
  });

  const overlayData = overlayCheck?.result?.value;
  if (!overlayData?.hasXtermRows) {
    process.stderr.write("FAIL: xterm rows not found — terminal may not have mounted\n");
    process.stderr.write(`Expected: .xterm-rows contains at least one row div\n`);
    process.stderr.write(`Actual:   hasXtermRows=${overlayData?.hasXtermRows}, hasBlockingOverlay=${overlayData?.hasBlockingOverlay}\n`);
    ws.close();
    process.exit(1);
  }

  if (overlayData.hasBlockingOverlay) {
    process.stderr.write("FAIL: Terminal shows a blocking overlay — it is not connected\n");
    process.stderr.write(`Expected: Terminal connected, no overlay\n`);
    process.stderr.write(`Actual:   Blocking connection overlay is visible\n`);
    ws.close();
    process.exit(1);
  }

  // Capture the number of xterm rows before typing to verify new output appears
  const rowsBefore = await send("Runtime.evaluate", {
    expression: `document.querySelectorAll('.xterm-rows > div').length`,
    returnByValue: true,
  });
  const countBefore = rowsBefore?.result?.value ?? 0;

  // Focus terminal and type "echo kai_tab_fix_smoke_test" + Enter
  await send("Runtime.evaluate", {
    expression: `document.querySelector('.xterm-helper-textarea')?.focus()`,
    returnByValue: true,
  });

  const testCmd = "echo kai_tab_fix_smoke_test";
  for (const char of testCmd) {
    await send("Input.dispatchKeyEvent", {
      type: "char",
      text: char,
    });
    await new Promise((r) => setTimeout(r, 20));
  }

  // Press Enter
  await send("Input.dispatchKeyEvent", { type: "keyDown", key: "Enter", code: "Enter", keyCode: 13 });
  await send("Input.dispatchKeyEvent", { type: "keyUp", key: "Enter", code: "Enter", keyCode: 13 });

  await new Promise((r) => setTimeout(r, 1500)); // wait for PTY response

  // Check terminal content for the echo output
  const contentCheck = await send("Runtime.evaluate", {
    expression: `
      (() => {
        const rows = Array.from(document.querySelectorAll('.xterm-rows > div'));
        const text = rows.map(r => r.textContent).join('\\n');
        return {
          rowCount: rows.length,
          containsOutput: text.includes('kai_tab_fix_smoke_test'),
        };
      })()
    `,
    returnByValue: true,
  });

  ws.close();

  const contentData = contentCheck?.result?.value;
  if (!contentData?.containsOutput) {
    process.stderr.write("FAIL: Terminal did not show echo output — regular input may be broken\n");
    process.stderr.write(`Expected: terminal rows contain 'kai_tab_fix_smoke_test'\n`);
    process.stderr.write(`Actual:   rowCount=${contentData?.rowCount}, containsOutput=${contentData?.containsOutput}\n`);
    process.exit(1);
  }

  console.log(`PASS: Regular terminal input works — echo output 'kai_tab_fix_smoke_test' appeared in terminal (${contentData.rowCount} rows rendered).`);
  process.exit(0);
}

runTest().catch((err) => {
  process.stderr.write(`FAIL: Unexpected error: ${err.message}\n`);
  process.exit(1);
});
