---
title: "QA Finding: Sheet X close button touch target is too small on mobile"
category: "optimization"
source: "qa-system"
created: "2026-02-20T00:00:00Z"
linked_to:
  features: ["003-fix-mobile-responsive-layout-sheet-close-failure-and-tablet-breakpoint"]
  feedbacks: []
  backlog: []
---

**Test Script**: `.qa/003-fix-mobile-responsive-layout-sheet-close-failure-and-tablet-breakpoint/scripts/test-sheet-close-x-button.sh`
**Criterion**: US1.AC1 — "Given the mobile nav sheet is open, When the user clicks the X close button inside the sheet, Then the sheet closes and only the hamburger button is visible."
**Observation**: The X close button icon is `size-4` (16px) with no minimum touch target padding. During MCP Chrome DevTools touch-emulated testing at 375px mobile viewport, the button was difficult to activate via touch clicks (though it works via programmatic `.click()` and via Escape key). The WCAG minimum touch target recommendation is 44x44px.
**Severity**: non-blocking
**Suggestion**: Add `min-h-11 min-w-11` (44px) or equivalent padding to the `SheetPrimitive.Close` button in `src/components/ui/sheet.tsx` to improve mobile touch accessibility.
