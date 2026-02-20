---
title: "QA Finding: Sidecar runtime tests skipped — static verification only"
category: "optimization"
source: "qa-system"
created: "2026-02-20T00:00:00Z"
linked_to:
  features: ["001-terminal-panel-xterm-js-tmux-integration"]
  feedbacks: []
  backlog: []
---

**Test Script**: `.qa/001-terminal-panel-xterm-js-tmux-integration/scripts/test-terminal-renders-shell-prompt.sh` and `test-if3-health-endpoint.sh`
**Criterion**: US1.AC1, IF3
**Observation**: Both scripts detected that the sidecar server was not running at localhost:3001 and skipped runtime verification, falling back to static/source-code checks only. All 19 tests passed via static analysis but 2 criteria lack runtime confirmation.
**Severity**: non-blocking
**Suggestion**: Consider adding a QA mode that starts the sidecar before running tests, or document that runtime tests require the sidecar to be running. A future `/qa.run` enhancement could auto-start prerequisites.
