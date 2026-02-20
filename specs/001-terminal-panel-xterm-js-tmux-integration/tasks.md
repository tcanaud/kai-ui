# Tasks: Terminal Panel — xterm.js + tmux Integration

**Input**: Design documents from `/specs/001-terminal-panel-xterm-js-tmux-integration/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/websocket-api.md, quickstart.md

**Tests**: Not requested in feature specification. No test tasks generated.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Install dependencies, create project scaffolding, and configure dev scripts

- [x] T001 Install frontend dependencies: `@xterm/xterm`, `@xterm/addon-fit`, `@xterm/addon-web-links` via npm
- [x] T002 Install backend dependencies: `ws`, `node-pty`, `@types/ws` (dev) via npm
- [x] T003 Add `dev:terminal` and `dev:all` scripts to `package.json` (use `concurrently` to run Next.js + sidecar together)
- [x] T004 Create directory structure: `src/terminal-server/` for the sidecar server

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Backend sidecar server and PTY manager that ALL user stories depend on

**WARNING**: No user story work can begin until this phase is complete

- [x] T005 Implement PTY session manager in `src/terminal-server/pty-manager.ts` — PtySession class with create (spawn `tmux new-session -A -s kai-{sessionId} -c {worktreePath}`), attach (add WebSocket client), resize (pty.resize), detach (remove client), and cleanup logic. Use `node-pty` for PTY allocation. Handle tmux-not-found and invalid-path errors.
- [x] T006 Implement sidecar WebSocket server in `src/terminal-server/index.ts` — HTTP server on port 3001 with `ws` library, route `ws://localhost:3001/terminal/:sessionId`, parse `worktreePath` query param, wire WebSocket messages to PtyManager (raw text frames for I/O, JSON `{"type":"resize"}` for resize), send `{"type":"error"}` and `{"type":"exit"}` control messages, implement message discrimination (check if frame starts with `{`), add HTTP GET `/health` endpoint, handle WebSocket close codes (4001, 4002, 4003).
- [x] T007 Create terminal theme configuration in `src/app/lib/terminal-theme.ts` — export `ITheme` object with cyberpunk palette: background `#0a0a0f`, foreground `#e0e0e8`, cursor `#00f0ff`, cursorAccent `#0a0a0f`, selectionBackground `#00f0ff33`, selectionForeground `#e0e0e8`, and all 16 ANSI colors mapped per data-model.md TerminalTheme entity.

**Checkpoint**: Sidecar server runs, accepts WebSocket connections, spawns/attaches tmux sessions, and streams PTY I/O. Theme config is ready for consumption.

---

## Phase 3: User Story 1 — Interactive Terminal in Panel (Priority: P1) MVP

**Goal**: Replace the terminal placeholder with a live xterm.js terminal that renders a shell prompt and accepts commands.

**Independent Test**: Open a session, verify the terminal panel renders a shell prompt, type `echo hello`, confirm output appears. Run an interactive TUI (e.g., `top`) and confirm it renders correctly.

### Implementation for User Story 1

- [x] T008 [US1] Create the `useTerminal` React hook in `src/app/lib/use-terminal.ts` — manage xterm.js Terminal instance lifecycle (create on mount, dispose on unmount), establish WebSocket connection to `ws://localhost:3001/terminal/{sessionId}?worktreePath={path}`, pipe WebSocket `onmessage` data to `terminal.write()`, pipe `terminal.onData` to WebSocket `send()`, apply terminal theme from `terminal-theme.ts`, configure options: `scrollback: 10000`, `cursorBlink: true`, `fontFamily: 'monospace'`, `fontSize: 14`. Accept `containerRef`, `sessionId`, and `worktreePath` as parameters. Return `{ connectionState }`.
- [x] T009 [US1] Create the `TerminalPanel` component in `src/app/components/panels/terminal-panel.tsx` — React component that renders a full-bleed `<div ref={terminalRef}>` container, uses `useTerminal` hook, loads xterm.js via `next/dynamic` with `ssr: false` to avoid SSR crashes. Display loading state while connecting. Accept `sessionId` and `worktreePath` props.
- [x] T010 [US1] Modify `src/app/components/panels/panel-layout.tsx` — replace `TerminalPlaceholder` import/usage with `TerminalPanel`, pass `sessionId` and `worktreePath` props.
- [x] T011 [US1] Modify `src/app/components/panels/panel-slot.tsx` — remove padding/margins from the terminal panel slot so xterm.js renders full-bleed without gaps.

