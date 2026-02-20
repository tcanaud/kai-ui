---
title: "QA Finding: test-modified-tab-stays-in-terminal.mjs has a syntax error preventing execution"
category: "bug"
source: "qa-system"
created: "2026-02-20T00:00:00Z"
linked_to:
  features: ["005-fix-terminal-tab-key-focus-trap-wcag-2-1-2-keyboard-escape"]
  feedbacks: []
  backlog: []
---

**Test Script**: `.qa/005-fix-terminal-tab-key-focus-trap-wcag-2-1-2-keyboard-escape/scripts/test-modified-tab-stays-in-terminal.mjs`
**Criterion**: US1.AC3 — "Given the terminal is focused, When the user presses Tab with Alt, Ctrl, or Meta held down, Then xterm processes the key as terminal input and browser focus does NOT move away from the terminal."
**Observation**: Line 140 contains `const { default: WebSocket: WS2 } = await import("ws");` which is invalid JavaScript destructuring syntax. The identifier `WebSocket` was already declared on line 43. The script fails to parse before any test logic executes.
**Severity**: non-blocking
**Suggestion**: Fix the syntax error on line 140. The line and the code after it (lines 138-141) appear to be dead code that was left behind after the main loop already completes verification. Remove lines 138-141 entirely — the script already prints PASS and exits before reaching them, but the syntax error prevents the module from loading at all.
