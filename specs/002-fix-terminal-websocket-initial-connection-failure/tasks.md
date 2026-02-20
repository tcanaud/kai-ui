# Tasks: Fix Terminal WebSocket Initial Connection Failure

**Feature**: `002-fix-terminal-websocket-initial-connection-failure`
**Input**: Design documents from `/specs/002-fix-terminal-websocket-initial-connection-failure/`
**Plan**: [plan.md](./plan.md) | **Spec**: [spec.md](./spec.md)
**Tests**: Not requested — no test tasks included.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: No new project structure needed — this is a targeted bug fix in two existing files. Setup phase confirms working directory and verifies the two target files exist.

- [ ] T001 Verify target files exist: `src/app/lib/use-terminal.ts` and `src/app/components/panels/terminal-panel.tsx`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Read and understand the current implementation in both target files before making any changes. This phase is required before any user story work.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [ ] T002 Read current implementation of `src/app/lib/use-terminal.ts` — locate `connect()` callback, `ws.onclose` handler, `attemptReconnect()` call, and `retry()` callback; note the `reconnectAttemptsRef` logic
- [ ] T003 [P] Read current implementation of `src/app/components/panels/terminal-panel.tsx` — locate `ConnectionOverlay` component and the `"disconnected"` case in its message switch/map

**Checkpoint**: Both files fully understood — implementation can now begin.

---

## Phase 3: User Story 1 — First-Time Terminal Load (Priority: P1) 🎯 MVP

**Goal**: Fix the two bugs in `use-terminal.ts` so the terminal never shows "Disconnected. Reconnecting..." on initial page load when the sidecar is healthy. A `hasEverConnected` ref is introduced to correctly separate the initial-connection path from the post-success reconnection path.

**Independent Test**: Open `http://localhost:3000` with the sidecar running. The terminal must show "Connecting..." briefly and then a live shell prompt. The "Disconnected. Reconnecting..." overlay must never appear during this flow.

### Implementation for User Story 1

- [ ] T004 [US1] Add `hasEverConnectedRef` declaration in `src/app/lib/use-terminal.ts` — insert `const hasEverConnectedRef = useRef(false);` after the existing refs block
- [ ] T005 [US1] Fix state label in `connect()` in `src/app/lib/use-terminal.ts` — replace `const state = reconnectAttemptsRef.current > 0 ? "reconnecting" : "connecting"` with `const state = hasEverConnectedRef.current && reconnectAttemptsRef.current > 0 ? "reconnecting" : "connecting"`
- [ ] T006 [US1] Set `hasEverConnectedRef.current = true` inside `ws.onopen` in `src/app/lib/use-terminal.ts` — add the assignment immediately before or after `setConnectionState("connected")`
- [ ] T007 [US1] Fix `ws.onclose` handler in `src/app/lib/use-terminal.ts` — wrap `setConnectionState("disconnected")` in an `if (hasEverConnectedRef.current)` guard so the "disconnected" state is only set after a prior successful connection; ensure `attemptReconnect(term)` is always called regardless
- [ ] T008 [US1] Fix `retry()` callback in `src/app/lib/use-terminal.ts` — add `hasEverConnectedRef.current = false;` before the `connect()` call so user-initiated retry after error restarts from "Connecting..." not "Reconnecting..."

**Checkpoint**: User Story 1 fully implemented. Verify with quickstart scenario 1, 2, and 3 from `quickstart.md`.

---

## Phase 4: User Story 2 — Stable Connection After Sidecar Restart (Priority: P2)

**Goal**: Confirm the reconnection path correctly shows "Connection lost. Retrying..." (not "Disconnected. Reconnecting...") after a sidecar restart. This is validated by the overlay message fix in `terminal-panel.tsx` combined with the state machine fix from Phase 3.

**Independent Test**: With the terminal connected, restart the sidecar. The terminal must show "Connection lost. Retrying..." then recover to a live shell prompt without a page reload.

**Note**: This story depends on Phase 3 (US1) being complete, since the `hasEverConnectedRef` guard introduced in T007 is what causes `ws.onclose` to set `"disconnected"` only on post-success drops — which is exactly the path that US2 exercises.

### Implementation for User Story 2

- [ ] T009 [US2] Fix `"disconnected"` overlay message in `src/app/components/panels/terminal-panel.tsx` — in `ConnectionOverlay`, change the `"disconnected"` case message from `"Disconnected. Reconnecting..."` to `"Connection lost. Retrying..."`

**Checkpoint**: User Stories 1 and 2 both functional. Verify with quickstart scenarios 4 and 5 from `quickstart.md`.

---

## Phase 5: User Story 3 — Accurate Connection Status Messages (Priority: P3)

