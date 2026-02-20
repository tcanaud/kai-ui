# Research: Terminal Panel — xterm.js + tmux Integration

**Feature**: 001-terminal-panel-xterm-js-tmux-integration
**Date**: 2026-02-20

## R1: xterm.js Integration in Next.js (React 19)

**Decision**: Use `@xterm/xterm` v5+ with `@xterm/addon-fit` and `@xterm/addon-web-links`. Load via dynamic import (`next/dynamic` with `ssr: false`) since xterm.js requires DOM APIs.

**Rationale**: xterm.js is the de facto standard for browser-based terminal emulation (used by VS Code, GitHub Codespaces, Theia). The `@xterm/xterm` scoped packages are the maintained v5 line. React 19 compatibility is achieved by wrapping in a `useEffect`-based component with a ref for the terminal container div. Dynamic import avoids SSR crashes since xterm accesses `window`/`document`.

**Alternatives considered**:
- `react-terminal` — Too simplistic, no PTY support, just command simulation.
- `terminal.js` — Unmaintained, no WebGL renderer.
- Raw canvas-based — Enormous effort for no benefit over xterm.js.

## R2: WebSocket Transport for PTY Bridging

**Decision**: Use a custom Next.js API route upgraded to WebSocket via the Node.js `ws` library, running a `node-pty` child process attached to `tmux attach-session`. The Next.js custom server approach or a standalone sidecar WebSocket server on a separate port.

**Rationale**: Next.js App Router API routes do not natively support WebSocket upgrades. Two viable approaches exist:
1. **Custom server** (`server.ts`) — intercept the HTTP upgrade event on the Node HTTP server, hand off to `ws`. This is the cleanest for a single-process deployment.
2. **Sidecar process** — a small standalone Node.js WebSocket server on a different port (e.g., 3001). The UI connects to `ws://localhost:3001/terminal/:sessionId`. Simpler to implement and avoids modifying the Next.js server entrypoint.

We choose the **sidecar approach** for separation of concerns: the terminal server handles PTY lifecycle independently, making it easier to test and deploy. The sidecar is started alongside `next dev` via a `concurrently` script.

**Alternatives considered**:
- Socket.IO — Unnecessary overhead; raw WebSocket is sufficient for a binary stream.
- Server-Sent Events — Unidirectional, cannot send input from client to server.
- Next.js middleware WebSocket — Not supported in App Router.

## R3: tmux Session Management

**Decision**: Use `node-pty` to spawn `tmux new-session -A -s <session-name> -c <worktree-path>`. The `-A` flag attaches if the session exists or creates it if it does not. Session name is derived from the kai session ID.

**Rationale**: The `-A` flag on `tmux new-session` handles the "create or attach" logic in a single command, eliminating race conditions. `node-pty` provides a proper PTY (pseudo-terminal) that tmux requires — raw `child_process.spawn` does not allocate a PTY and tmux will refuse to run.

**Alternatives considered**:
- Manually checking `tmux has-session` then branching — Race-prone, more code.
- Using `tmux -CC` (control mode) — Non-standard, macOS-specific features.
- Direct shell without tmux — No persistence across reconnections.

## R4: Resize / Fit Handling

**Decision**: Use `@xterm/addon-fit` with a `ResizeObserver` on the terminal container, debounced at 100ms. On fit, send the new `{cols, rows}` dimensions over WebSocket to the server, which calls `pty.resize(cols, rows)`.

**Rationale**: `ResizeObserver` is the modern, efficient way to detect container dimension changes (works for panel drag-resize, browser window resize, and CSS layout shifts). The fit addon calculates optimal cols/rows from pixel dimensions. Debouncing at 100ms prevents flooding during drag operations.

**Alternatives considered**:
- `window.resize` event only — Misses panel-internal resizes.
- Polling dimensions — Wasteful and laggy.
- No debounce — Floods backend with resize calls during drag.

## R5: Cyberpunk Theme Mapping

**Decision**: Define an `ITheme` object for xterm.js that maps the 16 ANSI colors plus background/foreground/cursor/selection to the kai CSS custom properties. Extract the hex values from `globals.css` design tokens.

**Rationale**: xterm.js accepts an `ITheme` object at construction or via `terminal.options.theme`. This is the standard, supported theming mechanism. Mapping to existing CSS variables ensures visual consistency.

The theme will use:
- Background: `#0a0a0f` (--background)
- Foreground: `#e0e0e8` (--foreground)
- Cursor: `#00f0ff` (--neon-cyan)
- Selection: `#00f0ff33` (--neon-cyan-dim)
- ANSI Black: `#1a1a2e`, Red: `#ff3366`, Green: `#00ff88`, Yellow: `#ffaa00`, Blue: `#8b5cf6`, Magenta: `#ff00ff`, Cyan: `#00f0ff`, White: `#e0e0e8`
- Bright variants with increased luminance

**Alternatives considered**:
- CSS injection to override xterm internals — Fragile, breaks on xterm updates.
- WebGL shader-based theming — Overkill for color mapping.

## R6: Copy/Paste and Scrollback

**Decision**: Enable xterm.js built-in selection and clipboard handling. Set `scrollback: 10000` lines. Enable bracketed paste mode via the `@xterm/addon-clipboard` or by handling paste events manually and wrapping in `\x1b[200~...\x1b[201~`.

**Rationale**: xterm.js natively supports text selection and the Clipboard API for copy. Paste requires intercepting the browser paste event and writing to the terminal. Bracketed paste mode signals to the shell that the input is pasted (not typed), preventing line-by-line execution of multi-line pastes.

**Alternatives considered**:
- Custom selection rendering — Unnecessary; xterm.js handles this well.
- Unlimited scrollback — Memory concern; 10,000 lines is generous and bounded.

## R7: Error Handling and Reconnection

**Decision**: Implement a connection state machine in the React component: `connecting → connected → disconnected → reconnecting → connected|error`. On WebSocket close/error, attempt reconnection with exponential backoff (1s, 2s, 4s, max 30s). After 5 failures, show an error state with a manual retry button.

**Rationale**: Network interruptions are common. Automatic reconnection with backoff provides resilience without overwhelming the server. The tmux session persists server-side regardless of WebSocket state, so reconnection simply re-attaches.

**Alternatives considered**:
- No auto-reconnect — Poor UX; user must manually retry on every blip.
- Infinite retry — Could mask permanent failures.
- WebSocket ping/pong keepalive — Good addition but doesn't replace reconnection logic.
