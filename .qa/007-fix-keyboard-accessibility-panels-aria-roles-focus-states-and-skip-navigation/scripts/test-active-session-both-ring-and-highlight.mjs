// ──────────────────────────────────────────────────────
// Test: Active session button shows both selection highlight and focus ring when focused
// Criterion: US2.AC2 — "Given the active session button also has keyboard focus,
//   When inspecting the button,
//   Then both the selection highlight (neon-cyan border) and the focus ring (white ring) are present simultaneously."
// Feature: 007-fix-keyboard-accessibility-panels-aria-roles-focus-states-and-skip-navigation
// Generated: 2026-02-20T00:00:00Z
// ──────────────────────────────────────────────────────
//
// MANUAL TEST — MCP Chrome DevTools
//
// Prerequisites:
//   1. npm run dev
//   2. Chrome with --remote-debugging-port=9222
//   3. At least one session exists and is selected (active)
//
// Steps:
//   1. Navigate to http://localhost:3000 and ensure a session is selected.
//   2. mcp__chrome-devtools__evaluate_script
//      function: () => {
//        const activeBtn = document.querySelector('nav button[aria-selected="true"]');
//        if (!activeBtn) return { error: 'No active session button found' };
//        activeBtn.focus();
//        return {
//          ariaSelected: activeBtn.getAttribute('aria-selected'),
//          className: activeBtn.className,
//          isFocused: document.activeElement === activeBtn,
//        };
//      }
//      → Verify:
//        - ariaSelected === "true"
//        - isFocused === true
//        - className contains both "border-glow-cyan" (selection) AND "focus-visible:ring-white" (focus)
//   3. mcp__chrome-devtools__take_screenshot
//      → Visually confirm: white ring overlaid on cyan border simultaneously.
//
// Pass Criteria:
//   - isFocused is true
//   - className includes selection class ("bg-neon-cyan-dim/20" or "border-glow-cyan")
//   - className includes focus ring class ("focus-visible:ring-white")
//
// Fail Criteria:
//   - Focus ring disappears when button is active/selected
//   - Only one of selection highlight OR focus ring visible at a time

console.log("MANUAL TEST: US2.AC2 — active session button shows both highlight and focus ring");
console.log("Follow the MCP Chrome DevTools steps documented in this file.");
