# Data Model: Terminal Panel — xterm.js + tmux Integration

**Feature**: 001-terminal-panel-xterm-js-tmux-integration
**Date**: 2026-02-20

## Entities

### TerminalConnection

Represents the client-side connection state between the UI and a backend terminal session.

| Field | Type | Description |
|-------|------|-------------|
| sessionId | string | The kai session ID (maps 1:1 to a tmux session) |
| worktreePath | string | Absolute path to the session's worktree directory |
| state | ConnectionState | Current connection lifecycle state |
| cols | number | Current terminal column count |
| rows | number | Current terminal row count |
| websocketUrl | string | Computed WebSocket URL for this session |
| reconnectAttempts | number | Number of consecutive reconnection attempts |

**State Transitions (ConnectionState)**:

```
idle → connecting → connected → disconnected → reconnecting → connected
                                             → error (after max retries)
error → connecting (manual retry)
```

Valid states: `idle | connecting | connected | disconnected | reconnecting | error`

### TerminalTheme

Static configuration object applied to xterm.js. No persistence needed.

| Field | Type | Description |
|-------|------|-------------|
| background | string (hex) | Terminal background color — `#0a0a0f` |
| foreground | string (hex) | Default text color — `#e0e0e8` |
| cursor | string (hex) | Cursor color — `#00f0ff` |
| cursorAccent | string (hex) | Cursor text color — `#0a0a0f` |
| selectionBackground | string (hex) | Selection highlight — `#00f0ff33` |
| selectionForeground | string (hex) | Selected text color — `#e0e0e8` |
| black | string (hex) | ANSI 0 — `#1a1a2e` |
| red | string (hex) | ANSI 1 — `#ff3366` |
| green | string (hex) | ANSI 2 — `#00ff88` |
| yellow | string (hex) | ANSI 3 — `#ffaa00` |
| blue | string (hex) | ANSI 4 — `#8b5cf6` |
| magenta | string (hex) | ANSI 5 — `#ff00ff` |
| cyan | string (hex) | ANSI 6 — `#00f0ff` |
| white | string (hex) | ANSI 7 — `#e0e0e8` |
| brightBlack | string (hex) | ANSI 8 — `#2a2a3e` |
| brightRed | string (hex) | ANSI 9 — `#ff5588` |
| brightGreen | string (hex) | ANSI 10 — `#33ffaa` |
| brightYellow | string (hex) | ANSI 11 — `#ffcc33` |
| brightBlue | string (hex) | ANSI 12 — `#a78bfa` |
| brightMagenta | string (hex) | ANSI 13 — `#ff66ff` |
| brightCyan | string (hex) | ANSI 14 — `#66f5ff` |
| brightWhite | string (hex) | ANSI 15 — `#ffffff` |

### WebSocketMessage (wire protocol)

Messages exchanged between the xterm.js client and the terminal sidecar server.

**Client → Server**:

| Type | Payload | Description |
|------|---------|-------------|
| `data` | `string` (raw bytes) | Keyboard input forwarded to PTY stdin |
| `resize` | `{ cols: number, rows: number }` | Terminal dimension change |

**Server → Client**:

| Type | Payload | Description |
|------|---------|-------------|
| `data` | `string` (raw bytes) | PTY stdout/stderr output |
| `exit` | `{ code: number }` | PTY process exited |
| `error` | `{ message: string }` | Server-side error |

Wire format: JSON envelope `{ type: string, payload: any }` for control messages. Raw binary/text frames for bulk data transfer (optimization: data messages sent as raw text frames without JSON wrapping for performance).

### PtySession (server-side, in-memory)

Managed by the sidecar WebSocket server. Not persisted — tmux provides persistence.

| Field | Type | Description |
|-------|------|-------------|
| sessionId | string | The kai session ID |
| tmuxSessionName | string | tmux session name (derived: `kai-{sessionId}`) |
| pty | IPty | node-pty process handle |
| clients | Set\<WebSocket\> | Connected WebSocket clients |
| cols | number | Current PTY column count |
| rows | number | Current PTY row count |

## Relationships

```
Session (kai) 1 ──── 1 PtySession (sidecar server)
PtySession   1 ──── * WebSocket clients (browser tabs)
PtySession   1 ──── 1 tmux session (OS-level)
TerminalConnection 1 ──── 1 xterm.js Terminal instance (client)
```

## Validation Rules

- `sessionId` must be a non-empty string matching an existing kai session
- `worktreePath` must be an existing directory on the host filesystem (fallback to `$HOME` if missing)
- `cols` must be >= 1 and <= 500
- `rows` must be >= 1 and <= 200
- `reconnectAttempts` resets to 0 on successful connection
- Maximum 5 reconnection attempts before transitioning to `error` state
