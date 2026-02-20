// ──────────────────────────────────────────────────────
// Test: Pressing Enter/Space on a focused panel sets aria-pressed="true"
// Criterion: US1.AC2 — "Given a panel has keyboard focus,
//   When the user presses Enter or Space,
//   Then aria-pressed on that panel changes to true,
//   And the panel is visually activated."
// Feature: 007-fix-keyboard-accessibility-panels-aria-roles-focus-states-and-skip-navigation
// Generated: 2026-02-20T00:00:00Z
// ──────────────────────────────────────────────────────
//
// MANUAL TEST — MCP Chrome DevTools
//
// Prerequisites:
//   1. npm run dev
//   2. Chrome with --remote-debugging-port=9222
//   3. Session loaded (PanelLayout visible)
//
// Steps:
//   1. mcp__chrome-devtools__navigate_page  url="http://localhost:3000"
//   2. Select a session so PanelLayout renders.
//   3. mcp__chrome-devtools__evaluate_script
//      function: () => {
//        const panel = document.querySelector('[aria-label="Terminal panel"]');
//        panel?.focus();
//        return panel?.getAttribute('aria-pressed');
//      }
//      → Before activation: aria-pressed should be "false"
//   4. mcp__chrome-devtools__press_key  key="Enter"
//   5. mcp__chrome-devtools__evaluate_script
//      function: () => {
//        const panel = document.querySelector('[aria-label="Terminal panel"]');
//        return panel?.getAttribute('aria-pressed');
//      }
//      → PASS if result is "true"
//   6. Repeat with Space key for a different panel (e.g., Editor panel).
//
// Pass Criteria:
//   - After Enter: aria-pressed changes from "false" to "true"
//   - After Space: same behavior
//
// Fail Criteria:
//   - aria-pressed remains "false" after keypress
//   - Panel has no aria-pressed attribute

console.log("MANUAL TEST: US1.AC2 — aria-pressed toggles on Enter/Space");
console.log("Follow the MCP Chrome DevTools steps documented in this file.");
