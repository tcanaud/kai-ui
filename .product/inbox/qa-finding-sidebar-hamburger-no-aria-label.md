---
title: "QA Finding: Hamburger menu button has no accessible label"
category: "bug"
source: "qa-system"
created: "2026-02-20T03:50:00Z"
linked_to:
  features: ["001-terminal-panel-xterm-js-tmux-integration"]
  feedbacks: []
  backlog: []
---

**Test Script**: Manual exploratory QA via MCP Chrome DevTools
**Criterion**: Accessibility -- all interactive elements should have accessible names
**Observation**: The hamburger menu button in `MobileNav` (visible at <1024px viewport) renders as a `Button` with only an SVG icon (`Menu` from lucide-react) and no `aria-label`, `title`, or visible text. The a11y tree shows it as just "button" with `haspopup="dialog"` but no accessible name. Screen readers cannot announce what this button does.
**Severity**: non-blocking
**Suggestion**: Add `aria-label="Open navigation"` or a `<span className="sr-only">` to the hamburger Button in `/src/app/components/layout/mobile-nav.tsx`.
