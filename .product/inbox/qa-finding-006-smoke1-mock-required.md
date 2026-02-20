---
title: "QA Finding: SMOKE1 happy path required fetch mock due to dirty working tree"
category: "optimization"
source: "qa-system"
created: "2026-02-20T00:00:00Z"
linked_to:
  features: ["006-fix-session-creation-dialog-ux-actionable-errors-form-reset-and-abort"]
  feedbacks: []
  backlog: []
---

**Test Script**: `.qa/006-fix-session-creation-dialog-ux-actionable-errors-form-reset-and-abort/scripts/test-smoke1-successful-session-creation.sh`
**Criterion**: SMOKE1 — "Given the New Session dialog is open and the API is healthy, When the user fills in a valid Playbook and Feature Name and submits, Then the session is created, the dialog closes, and the session list refreshes."
**Observation**: The real POST /api/sessions returned an error ("Working tree is dirty. Commit or stash changes first.") because the test environment had uncommitted changes. The test was completed using a mocked fetch response to verify the UI success path (dialog closes on 200). Session list refresh could not be verified end-to-end.
**Severity**: non-blocking
**Suggestion**: Consider adding a dedicated E2E test environment with a clean git working tree, or add a test-mode flag that bypasses git-clean checks in the sidecar API.