**Checkpoint**: Terminal panel shows a live shell prompt. User can type commands and see output. Interactive TUI programs render correctly.

---

## Phase 4: User Story 2 — Persistent Terminal via tmux Session (Priority: P1)

**Goal**: Terminal connects to a persistent tmux session so state survives page reloads and reconnections.

**Independent Test**: Run `sleep 300` in the terminal, refresh the page, verify the command is still running and visible upon reconnection.

### Implementation for User Story 2

- [x] T012 [US2] Add connection state machine to `src/app/lib/use-terminal.ts` — implement states: `idle -> connecting -> connected -> disconnected -> reconnecting -> connected | error`. On WebSocket close/error, attempt reconnection with exponential backoff (1s, 2s, 4s, max 30s). After 5 failures, transition to `error` state. Reset `reconnectAttempts` on successful connection.
- [x] T013 [US2] Add error and reconnecting UI states to `src/app/components/panels/terminal-panel.tsx` — display connection status overlay: "Connecting..." during `connecting`/`reconnecting`, "Connection lost. Retrying..." during `reconnecting`, error message with "Retry" button during `error` state. Style overlays with cyberpunk palette.
- [x] T014 [US2] Ensure `src/terminal-server/pty-manager.ts` handles re-attachment correctly — when a new WebSocket connects to an existing PtySession, add it to the clients set and stream current PTY output. When all clients disconnect, keep the tmux session alive (do not kill it). On reconnect, `tmux new-session -A` re-attaches to existing session.

**Checkpoint**: Terminal state persists across page refreshes. Auto-reconnection works on connection drops. Error state displays with retry button after max retries.

---

## Phase 5: User Story 3 — Copy, Paste, and Scrollback (Priority: P2)

**Goal**: Users can copy text from terminal output, paste text into the terminal, and scroll through previous output.

**Independent Test**: Run a command with long output, scroll up to review it, select text and copy, paste external text into the terminal.

### Implementation for User Story 3

- [x] T015 [P] [US3] Enable scrollback and selection in `src/app/lib/use-terminal.ts` — ensure xterm.js options include `scrollback: 10000` (already set in T008, verify). No additional work needed if T008 configured correctly.
- [x] T016 [US3] Implement clipboard integration in `src/app/lib/use-terminal.ts` — handle paste events: listen for browser `paste` event on the terminal container, write clipboard content to terminal wrapped in bracketed paste mode (`\x1b[200~...\x1b[201~`). Copy is handled natively by xterm.js selection + browser Clipboard API.

**Checkpoint**: Scrollback works with mouse wheel and keyboard. Copy/paste works with system clipboard. Bracketed paste mode prevents line-by-line execution of multi-line pastes.

---

## Phase 6: User Story 4 — Cyberpunk-Themed Terminal (Priority: P2)

**Goal**: Terminal visuals match the kai cyberpunk design system (neon cyan, violet, dark backgrounds).

**Independent Test**: Visually inspect terminal colors against surrounding UI. Run `ls --color` and `git diff` to verify ANSI color mapping.

### Implementation for User Story 4

- [x] T017 [US4] Verify and refine theme application in `src/app/components/panels/terminal-panel.tsx` — ensure the terminal container has matching background color so there is no flash of wrong color before xterm initializes. Add CSS to match panel header bar borders and surrounding UI elements. Ensure the xterm.js canvas blends seamlessly with panel chrome.
- [x] T018 [US4] Add `@xterm/addon-web-links` integration in `src/app/lib/use-terminal.ts` — load and activate the web-links addon so URLs in terminal output are clickable and styled with the cyberpunk link color.

**Checkpoint**: Terminal visually integrates with the kai UI. ANSI colors map to cyberpunk palette. Clickable URLs work.

---

## Phase 7: User Story 5 — Terminal Resizes with Panel (Priority: P2)

