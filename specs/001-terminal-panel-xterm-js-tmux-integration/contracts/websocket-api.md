# WebSocket API Contract: Terminal Sidecar Server

**Endpoint**: `ws://localhost:3001/terminal/:sessionId`

## Connection Lifecycle

### Connect
- **URL**: `ws://localhost:3001/terminal/{sessionId}`
- **Query params**: `worktreePath` (optional, URL-encoded absolute path)
- **Behavior**: Server looks up or creates a `PtySession` for the given `sessionId`. If no tmux session exists, creates one with `tmux new-session -A -s kai-{sessionId} -c {worktreePath}`. Attaches the WebSocket as a client.
- **Success**: WebSocket connection established, server begins streaming PTY output.
- **Error**: WebSocket closed with code `4001` and reason string if session creation fails.

### Disconnect
- WebSocket `close` event removes the client from `PtySession.clients`.
- If no clients remain, the PTY handle is released but the tmux session continues running (persistence).
- On next connection with the same `sessionId`, re-attaches to the existing tmux session.

## Messages

### Client → Server

#### Input Data (raw text frame)
```
<raw keystroke data as UTF-8 string>
```
No JSON wrapping. Sent directly to PTY stdin.

#### Resize (JSON text frame)
```json
{
  "type": "resize",
  "cols": 120,
  "rows": 40
}
```
Server calls `pty.resize(cols, rows)`.

### Server → Client

#### Output Data (raw text frame)
```
<raw PTY output as UTF-8 string>
```
No JSON wrapping. Written directly to xterm.js.

#### Error (JSON text frame)
```json
{
  "type": "error",
  "message": "tmux not found on PATH"
}
```

#### Exit (JSON text frame)
```json
{
  "type": "exit",
  "code": 0
}
```
Sent when the PTY process exits. The WebSocket remains open to allow reconnection.

## Message Discrimination

To distinguish raw data frames from JSON control messages, the server checks if the incoming text starts with `{` and attempts JSON parse. If it fails or has no `type` field, it is treated as raw input data. Server output follows the same convention: frames starting with `{"type":` are control messages; all other frames are raw PTY output.

## Error Codes (WebSocket close)

| Code | Meaning |
|------|---------|
| 1000 | Normal close (client navigated away) |
| 1001 | Going away (server shutdown) |
| 4001 | Session creation failed (tmux error, invalid path) |
| 4002 | Session not found and no worktreePath provided |
| 4003 | tmux binary not available |

## Health Check

**HTTP GET** `http://localhost:3001/health`

Response:
```json
{
  "status": "ok",
  "activeSessions": 3
}
```