**Goal**: Ensure all three overlay messages are semantically correct across the full connection lifecycle: initial load → "Connecting...", post-success drop → "Connection lost. Retrying...", max retries exhausted → "Connection failed." with Retry button.

**Independent Test**: Observe the overlay across all three scenarios (initial load, sidecar restart, sidecar unavailable) and confirm the correct message appears in each.

**Note**: US3 is fully satisfied by the work in Phase 3 (T004–T008) and Phase 4 (T009). This phase is a verification and documentation checkpoint — no additional code changes are needed unless a gap is found during review.

### Implementation for User Story 3

- [ ] T010 [US3] Review overlay message mapping in `src/app/components/panels/terminal-panel.tsx` — confirm all six `ConnectionState` values (`idle`, `connecting`, `connected`, `disconnected`, `reconnecting`, `error`) map to the correct overlay messages as specified in `specs/002-fix-terminal-websocket-initial-connection-failure/data-model.md` Overlay Message Mapping table
- [ ] T011 [US3] Verify `"idle"` state maps to `"Connecting..."` in `ConnectionOverlay` in `src/app/components/panels/terminal-panel.tsx` — update if currently missing or incorrect

**Checkpoint**: All three user stories complete and all connection states show correct messages.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and cleanup.

- [ ] T012 Run `npm test && npm run lint` from `packages/kai-ui` root and confirm no regressions
- [ ] T013 [P] Execute quickstart.md manual verification steps 1–7 against a running sidecar to confirm all three acceptance scenarios pass end-to-end
- [ ] T014 [P] Review the contract in `specs/002-fix-terminal-websocket-initial-connection-failure/contracts/use-terminal-contract.ts` and confirm the implemented state machine matches all documented invariants

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **US1 (Phase 3)**: Depends on Phase 2 — the core state machine fix
- **US2 (Phase 4)**: Depends on Phase 3 (T007 must be complete before T009 is meaningful)
- **US3 (Phase 5)**: Depends on Phase 3 and Phase 4 being complete
- **Polish (Phase 6)**: Depends on all story phases complete

### User Story Dependencies

- **User Story 1 (P1)**: Foundational phase complete → can start. No dependency on US2 or US3.
- **User Story 2 (P2)**: Depends on US1 (specifically T007) — the `hasEverConnectedRef` guard is required for the reconnect overlay path to be correct.
- **User Story 3 (P3)**: Depends on US1 and US2 — all messages only verifiable after both fixes are applied.

### Within Each User Story

- T004 → T005, T006, T007, T008 can all be done in sequence (same file, single callback region)
- T009 is independent from T004–T008 (different file) — can be done in parallel with Phase 3 if desired

### Parallel Opportunities

- T002 and T003 (Foundational reads) can run in parallel — different files
- T009 (US2 overlay fix) can be done in parallel with T004–T008 (US1 state machine fix) since they are in different files and have no shared state
- T012, T013, T014 (Polish) can all run in parallel

---

## Parallel Example: US1 + US2 in parallel

```
# These can be done simultaneously (different files):
Developer A: T004 → T005 → T006 → T007 → T008  (use-terminal.ts)
Developer B: T009                                (terminal-panel.tsx)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: Foundational (T002, T003)
3. Complete Phase 3: User Story 1 (T004–T008)
4. **STOP and VALIDATE**: Open app with running sidecar — confirm terminal connects without error state
5. Proceed to US2 and US3 only after US1 is validated

### Incremental Delivery

1. Phase 1 + Phase 2 → files read and understood
2. Phase 3 (US1) → core bug fixed, primary symptom resolved (**MVP**)
3. Phase 4 (US2) → overlay message corrected for reconnection path
4. Phase 5 (US3) → all messages verified accurate across all states
5. Phase 6 → full validation and lint pass

---

## Notes

- Total tasks: 14
- Tasks per user story: US1 = 5, US2 = 1, US3 = 2
- Setup/Foundational/Polish: 6
- Parallel opportunities: T002+T003 (Phase 2), T004–T008 parallel with T009 (Phase 3+4), T012+T013+T014 (Phase 6)
- Suggested MVP scope: Phase 1 + Phase 2 + Phase 3 (User Story 1) — 8 tasks total
- Independent test criteria per story:
  - **US1**: Browser opens to app URL with running sidecar → shell prompt appears, no "Disconnected. Reconnecting..." shown
  - **US2**: Sidecar restarted mid-session → terminal shows "Connection lost. Retrying..." and recovers without page reload
  - **US3**: All three scenarios (initial load, restart, unavailable) → correct overlay message shown in each case
- No new files needed — only two existing source files are modified
- No new npm dependencies
