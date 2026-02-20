// ──────────────────────────────────────────────────────
// Test: "New Session" button displays a visible focus ring when keyboard-focused
// Criterion: US3.AC1 — "Given the sidebar is visible,
//   When the user Tabs to the 'New Session' button,
//   Then the button displays a focus-visible:ring-2 focus-visible:ring-white focus ring,
//   And the ring is visible against the sidebar background."
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
//   2. mcp__chrome-devtools__take_snapshot
//      → Find the "New Session" button uid in the sidebar.
//   3. mcp__chrome-devtools__evaluate_script
//      function: () => {
//        // Find the "New Session" button by text content
//        const allBtns = document.querySelectorAll('nav button');
//        const newSessionBtn = Array.from(allBtns).find(b => b.textContent?.includes('New Session'));
//        if (!newSessionBtn) return { error: 'New Session button not found' };
//        newSessionBtn.focus();
//        return {
//          isFocused: document.activeElement === newSessionBtn,
//          className: newSessionBtn.className,
//        };
//      }
//      → Verify className includes "focus-visible:ring-2" and "focus-visible:ring-white"
//   4. mcp__chrome-devtools__take_screenshot
//      → Visually confirm: white focus ring visible around the "New Session" button.
//
// Pass Criteria:
//   - Button is focusable (isFocused === true)
//   - className contains "focus-visible:ring-2" and "focus-visible:ring-white"
//   - Ring is visible (white against dark sidebar background)
//
// Fail Criteria:
//   - Button not focusable via Tab
//   - No focus-visible ring class present
//   - Ring not visible (e.g., same color as background)

console.log("MANUAL TEST: US3.AC1 — New Session button has visible focus ring");
console.log("Follow the MCP Chrome DevTools steps documented in this file.");
