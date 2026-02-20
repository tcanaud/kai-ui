---
id: devkit
title: "Devkit — dev server setup, environment, ports, and local workflow"
created: "2026-02-20"
last_verified: "2026-02-20"
references:
  conventions:
    - "conv-001-esm-zero-deps"
  adrs: []
  features:
    - "001-terminal-panel-xterm-js-tmux-integration"
watched_paths:
  - "package.json"
  - "next.config.ts"
  - "tsconfig.json"
  - "postcss.config.mjs"
  - "src/terminal-server/index.ts"
topics: [devkit, dev-server, environment, ports, scripts, local-development]
---

## Overview

kai-ui is a Next.js 16 app with a sidecar WebSocket server for terminal functionality. Local development involves two processes running in parallel: the Next.js dev server and the terminal sidecar.

## Prerequisites

- **Node.js** >= 18.0.0
- **tmux** on PATH (required for terminal panel — optional if you don't need terminal features)
- **npm** for package management

## Install

```bash
npm install
```

`node-pty` (native addon) compiles during install. If it fails, check that you have Xcode CLI tools (macOS) or `build-essential` (Linux).

## Scripts

| Command | What it does |
|---------|-------------|
| `npm run dev` | Next.js dev server on **:3000** |
| `npm run dev:terminal` | Terminal sidecar on **:3001** (uses `tsx`) |
| `npm run dev:all` | Both in parallel via `concurrently` |
| `npm run build` | Production build |
| `npm run start` | Serve production build |
| `npm run lint` | ESLint |

For full local development with terminal support, use:

```bash
npm run dev:all
```

## Ports

| Port | Service | Protocol |
|------|---------|----------|
| 3000 | Next.js dev server | HTTP |
| 3001 | Terminal sidecar | HTTP + WebSocket |

Next.js proxies `/terminal/*` requests to the sidecar via a rewrite rule in `next.config.ts`.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TERMINAL_PORT` | `3001` | Port for the terminal sidecar server |

No `.env` file is required — all defaults work out of the box.

## Architecture

```
Browser (:3000)
  │
  ├── Next.js App Router (pages, components, API)
  │
  └── /terminal/:sessionId  ──rewrite──▶  ws://localhost:3001/terminal/:sessionId
                                            │
                                            └── node-pty + tmux session
```

- The sidecar creates tmux sessions per `sessionId`
- WebSocket carries raw terminal I/O (text) and JSON control messages (resize, error)
- Health check: `GET http://localhost:3001/health`

## Verifying the Setup

1. Run `npm run dev:all`
2. Open http://localhost:3000 — UI should load
3. Check sidecar health: `curl http://localhost:3001/health` — should return `{"status":"ok","activeSessions":0}`
4. The terminal panel in the UI should connect and show a shell prompt

## Notes

- The terminal sidecar uses `tsx` to run TypeScript directly — no build step needed for dev
- If tmux is not installed, the sidecar starts but warns and rejects all terminal connections with close code 4003
- The sidecar cleans up all PTY sessions on SIGINT/SIGTERM
