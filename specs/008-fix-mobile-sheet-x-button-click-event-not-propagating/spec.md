# Spec: 008-fix-mobile-sheet-x-button-click-event-not-propagating

## Summary

Fix for the mobile sheet X button click event not propagating correctly. On mobile viewports the X (close) button inside the sheet does not close the sheet when tapped. Escape key dismissal and desktop close behaviour must remain unaffected.

---

## User Story 1 — X button closes the sheet on mobile

**As a** mobile user,
**I want** the X button inside the navigation sheet to close the sheet when I tap it,
**So that** I can dismiss the sidebar without resorting to a swipe or the backdrop.

### AC1

Given the mobile nav sheet is open (viewport <= 768px),
When the user taps/clicks the X close button,
Then the sheet closes and only the hamburger button is visible.

---

## User Story 2 — Escape key still closes the sheet

**As a** mobile or desktop user,
**I want** pressing Escape to still close the sheet,
**So that** keyboard-driven dismissal is not regressed by the fix.

### AC1

Given the mobile nav sheet is open,
When the user presses the Escape key,
Then the sheet closes and only the hamburger button is visible.

---

## User Story 3 — Desktop close has no regression

**As a** desktop user,
**I want** the sheet (if triggered on desktop) to still close via the X button,
**So that** the fix for mobile does not break desktop behaviour.

### AC1

Given the viewport is >= 1024px and the nav sheet is open,
When the user clicks the X close button,
Then the sheet closes and the desktop sidebar returns to its normal state.
