// ──────────────────────────────────────────────────────
// Test: All panel buttons are reachable via Tab key navigation
// Criterion: US1.AC1 — "Given the page has loaded with a session selected,
//   When the user presses Tab to cycle through interactive elements,
//   Then each panel (Terminal, Editor, Playbook, Chat, Assistant) receives focus in order,
//   And each panel is reachable via keyboard Tab navigation."
// Feature: 007-fix-keyboard-accessibility-panels-aria-roles-focus-states-and-skip-navigation
// Generated: 2026-02-20T00:00:00Z
// ──────────────────────────────────────────────────────
//
// MANUAL TEST — MCP Chrome DevTools
//
// Prerequisites:
//   1. Run: npm run dev  (app on http://localhost:3000)
//   2. Chrome launched with: --remote-debugging-port=9222
//   3. At least one session exists (or create one via the UI first)
//
// Steps:
//   1. mcp__chrome-devtools__navigate_page  url="http://localhost:3000"
//   2. Click on a session to load PanelLayout.
//   3. mcp__chrome-devtools__take_snapshot
//      → Verify snapshot contains elements with role="button" and
//        aria-label matching: "Terminal panel", "Editor panel",
//        "Playbook panel", "Chat panel", "Assistant panel"
//   4. mcp__chrome-devtools__evaluate_script
//      function: () => {
//        const panels = document.querySelectorAll('[role="button"][aria-label$=" panel"]');
//        return Array.from(panels).map(el => ({
//          label: el.getAttribute('aria-label'),
//          tabIndex: el.tabIndex,
//        }));
//      }
//      → PASS if result has 5 entries, each with tabIndex === 0
//   5. Focus the body, then press Tab repeatedly and verify each panel
//      gets focused in sequence using evaluate_script to check document.activeElement.
//
// Pass Criteria:
//   - 5 panel elements found with role="button" and tabIndex=0
//   - Each panel is reachable by Tab key (browser cycles through them)
//
// Fail Criteria:
//   - Any panel missing tabIndex=0 or role="button"
//   - Fewer than 5 panels found

console.log("MANUAL TEST: US1.AC1 — panels keyboard tab focusable");
console.log("Follow the MCP Chrome DevTools steps documented in this file.");
console.log("See .knowledge/guides/qa-testing-mcp-chrome.md for the full workflow.");
