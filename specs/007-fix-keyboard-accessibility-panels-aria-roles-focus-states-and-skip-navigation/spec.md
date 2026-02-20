# Spec: Fix Keyboard Accessibility — Panels ARIA Roles, Focus States, and Skip Navigation

**Feature**: 007-fix-keyboard-accessibility-panels-aria-roles-focus-states-and-skip-navigation
**Status**: hotfix
**Created**: 2026-02-20

## Problem

Panel containers in `PanelLayout` and session buttons in the sidebar lacked consistent keyboard accessibility: panels had no focusable role, session items had no visible focus distinction from selection state, the "New Session" button lacked a visible focus ring, and the sidebar had no landmark or skip link for keyboard-only users.

## Fix

- Each panel `<div>` gets `role="button"`, `tabIndex={0}`, `aria-pressed`, `aria-label`, and focus-visible ring styles.
- Session `<button>` elements get distinct `focus-visible:ring-*` styles separate from the `isActive` border glow.
- The "New Session" `<Button>` gets `focus-visible:ring-2 focus-visible:ring-white` styles.
- The sidebar root `<nav aria-label="Sessions">` provides the landmark.
- A skip link `<a href="#main-content">` is rendered as the first child of the sidebar, visible only on focus.

---

## User Story 1 — Panels are keyboard-focusable and communicate state

**As a** keyboard-only user,
**I want** to Tab through the panel buttons and activate them with Enter or Space,
**So that** I can control which panel is active without a mouse.

### US1.AC1

Given the page has loaded with a session selected,
When the user presses Tab to cycle through interactive elements,
Then each panel (Terminal, Editor, Playbook, Chat, Assistant) receives focus in order,
And each panel is reachable via keyboard Tab navigation.

### US1.AC2

Given a panel has keyboard focus,
When the user presses Enter or Space,
Then `aria-pressed` on that panel changes to `true`,
And the panel is visually activated.

### US1.AC3

Given a panel is active (`aria-pressed="true"`),
When the user Tab-focuses the same panel and checks the DOM,
Then `aria-pressed` is `"true"` on the active panel,
And `aria-pressed` is `"false"` on all other panels.

---

## User Story 2 — Session buttons have distinct focus vs selection styles

**As a** keyboard-only user,
**I want** a visible focus ring on session buttons that is distinct from the active-selection highlight,
**So that** I can tell which item has keyboard focus versus which session is currently active.

### US2.AC1

Given a session list with at least one session,
When a session button receives keyboard focus (Tab),
Then a white focus ring (`focus-visible:ring-2 focus-visible:ring-white`) is visible around the button,
And this ring is distinct from the neon-cyan border that marks the active (selected) session.

### US2.AC2

Given the active session button also has keyboard focus,
When inspecting the button,
Then both the selection highlight (neon-cyan border) and the focus ring (white ring) are present simultaneously.

---

## User Story 3 — New Session button has a visible focus ring

**As a** keyboard-only user,
**I want** the "New Session" button to show a clear focus ring when focused,
**So that** I know the button is focused and can activate it with Enter or Space.

### US3.AC1

Given the sidebar is visible,
When the user Tabs to the "New Session" button,
Then the button displays a `focus-visible:ring-2 focus-visible:ring-white` focus ring,
And the ring is visible against the sidebar background.

---

## User Story 4 — Sidebar landmark and skip link

**As a** screen-reader or keyboard-only user,
**I want** the sidebar to be a `<nav>` landmark with a skip link,
**So that** I can navigate to the main content without tabbing through the entire session list.

### US4.AC1

Given the page is loaded,
When inspecting the DOM,
Then the sidebar root element is a `<nav>` with `aria-label="Sessions"`,
And this provides a landmark that assistive technology can jump to directly.

### US4.AC2

Given the sidebar is visible,
When the user presses Tab as the very first action on the page,
Then the skip link ("Skip to main content") becomes visible,
And activating it (Enter) moves focus to `#main-content`.
