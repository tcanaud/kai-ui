---
title: "QA Finding: DialogContent and SheetContent missing aria-describedby / Description"
category: "bug"
source: "qa-system"
created: "2026-02-20T03:50:00Z"
linked_to:
  features: ["001-terminal-panel-xterm-js-tmux-integration"]
  feedbacks: []
  backlog: []
---

**Test Script**: Manual exploratory QA via MCP Chrome DevTools
**Criterion**: Accessibility -- Radix Dialog requires Description or aria-describedby
**Observation**: Console shows repeated warnings: `Warning: Missing 'Description' or 'aria-describedby={undefined}' for {DialogContent}`. This affects both the "Create Session" dialog (`new-session-dialog.tsx`) and the mobile Sheet (`mobile-nav.tsx`, which uses Radix Dialog under the hood). Each open/close cycle produces a new warning.
**Severity**: non-blocking
**Suggestion**: Add `DialogDescription` (with `sr-only` class if not visually needed) to `new-session-dialog.tsx`. For the Sheet in `mobile-nav.tsx`, add a visually hidden `SheetDescription`. Alternatively, pass `aria-describedby={undefined}` explicitly to suppress if description is intentionally omitted.
