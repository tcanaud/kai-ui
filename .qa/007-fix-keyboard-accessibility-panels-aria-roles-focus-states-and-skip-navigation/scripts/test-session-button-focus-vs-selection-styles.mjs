// ──────────────────────────────────────────────────────
// Test: Session buttons show a white focus ring distinct from the neon-cyan selection highlight
// Criterion: US2.AC1 — "Given a session list with at least one session,
//   When a session button receives keyboard focus (Tab),
//   Then a white focus ring (focus-visible:ring-2 focus-visible:ring-white) is visible,
//   And this ring is distinct from the neon-cyan border that marks the active session."
// Feature: 007-fix-keyboard-accessibility-panels-aria-roles-focus-states-and-skip-navigation
// Generated: 2026-02-20T00:00:00Z
// ──────────────────────────────────────────────────────
//
// MANUAL TEST — MCP Chrome DevTools
//
// Prerequisites:
//   1. npm run dev
//   2. Chrome with --remote-debugging-port=9222
//   3. At least 2 sessions exist (one active, one inactive)
//
// Steps:
//   1. Navigate to http://localhost:3000.
//   2. Identify an inactive session button (not the currently selected one).
//   3. mcp__chrome-devtools__evaluate_script
//      function: () => {
//        // Tab to focus an inactive session button
//        const buttons = document.querySelectorAll('nav[aria-label="Sessions"] button:not([data-state])');
//        // Find first session item button (not New Session)
//        const sessionBtns = Array.from(document.querySelectorAll('nav button[aria-selected]'));
//        if (sessionBtns.length === 0) return { error: 'No session buttons found' };
//        const inactive = sessionBtns.find(b => b.getAttribute('aria-selected') === 'false');
//        inactive?.focus();
//        const style = window.getComputedStyle(inactive);
//        return {
//          ariaSelected: inactive?.getAttribute('aria-selected'),
//          className: inactive?.className,
//        };
//      }
//      → Verify className contains "focus-visible:ring-2" and "focus-visible:ring-white"
//   4. mcp__chrome-devtools__take_screenshot
//      → Visually confirm: white ring appears around the focused button,
//        NOT the neon-cyan glow that marks the selected session.
//
// Pass Criteria:
//   - Session button className includes "focus-visible:ring-2 focus-visible:ring-white"
//   - Inactive session button: only white ring visible when focused (no cyan border)
//   - Active session button: cyan border present regardless of focus
//
// Fail Criteria:
//   - No ring visible on focus
//   - Focus ring is the same style as selection highlight (indistinguishable)
//   - Class "focus-visible:ring-white" absent from button element

console.log("MANUAL TEST: US2.AC1 — session button focus ring distinct from selection");
console.log("Follow the MCP Chrome DevTools steps documented in this file.");
