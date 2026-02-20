import * as pty from "node-pty";
import { execSync } from "node:child_process";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import type { WebSocket } from "ws";

export interface PtySession {
  sessionId: string;
  tmuxSessionName: string;
  pty: pty.IPty;
  clients: Set<WebSocket>;
  cols: number;
  rows: number;
}

const sessions = new Map<string, PtySession>();

/** Check if tmux is available on PATH */
export function checkTmux(): boolean {
  try {
    execSync("which tmux", { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

/** Resolve worktree path, falling back to $HOME */
function resolveWorktreePath(worktreePath?: string): string {
  if (worktreePath && existsSync(worktreePath)) {
    return worktreePath;
  }
  if (worktreePath) {
    console.warn(
      `[pty-manager] worktreePath "${worktreePath}" does not exist, falling back to $HOME`
    );
  }
  return homedir();
}

/** Create or re-attach to a PTY session */
export function createSession(
  sessionId: string,
  worktreePath?: string
): PtySession {
  const existing = sessions.get(sessionId);
  if (existing) {
    return existing;
  }

  const cwd = resolveWorktreePath(worktreePath);
  const tmuxSessionName = `kai-${sessionId}`;

  const shell = process.env.SHELL || "/bin/zsh";
  const ptyProcess = pty.spawn(shell, ["-c", `tmux new-session -A -s ${tmuxSessionName} -c ${cwd}`], {
    name: "xterm-256color",
    cols: 120,
    rows: 40,
    cwd,
    env: process.env as Record<string, string>,
  });

  const session: PtySession = {
    sessionId,
    tmuxSessionName,
    pty: ptyProcess,
    clients: new Set(),
    cols: 120,
    rows: 40,
  };

  ptyProcess.onData((data: string) => {
    for (const client of session.clients) {
      if (client.readyState === 1) {
        // WebSocket.OPEN
        client.send(data);
      }
    }
  });

  ptyProcess.onExit(({ exitCode }) => {
    const exitMsg = JSON.stringify({ type: "exit", code: exitCode });
    for (const client of session.clients) {
      if (client.readyState === 1) {
        client.send(exitMsg);
      }
    }
    sessions.delete(sessionId);
  });

  sessions.set(sessionId, session);
  return session;
}

/** Attach a WebSocket client to an existing session */
export function attachClient(sessionId: string, ws: WebSocket): PtySession | null {
  const session = sessions.get(sessionId);
  if (!session) return null;
  session.clients.add(ws);
  return session;
}

/** Detach a WebSocket client from a session */
export function detachClient(sessionId: string, ws: WebSocket): void {
  const session = sessions.get(sessionId);
  if (!session) return;
  session.clients.delete(ws);
  // Keep PTY alive even with no clients — tmux persists
}

/** Resize the PTY for a session */
export function resizeSession(
  sessionId: string,
  cols: number,
  rows: number
): void {
  const session = sessions.get(sessionId);
  if (!session) return;

  // Validate bounds
  const validCols = Math.max(1, Math.min(500, cols));
  const validRows = Math.max(1, Math.min(200, rows));

  session.cols = validCols;
  session.rows = validRows;
  session.pty.resize(validCols, validRows);
}

/** Get a session by ID */
export function getSession(sessionId: string): PtySession | undefined {
  return sessions.get(sessionId);
}

/** Get the count of active sessions */
export function getActiveSessionCount(): number {
  return sessions.size;
}

/** Clean up all sessions (for graceful shutdown) */
export function cleanupAll(): void {
  for (const [id, session] of sessions) {
    session.pty.kill();
    sessions.delete(id);
  }
}
