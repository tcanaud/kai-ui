---
title: "QA Finding: CDP-based test scripts require Chrome with --remote-debugging-port=9222"
category: "optimization"
source: "qa-system"
created: "2026-02-20T00:00:00Z"
linked_to:
  features: ["002-fix-terminal-websocket-initial-connection-failure"]
  feedbacks: []
  backlog: []
---

**Test Script**: `.qa/002-fix-terminal-websocket-initial-connection-failure/scripts/test-shell-prompt-within-3s.mjs` (and 5 other CDP-based scripts)
**Criterion**: US1.AC1, US1.AC2, US1.AC3, US2.AC1, US2.AC2, US3.AC1, US3.AC3
**Observation**: The 7 acceptance test scripts all require Chrome running with `--remote-debugging-port=9222` and the `ws` npm package. Two scripts (US2.AC1, US2.AC2) additionally require interactive stdin input to stop/restart the sidecar. These prerequisites make CI execution difficult without additional infrastructure (e.g., Playwright or Puppeteer).
**Severity**: non-blocking
**Suggestion**: Consider migrating CDP-based tests to use the MCP Chrome DevTools integration or Playwright for headless execution. For sidecar stop/restart tests, automate the sidecar lifecycle within the test script itself (e.g., spawn/kill child process).
