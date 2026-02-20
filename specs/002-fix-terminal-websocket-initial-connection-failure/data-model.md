# Data Model: Fix Terminal WebSocket Initial Connection Failure

**Feature**: `002-fix-terminal-websocket-initial-connection-failure`
**Date**: 2026-02-20

## Entities

### ConnectionState (TypeScript Union Type)

Represents the current status of the WebSocket terminal connection.

```ts
export type ConnectionState =
  | "idle"          // Terminal not yet initialized (before useEffect runs)
  | "connecting"    // Initial connection in progress (no prior success)
  | "connected"     // WebSocket open and active
  | "disconnected"  // WebSocket closed after prior success; retry imminent
  | "reconnecting"  // Retry attempt in progress after prior success
  | "error";        // Max retries exhausted; awaiting user action
```

**No changes to the type definition itself.** The fix changes which values are assigned and when.

### Connection State Machine

```
                       ┌─────────────────────────────────────────┐
                       │                                         │
  mount ──► idle ──► connecting ──► connected ──► disconnected ──┤
                          ▲              │                       │
                          │         (onclose, hasEverConnected=true)
                          │              ▼
                          └────── reconnecting ◄────────────────┘
                                        │
                          (onclose, hasEverConnected=false)
                                        │ (stays "connecting" label)
                          max retries ──► error
```

**State Transition Rules** (corrected):

| From | Event | Condition | To | Message Shown |
|------|-------|-----------|-----|---------------|
| `idle` | `init()` runs | — | `connecting` | "Connecting..." |
| `connecting` | `ws.onopen` | — | `connected` | (hidden) |
| `connecting` | `ws.onclose` | `!hasEverConnected` | `connecting` (retry) | "Connecting..." |
| `connecting` | `ws.onclose` | `!hasEverConnected`, max retries | `error` | "Connection failed." |
| `connected` | `ws.onclose` | `hasEverConnected` | `disconnected` | "Connection lost. Retrying..." |
| `disconnected` | retry fires | `hasEverConnected` | `reconnecting` | "Connection lost. Retrying..." |
| `reconnecting` | `ws.onopen` | — | `connected` | (hidden) |
| `reconnecting` | `ws.onclose` | max retries | `error` | "Connection failed." |
| `error` | user clicks Retry | — | `connecting` | "Connecting..." |

### hasEverConnected (Internal Ref)

```ts
const hasEverConnectedRef = useRef<boolean>(false);
```

- Set to `true` on `ws.onopen`.
- Reset to `false` on user-initiated `retry()` (so manual retry after total failure restarts from "Connecting...").
- Never reset during automatic reconnection (preserves `"reconnecting"` labeling for post-success retries).

### Session (existing, unchanged)

```ts
interface Session {
  id: string;
  name: string;
  playbook: string;
  feature: string;
  createdAt: string;
  status: string;
  worktreePath: string;
}
```

No changes. Session resolution is handled in `page.tsx` before `TerminalPanel` mounts.

## Validation Rules

- A WebSocket connection MUST NOT be attempted if `sessionId` is empty or undefined (existing rendering guard in `page.tsx` covers this; no additional runtime guard needed).
- `hasEverConnectedRef` MUST be reset to `false` when `retry()` is manually invoked by the user (so the overlay shows "Connecting..." not "Reconnecting..." on user-initiated retry after error).
- `reconnectAttemptsRef` MUST be reset to `0` on both `ws.onopen` and on manual `retry()` invocation (existing behavior, preserved).

## Overlay Message Mapping (corrected)

| ConnectionState | Overlay Message | Spinner | Retry Button |
|-----------------|----------------|---------|-------------|
| `idle` | "Connecting..." | yes | no |
| `connecting` | "Connecting..." | yes | no |
| `connected` | (none — overlay hidden) | — | — |
| `disconnected` | "Connection lost. Retrying..." | yes | no |
| `reconnecting` | "Connection lost. Retrying..." | yes | no |
| `error` | "Connection failed." | no | yes |
