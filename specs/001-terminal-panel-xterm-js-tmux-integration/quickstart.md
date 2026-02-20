# Quickstart: Terminal Panel — xterm.js + tmux Integration

**Feature**: 001-terminal-panel-xterm-js-tmux-integration

## Prerequisites

- Node.js >= 18.0.0
- tmux installed on the host (`brew install tmux` on macOS)
- The kai-ui project cloned and dependencies installed

## New Dependencies

### Frontend (existing Next.js app)
```bash
npm install @xterm/xterm @xterm/addon-fit @xterm/addon-web-links
```

### Terminal Sidecar Server (new)
```bash
npm install ws node-pty
npm install -D @types/ws
```

Note: `node-pty` requires native compilation. On macOS this needs Xcode Command Line Tools. On Linux, `build-essential` and `python3`.

## Architecture Overview

```
Browser (xterm.js)  ←──WebSocket──→  Sidecar Server (ws + node-pty)  ←──PTY──→  tmux session
     :3000                                  :3001                                   (persistent)
```

- **Next.js app** (port 3000) — serves the React UI with the xterm.js terminal component
- **Terminal sidecar** (port 3001) — standalone Node.js WebSocket server managing PTY sessions
- **tmux** — OS-level terminal multiplexer providing session persistence

## Key Files to Create/Modify

### New Files
| Path | Purpose |
|------|---------|
| `src/app/components/panels/terminal-panel.tsx` | React component wrapping xterm.js (replaces `terminal-placeholder.tsx`) |
| `src/app/lib/terminal-theme.ts` | Cyberpunk ITheme configuration for xterm.js |
| `src/app/lib/use-terminal.ts` | React hook managing WebSocket connection, xterm lifecycle, resize |
| `src/terminal-server/index.ts` | Sidecar WebSocket server entry point |
| `src/terminal-server/pty-manager.ts` | PTY session lifecycle (create/attach/resize/cleanup) |

### Modified Files
| Path | Change |
|------|--------|
| `src/app/components/panels/panel-layout.tsx` | Import `TerminalPanel` instead of `TerminalPlaceholder` |
| `src/app/components/panels/panel-slot.tsx` | Remove padding from terminal slot (xterm needs full bleed) |
| `package.json` | Add dependencies, add `dev:terminal` and `dev:all` scripts |
| `next.config.ts` | (Optional) Add WebSocket proxy rewrite for production |

## Running Locally

```bash
# Start both Next.js and terminal sidecar
npm run dev:all

# Or individually:
npm run dev           # Next.js on :3000
npm run dev:terminal  # Terminal sidecar on :3001
```

## Verification

1. Open `http://localhost:3000` in a browser
2. Select or create a session
3. The terminal panel should show a live shell prompt (not the placeholder)
4. Type `echo hello` and press Enter — output should appear
5. Refresh the page — the terminal should reconnect and show the same state
6. Resize the browser window — the terminal should reflow
