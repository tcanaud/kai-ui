// ──────────────────────────────────────────────────────
// Test: Sidebar root element is a <nav> landmark with aria-label="Sessions"
// Criterion: US4.AC1 — "Given the page is loaded,
//   When inspecting the DOM,
//   Then the sidebar root element is a <nav> with aria-label='Sessions',
//   And this provides a landmark that assistive technology can jump to directly."
// Feature: 007-fix-keyboard-accessibility-panels-aria-roles-focus-states-and-skip-navigation
// Generated: 2026-02-20T00:00:00Z
// ──────────────────────────────────────────────────────
//
// MANUAL TEST — MCP Chrome DevTools
//
// Prerequisites:
//   1. npm run dev
//   2. Chrome with --remote-debugging-port=9222
//
// Steps:
//   1. mcp__chrome-devtools__navigate_page  url="http://localhost:3000"
//   2. mcp__chrome-devtools__evaluate_script
//      function: () => {
//        const nav = document.querySelector('nav[aria-label="Sessions"]');
//        return {
//          exists: !!nav,
//          tagName: nav?.tagName,
//          ariaLabel: nav?.getAttribute('aria-label'),
//        };
//      }
//      → PASS if exists=true, tagName="NAV", ariaLabel="Sessions"
//   3. mcp__chrome-devtools__take_snapshot
//      → Snapshot should list a "navigation" landmark with label "Sessions"
//        in the accessibility tree.
//
// Pass Criteria:
//   - <nav aria-label="Sessions"> exists in the DOM
//   - Snapshot accessibility tree shows a "navigation" landmark labelled "Sessions"
//
// Fail Criteria:
//   - No <nav> found
//   - nav missing aria-label
//   - aria-label value is not exactly "Sessions"

console.log("MANUAL TEST: US4.AC1 — sidebar nav landmark with aria-label=Sessions");
console.log("Follow the MCP Chrome DevTools steps documented in this file.");
