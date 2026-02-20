// ──────────────────────────────────────────────────────
// Test: Exactly one panel has aria-pressed="true" after activation; all others are false
// Criterion: US1.AC3 — "Given a panel is active (aria-pressed='true'),
//   When the user Tab-focuses the same panel and checks the DOM,
//   Then aria-pressed is 'true' on the active panel,
//   And aria-pressed is 'false' on all other panels."
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
//   1. Navigate to http://localhost:3000 and select a session.
//   2. Activate the "Editor panel" by clicking it or via keyboard.
//   3. mcp__chrome-devtools__evaluate_script
//      function: () => {
//        const panels = document.querySelectorAll('[role="button"][aria-label$=" panel"]');
//        return Array.from(panels).map(el => ({
//          label: el.getAttribute('aria-label'),
//          pressed: el.getAttribute('aria-pressed'),
//        }));
//      }
//      → PASS if exactly one entry has pressed="true" (the activated panel),
//        and all others have pressed="false".
//
// Pass Criteria:
//   - Exactly 1 panel has aria-pressed="true"
//   - All other 4 panels have aria-pressed="false"
//
// Fail Criteria:
//   - More than one panel with aria-pressed="true"
//   - No panel with aria-pressed="true" after activation
//   - Any panel missing the aria-pressed attribute entirely

console.log("MANUAL TEST: US1.AC3 — only one panel aria-pressed=true at a time");
console.log("Follow the MCP Chrome DevTools steps documented in this file.");
