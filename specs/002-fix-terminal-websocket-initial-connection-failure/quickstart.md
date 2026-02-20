# Quickstart: Fix Terminal WebSocket Initial Connection Failure

**Feature**: `002-fix-terminal-websocket-initial-connection-failure`
**Date**: 2026-02-20

## What Is Being Fixed

The terminal panel shows "Disconnected. Reconnecting..." on initial page load even when the sidecar WebSocket server is healthy. Two bugs in `use-terminal.ts` combine to produce this:

1. `ws.onclose` sets state to `"disconnected"` (shown as "Disconnected. Reconnecting...") before the retry logic transitions to `"reconnecting"`.
2. The second (and any subsequent) connection attempt before any success is labeled `"reconnecting"` instead of `"connecting"`.

## Files to Change

| File | Change |
|------|--------|
| `src/app/lib/use-terminal.ts` | Add `hasEverConnectedRef`; fix state labels in `connect()` and `ws.onclose` |
| `src/app/components/panels/terminal-panel.tsx` | Fix `"disconnected"` overlay message |

## Change 1: `src/app/lib/use-terminal.ts`

Add `hasEverConnectedRef` after the existing refs:

```ts
const hasEverConnectedRef = useRef(false);
```

Update `connect()`:

```ts
const connect = useCallback(
  (term: Terminal) => {
    // Always "connecting" until hasEverConnected; "reconnecting" only after prior success
    const state = hasEverConnectedRef.current && reconnectAttemptsRef.current > 0
      ? "reconnecting"
      : "connecting";
    setConnectionState(state);

    const wsUrl = `ws://localhost:3001/terminal/${sessionId}?worktreePath=${encodeURIComponent(worktreePath)}`;
    const ws = new WebSocket(wsUrl);
    wsRef.current = ws;

    ws.onopen = () => {
      hasEverConnectedRef.current = true;
      setConnectionState("connected");
      reconnectAttemptsRef.current = 0;
      // ... rest unchanged
    };

    ws.onclose = () => {
      if (hasEverConnectedRef.current) {
        // Post-success drop: show "disconnected" briefly before reconnect
        setConnectionState("disconnected");
      }
      // If never connected: skip "disconnected" state, go straight to retry
      attemptReconnect(term);
    };

    // ws.onerror unchanged
  },
  [sessionId, worktreePath]
);
```

Update `retry()` to reset `hasEverConnectedRef`:

```ts
const retry = useCallback(() => {
  if (terminalRef.current) {
    reconnectAttemptsRef.current = 0;
    hasEverConnectedRef.current = false;  // ← reset so retry shows "Connecting..."
    connect(terminalRef.current);
  }
}, [connect]);
```

## Change 2: `src/app/components/panels/terminal-panel.tsx`

Fix the `"disconnected"` case in `ConnectionOverlay`:

```ts
case "disconnected":
  message = "Connection lost. Retrying...";  // was: "Disconnected. Reconnecting..."
  break;
```

## How to Verify

1. Start the sidecar: `cd packages/kai-ui && node src/terminal-server/index.ts` (or however it is started).
2. Open `http://localhost:3000`.
3. Confirm: terminal shows "Connecting..." briefly, then a live shell prompt. "Disconnected. Reconnecting..." is never shown.
4. Restart the sidecar mid-session.
5. Confirm: terminal shows "Connection lost. Retrying..." then reconnects to a live prompt.
6. Stop the sidecar before opening the app.
7. Confirm: terminal shows "Connecting..." then eventually "Connection failed." with a Retry button.

## No New Dependencies

This fix adds zero new npm packages.
