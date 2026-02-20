# Implementation Plan: Terminal Panel — xterm.js + tmux Integration

**Branch**: `001-terminal-panel-xterm-js-tmux-integration` | **Date**: 2026-02-20 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-terminal-panel-xterm-js-tmux-integration/spec.md`

## Summary

Replace the terminal placeholder component with a fully functional xterm.js terminal emulator connected to persistent tmux sessions via a WebSocket sidecar server. The terminal renders in the existing panel slot with cyberpunk theming, supports copy/paste/scrollback, and resizes dynamically with the panel.

## Technical Context

**Language/Version**: TypeScript 5.x, Node.js >= 18.0.0, React 19, Next.js 16
**Primary Dependencies**: `@xterm/xterm` (terminal emulator), `@xterm/addon-fit` (resize), `@xterm/addon-web-links` (clickable URLs), `ws` (WebSocket server), `node-pty` (PTY allocation)
**Storage**: N/A (tmux provides persistence; no database)
**Testing**: Manual verification initially; Playwright for E2E (future)
**Target Platform**: Web (modern browsers — Chrome, Firefox, Safari), macOS/Linux host for backend
**Project Type**: Web application (frontend Next.js + backend sidecar server)
**Performance Goals**: Shell prompt visible within 3 seconds; command output within 1 second; 60fps terminal rendering
**Constraints**: WebSocket latency < 50ms local; scrollback buffer capped at 10,000 lines; resize debounce at 100ms
**Scale/Scope**: Single user, single host deployment; 1-5 concurrent terminal sessions

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The project constitution is a template with placeholder principles (not yet filled in). No specific gates or constraints are defined. Proceeding without violations.

**Post-Phase-1 re-check**: No constitution violations. The design uses standard patterns (React component, WebSocket, PTY) with zero unnecessary abstractions.

## Project Structure

### Documentation (this feature)

```text
specs/001-terminal-panel-xterm-js-tmux-integration/
├── plan.md              # This file
├── research.md          # Phase 0 output — technology decisions
├── data-model.md        # Phase 1 output — entities and wire protocol
├── quickstart.md        # Phase 1 output — setup and verification
├── contracts/           # Phase 1 output — API contracts
│   └── websocket-api.md # WebSocket sidecar protocol specification
└── tasks.md             # Phase 2 output (/speckit.tasks — NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
src/
├── app/
│   ├── components/
│   │   └── panels/
│   │       ├── terminal-panel.tsx       # NEW: xterm.js React component
│   │       ├── panel-layout.tsx         # MODIFIED: swap placeholder → panel
│   │       └── panel-slot.tsx           # MODIFIED: full-bleed mode for terminal
│   └── lib/
│       ├── terminal-theme.ts            # NEW: cyberpunk ITheme object
│       └── use-terminal.ts              # NEW: React hook (WebSocket + xterm lifecycle)
└── terminal-server/
    ├── index.ts                         # NEW: sidecar WebSocket server entrypoint
    └── pty-manager.ts                   # NEW: PTY session create/attach/resize/cleanup
```

**Structure Decision**: Web application with frontend (existing Next.js app) and a lightweight backend sidecar (new `terminal-server/` directory under `src/`). The sidecar runs as a separate Node.js process since Next.js App Router does not support WebSocket upgrades natively.

## Complexity Tracking

No constitution violations to justify. The architecture is minimal:
- 2 new frontend files (component + hook) + 1 theme config
- 2 new backend files (server + pty manager)
- 2 modified files (panel-layout, panel-slot)
- 3 new npm dependencies (xterm, ws, node-pty)
