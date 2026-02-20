# Spec: 003-fix-mobile-responsive-layout-sheet-close-failure-and-tablet-breakpoint

## Summary

Hotfix for three regressions in the responsive layout:
1. Mobile sheet (MobileNav) cannot be closed via the X button, backdrop click, or Escape key.
2. At 768px (tablet breakpoint), the desktop sidebar is visible instead of the hamburger button.
3. Opening "New Session" from the mobile sheet causes both the sheet and dialog to stack, creating a double-overlay.

---

## User Story 1 — Mobile sheet can be closed

**As a** mobile user,
**I want** to close the navigation sheet via the X button, backdrop, or Escape key,
**So that** I can dismiss the sidebar and return to the main content.

### AC1

Given the mobile nav sheet is open,
When the user clicks the X close button inside the sheet,
Then the sheet closes and only the hamburger button is visible.

### AC2

Given the mobile nav sheet is open,
When the user clicks the backdrop overlay outside the sheet,
Then the sheet closes and only the hamburger button is visible.

### AC3

Given the mobile nav sheet is open,
When the user presses the Escape key,
Then the sheet closes and only the hamburger button is visible.

---

## User Story 2 — Tablet breakpoint shows hamburger, not desktop sidebar

**As a** tablet user at 768px viewport width,
**I want** to see the hamburger button instead of the desktop sidebar,
**So that** the layout is optimised for my screen size.

### AC1

Given the viewport width is 768px,
When the page loads,
Then the hamburger button is visible and the desktop sidebar is hidden.

### AC2

Given the viewport width is 1024px or wider,
When the page loads,
Then the desktop sidebar is visible and the hamburger button is hidden.

---

## User Story 3 — New Session from mobile sheet does not stack overlays

**As a** mobile user,
**I want** opening "New Session" from the mobile sheet to close the sheet before the dialog appears,
**So that** there is never a double-overlay of sheet + dialog at the same time.

### AC1

Given the mobile nav sheet is open,
When the user taps "New Session",
Then the sheet closes before the New Session dialog opens (no simultaneous sheet + dialog).

### AC2

Given the New Session dialog was opened from the mobile sheet,
When the user cancels or closes the dialog,
Then only the main content is visible — the sheet does not reappear automatically.
