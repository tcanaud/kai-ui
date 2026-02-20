---
title: "QA Finding: #main-content missing tabindex=-1 for skip link focus transfer"
category: "optimization"
source: "qa-system"
created: "2026-02-20T00:00:00Z"
linked_to:
  features: ["007-fix-keyboard-accessibility-panels-aria-roles-focus-states-and-skip-navigation"]
  feedbacks: []
  backlog: []
---

**Test Script**: `.qa/007-fix-keyboard-accessibility-panels-aria-roles-focus-states-and-skip-navigation/scripts/test-skip-link-visible-on-focus.mjs`
**Criterion**: US4.AC2 — "Skip to main content link becomes visible on focus and navigates to #main-content"
**Observation**: The `#main-content` element is a `<main>` tag but does not have `tabindex="-1"`. After activating the skip link, the browser scrolls to the anchor but focus falls back to `<body>` instead of landing on `#main-content`. Screen reader users would not hear the main content region announced after activating the skip link.
**Severity**: non-blocking
**Suggestion**: Add `tabindex="-1"` to the `<main id="main-content">` element so that skip link activation programmatically moves focus into the main content area, improving the screen reader experience.