**Goal**: Terminal dynamically resizes when panel dimensions change, and TUI programs render correctly at new dimensions.

**Independent Test**: Resize the browser window, verify terminal reflows. Run `htop`, resize, confirm correct rendering at new dimensions.

### Implementation for User Story 5

- [x] T019 [US5] Implement resize handling in `src/app/lib/use-terminal.ts` — load `@xterm/addon-fit`, attach `ResizeObserver` to the terminal container div, debounce at 100ms, call `fitAddon.fit()` on container resize, send `{"type":"resize","cols":N,"rows":N}` JSON message over WebSocket after each fit. Clean up observer on unmount.
- [x] T020 [US5] Ensure `src/terminal-server/pty-manager.ts` processes resize messages — on receiving `{"type":"resize"}`, call `pty.resize(cols, rows)` with validation (cols 1-500, rows 1-200).

**Checkpoint**: Terminal fills panel on every resize. TUI programs re-render correctly. Resize is debounced at 100ms.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Edge cases, error handling improvements, and cleanup

- [x] T021 [P] Handle tmux-not-installed edge case in `src/terminal-server/pty-manager.ts` — check for `tmux` on PATH at server startup, return WebSocket close code 4003 with clear message if missing
- [x] T022 [P] Handle missing worktree directory in `src/terminal-server/pty-manager.ts` — if `worktreePath` does not exist, fall back to `$HOME` and log a warning
- [x] T023 [P] Handle large paste gracefully in `src/app/lib/use-terminal.ts` — ensure bracketed paste mode is always used for pastes, add a reasonable size limit warning for extremely large pastes (10,000+ characters)
- [x] T024 Add `next.config.ts` WebSocket proxy rewrite for production deployments (optional, per quickstart.md)
- [x] T025 Run quickstart.md verification steps end-to-end and validate all acceptance scenarios

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Phase 2 — delivers MVP
- **User Story 2 (Phase 4)**: Depends on Phase 3 (needs working terminal to add persistence UI)
- **User Story 3 (Phase 5)**: Depends on Phase 3 (needs working terminal for clipboard/scrollback)
- **User Story 4 (Phase 6)**: Depends on Phase 2 (theme already created in T007; refinement only)
- **User Story 5 (Phase 7)**: Depends on Phase 3 (needs working terminal + hook for resize)
- **Polish (Phase 8)**: Depends on all user stories being complete

### User Story Dependencies

- **US1 (P1)**: Depends on Foundational only — delivers core terminal
- **US2 (P1)**: Depends on US1 — adds reconnection/persistence UI on top of working terminal
- **US3 (P2)**: Depends on US1 — adds clipboard/scrollback to working terminal
- **US4 (P2)**: Depends on Foundational only — theme refinement is independent
- **US5 (P2)**: Depends on US1 — adds resize handling to working terminal

### Parallel Opportunities

After Phase 2 completes:
- US4 (theme refinement) can start immediately in parallel with US1
- After US1 completes: US2, US3, and US5 can all run in parallel

---

## Parallel Example: After Phase 2

```text
# These can run in parallel after Foundational:
Developer A: US1 (T008, T009, T010, T011) — core terminal
Developer B: US4 (T017, T018) — theme polish

# After US1 completes, these can run in parallel:
Developer A: US2 (T012, T013, T014) — persistence
Developer B: US3 (T015, T016) — clipboard
Developer C: US5 (T019, T020) — resize
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T004)
2. Complete Phase 2: Foundational (T005-T007)
3. Complete Phase 3: User Story 1 (T008-T011)
4. **STOP and VALIDATE**: Open session, verify shell prompt, type commands, see output
5. Deploy/demo — terminal replaces placeholder with live shell

### Incremental Delivery

1. Setup + Foundational -> Sidecar server running
2. Add US1 -> Working terminal in panel (MVP!)
3. Add US2 -> Persistence across reloads + auto-reconnect
4. Add US3 -> Copy/paste/scrollback
5. Add US4 -> Cyberpunk theme polish
6. Add US5 -> Dynamic resize
7. Polish -> Edge cases and production readiness

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- The sidecar server (Phase 2) is the critical path — it unblocks everything
