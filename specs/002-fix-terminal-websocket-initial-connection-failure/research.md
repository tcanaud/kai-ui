# Research: Fix Terminal WebSocket Initial Connection Failure

**Feature**: `002-fix-terminal-websocket-initial-connection-failure`
**Date**: 2026-02-20

## Summary

All unknowns resolved through direct codebase analysis. No external dependencies or new technologies are introduced by this fix.

---

## Finding 1: Root Cause — Dual Bug in `use-terminal.ts`

**Decision**: Two distinct bugs combine to produce the observed symptom.

### Bug A: Transient `"disconnected"` state on first connection failure

In the current `connect()` callback:
```ts
ws.onclose = () => {
  setConnectionState("disconnected");  // ← immediately shown as "Disconnected. Reconnecting..."
  attemptReconnect(term);
};
```

When the first WebSocket connection attempt fails (e.g. sidecar not yet ready, race condition), `onclose` fires and sets state to `"disconnected"`. The `ConnectionOverlay` renders this as **"Disconnected. Reconnecting..."** — the message reserved for post-success drops. React batches state updates, but `setConnectionState("disconnected")` and the subsequent `setConnectionState("reconnecting")` (set inside `connect()` on the next attempt) are in different event loops (separated by a `setTimeout`), so the user sees the wrong message.

### Bug B: `connect()` misclassifies retries as reconnects

```ts
const state = reconnectAttemptsRef.current > 0 ? "reconnecting" : "connecting";
```

After the first failed attempt, `reconnectAttemptsRef.current` is incremented to 1, so all subsequent attempts (even before any success) are labeled `"reconnecting"`. This is semantically wrong — `"reconnecting"` should only apply after a previously successful connection.

**Rationale**: Both bugs share the same root cause: the state machine has no memory of whether a connection has ever succeeded.

**Alternatives considered**:
- Delaying the initial connection until `onopen` has fired at least once: rejected, too complex and still doesn't fix message labeling.
- Suppressing `"disconnected"` in `ConnectionOverlay` component: rejected, treats the symptom not the cause.

---

## Finding 2: Fix Strategy — `hasEverConnected` Ref

**Decision**: Add a `hasEverConnected = useRef(false)` to `use-terminal.ts`. Set it to `true` on `ws.onopen`. Use it to branch all state-labeling decisions.

```
hasEverConnected === false  →  initial connection path
  connecting state    → "connecting"
  retry state         → "connecting" (still initial, not yet succeeded)
  onclose before open → do NOT set "disconnected"; directly call attemptReconnect

hasEverConnected === true   →  reconnection path
  retry state         → "reconnecting"
  onclose             → set "disconnected" briefly, then attemptReconnect
```

**Rationale**: A single boolean ref is the minimal change that correctly separates the two semantically distinct connection lifecycle phases without altering retry backoff, retry limits, or any other behavior.

**Alternatives considered**:
- Using a `connectionPhase: "initial" | "established"` state variable: rejected, would cause extra re-renders and complicate the logic.
- Tracking success via `reconnectAttemptsRef` being reset on `onopen`: already done but insufficient, because the ref is reset after connection — not queried to know if it ever happened.

---

## Finding 3: `ConnectionOverlay` — `"disconnected"` state message

**Decision**: Map `"disconnected"` to **"Connection lost. Retrying..."** in `ConnectionOverlay`, not "Disconnected. Reconnecting...".

Current:
```ts
case "disconnected":
  message = "Disconnected. Reconnecting...";
```

Proposed:
```ts
case "disconnected":
  message = "Connection lost. Retrying...";
```

This aligns with FR-005 and User Story 2 acceptance scenario 2: the "disconnected" transient state (which does appear briefly between a post-success `onclose` and the next `connect()` call) should show the same message as the full reconnect flow.

**Rationale**: The spec explicitly names "Connection lost. Retrying..." as the correct message for this path. The current "Disconnected. Reconnecting..." string has no matching requirement.

---

## Finding 4: Session ID Race Condition Assessment

**Decision**: The session-ID race condition is **already mitigated** by the current `page.tsx` rendering guard.

```tsx
// page.tsx
{activeSession ? (
  <PanelLayout sessionId={activeSession.id} worktreePath={activeSession.worktreePath} ... />
) : (
  <EmptyState />
)}
```

`TerminalPanel` (and `useTerminal`) only mounts after `activeSession` is defined, which only becomes truthy after `fetchSessions()` resolves and `setActiveSessionId` is called. There is no genuine race condition between session resolution and WebSocket connection — the terminal is never given an undefined or empty `sessionId`.

**Rationale**: FR-001 is already satisfied. No additional guard is needed inside `use-terminal.ts` for session ID readiness.

**Alternatives considered**:
- Adding a guard `if (!sessionId) return;` inside `useEffect`: would be a defensive no-op given the rendering guard, but harmless to add as belt-and-suspenders.

---

## Finding 5: No New Dependencies

**Decision**: This fix requires zero new npm packages. All changes are in existing TypeScript/React files.

---

## Resolved Unknowns

| Unknown | Resolution |
|---------|------------|
| Why does "Disconnected. Reconnecting..." appear on first load? | `ws.onclose` sets `"disconnected"` before any retry; combined with `reconnectAttemptsRef > 0` labeling retries as `"reconnecting"` |
| Is there a genuine session ID race condition? | No — `TerminalPanel` only mounts after `activeSession` is resolved |
| What is the minimal fix scope? | Two files: `use-terminal.ts` (state machine) and `terminal-panel.tsx` (overlay message string) |
| Are new dependencies needed? | No |
