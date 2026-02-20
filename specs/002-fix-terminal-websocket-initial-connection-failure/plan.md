# Implementation Plan: Fix Terminal WebSocket Initial Connection Failure

**Branch**: `001-fix-ws-initial-connect` | **Date**: 2026-02-20 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-fix-terminal-websocket-initial-connection-failure/spec.md`

## Summary

Fix the terminal panel displaying "Disconnected. Reconnecting..." on initial page load by correcting the WebSocket connection lifecycle state machine in `use-terminal.ts`. The root cause is a combination of: (1) the `"disconnected"` state being set in `ws.onclose` before `attemptReconnect` transitions to `"reconnecting"`, causing a brief but visible wrong-state flash, and (2) `connect()` labeling the second attempt as `"reconnecting"` even when no prior successful connection has ever been established. The fix introduces a `hasEverConnected` ref to distinguish initial-connection retries from post-success reconnects, and removes the transient `"disconnected"` state from the initial connection path.

## Technical Context

**Language/Version**: TypeScript 5.x, Node.js >= 18.0.0
**Primary Dependencies**: React 19, Next.js 16, `@xterm/xterm`, `@xterm/addon-fit`, `@xterm/addon-web-links`, `ws`, `node-pty`
**Storage**: N/A (stateless WebSocket; session metadata loaded from sidecar API)
**Testing**: Jest / React Testing Library (project-standard)
**Target Platform**: Browser (Next.js client component)
**Project Type**: Web application (Next.js)
**Performance Goals**: Terminal connects within 3 seconds of page becoming interactive
**Constraints**: Fix must not alter reconnection retry limits or retry delay backoff logic
**Scale/Scope**: Single terminal panel per active session

## Constitution Check

The constitution file is a placeholder template without concrete project-specific rules. No enforceable gates are defined. Proceeding without violations.

*Gate result: PASS (no active constitution rules to evaluate)*

## Project Structure

### Documentation (this feature)

```text
specs/002-fix-terminal-websocket-initial-connection-failure/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (affected files)

```text
src/app/lib/
└── use-terminal.ts      # Core fix: connection state machine

src/app/components/panels/
└── terminal-panel.tsx   # ConnectionOverlay: remove "disconnected" → "Disconnected. Reconnecting..." mapping
```

**Structure Decision**: Single web application. Only two files need to change. No new modules, no new files outside the spec docs.

## Complexity Tracking

No constitution violations detected. No complexity justification required.
