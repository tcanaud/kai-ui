import { createServer } from "node:http";
import { URL } from "node:url";
import { WebSocketServer, WebSocket } from "ws";
import {
  checkTmux,
  createSession,
  attachClient,
  detachClient,
  resizeSession,
  getActiveSessionCount,
  cleanupAll,
} from "./pty-manager.js";

const PORT = Number(process.env.TERMINAL_PORT) || 3001;

// Check tmux availability at startup
const tmuxAvailable = checkTmux();
if (!tmuxAvailable) {
  console.error("[terminal-server] WARNING: tmux not found on PATH. Terminal sessions will fail.");
}

const httpServer = createServer((req, res) => {
  if (req.method === "GET" && req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok", activeSessions: getActiveSessionCount() }));
    return;
  }
  res.writeHead(404);
  res.end();
});

const wss = new WebSocketServer({ server: httpServer });

wss.on("connection", (ws: WebSocket, req) => {
  const url = new URL(req.url || "/", `http://localhost:${PORT}`);
  const pathMatch = url.pathname.match(/^\/terminal\/(.+)$/);

  if (!pathMatch) {
    ws.close(4002, "Invalid path. Expected /terminal/:sessionId");
    return;
  }

  const sessionId = pathMatch[1];
  const worktreePath = url.searchParams.get("worktreePath") || undefined;

  if (!tmuxAvailable) {
    const errMsg = JSON.stringify({ type: "error", message: "tmux not found on PATH" });
    ws.send(errMsg);
    ws.close(4003, "tmux binary not available");
    return;
  }

  // Create or get existing session
  let session;
  try {
    session = createSession(sessionId, worktreePath);
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Session creation failed";
    const errMsg = JSON.stringify({ type: "error", message });
    ws.send(errMsg);
    ws.close(4001, message);
    return;
  }

  // Attach this WebSocket client
  session.clients.add(ws);

  ws.on("message", (data: Buffer | string) => {
    const msg = data.toString();

    // Message discrimination: check if JSON control message
    if (msg.startsWith("{")) {
      try {
        const parsed = JSON.parse(msg);
        if (parsed.type === "resize" && typeof parsed.cols === "number" && typeof parsed.rows === "number") {
          resizeSession(sessionId, parsed.cols, parsed.rows);
          return;
        }
      } catch {
        // Not valid JSON, treat as raw input
      }
    }

    // Raw input data — write to PTY
    session.pty.write(msg);
  });

  ws.on("close", () => {
    detachClient(sessionId, ws);
  });

  ws.on("error", (err) => {
    console.error(`[terminal-server] WebSocket error for session ${sessionId}:`, err.message);
    detachClient(sessionId, ws);
  });
});

httpServer.listen(PORT, () => {
  console.log(`[terminal-server] Sidecar running on http://localhost:${PORT}`);
  console.log(`[terminal-server] WebSocket endpoint: ws://localhost:${PORT}/terminal/:sessionId`);
  console.log(`[terminal-server] Health check: http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on("SIGINT", () => {
  console.log("[terminal-server] Shutting down...");
  cleanupAll();
  wss.close();
  httpServer.close();
  process.exit(0);
});

process.on("SIGTERM", () => {
  cleanupAll();
  wss.close();
  httpServer.close();
  process.exit(0);
});
