---
title: "QA Finding: Mobile sidebar does not auto-close after session selection"
category: "bug"
source: "qa-system"
created: "2026-02-20T03:50:00Z"
linked_to:
  features: ["001-terminal-panel-xterm-js-tmux-integration"]
  feedbacks: []
  backlog: []
---

**Test Script**: Manual exploratory QA via MCP Chrome DevTools
**Criterion**: Mobile sidebar UX -- navigation drawer should close after item selection
**Observation**: When the mobile sidebar (Sheet) is open at 375x812 viewport and a user taps a session item, the session is selected (highlighted) but the Sheet remains open. The user must manually close the sidebar (via X button, Escape, or overlay tap) to see the main content. This is contrary to standard mobile navigation drawer behavior.
**Severity**: non-blocking
**Suggestion**: In `MobileNav`, convert `Sheet` to a controlled component and close it programmatically when `onSessionSelect` fires. Wrap the callback:
```tsx
const handleSelect = (id: string) => {
  onSessionSelect(id);
  setOpen(false);
};
```
