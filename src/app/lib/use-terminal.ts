"use client";

import { useEffect, useRef, useState, useCallback } from "react";
import type { Terminal } from "@xterm/xterm";
import { terminalTheme } from "./terminal-theme";

export type ConnectionState =
  | "idle"
  | "connecting"
  | "connected"
  | "disconnected"
  | "reconnecting"
  | "error";

interface UseTerminalOptions {
  containerRef: React.RefObject<HTMLDivElement | null>;
  sessionId: string;
  worktreePath: string;
}

const MAX_RECONNECT_ATTEMPTS = 5;
const LARGE_PASTE_THRESHOLD = 10000;

export function useTerminal({
  containerRef,
  sessionId,
  worktreePath,
}: UseTerminalOptions) {
  const [connectionState, setConnectionState] = useState<ConnectionState>("idle");
  const terminalRef = useRef<Terminal | null>(null);
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectAttemptsRef = useRef(0);
  const reconnectTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const fitAddonRef = useRef<{ fit: () => void } | null>(null);
  const resizeObserverRef = useRef<ResizeObserver | null>(null);
  const resizeDebounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const connect = useCallback(
    (term: Terminal) => {
      const state = reconnectAttemptsRef.current > 0 ? "reconnecting" : "connecting";
      setConnectionState(state);

      const wsUrl = `ws://localhost:3001/terminal/${sessionId}?worktreePath=${encodeURIComponent(worktreePath)}`;
      const ws = new WebSocket(wsUrl);
      wsRef.current = ws;

      ws.onopen = () => {
        setConnectionState("connected");
        reconnectAttemptsRef.current = 0;

        // Send initial size
        if (fitAddonRef.current) {
          fitAddonRef.current.fit();
          const dims = { type: "resize", cols: term.cols, rows: term.rows };
          ws.send(JSON.stringify(dims));
        }
      };

      ws.onmessage = (event) => {
        const data = typeof event.data === "string" ? event.data : "";
        term.write(data);
      };

      ws.onclose = () => {
        setConnectionState("disconnected");
        attemptReconnect(term);
      };

      ws.onerror = () => {
        // onclose will fire after onerror
      };
    },
    [sessionId, worktreePath]
  );

  const attemptReconnect = useCallback(
    (term: Terminal) => {
      if (reconnectAttemptsRef.current >= MAX_RECONNECT_ATTEMPTS) {
        setConnectionState("error");
        return;
      }
      reconnectAttemptsRef.current += 1;
      const delay = Math.min(1000 * Math.pow(2, reconnectAttemptsRef.current - 1), 30000);
      reconnectTimerRef.current = setTimeout(() => {
        connect(term);
      }, delay);
    },
    [connect]
  );

  const retry = useCallback(() => {
    if (terminalRef.current) {
      reconnectAttemptsRef.current = 0;
      connect(terminalRef.current);
    }
  }, [connect]);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    let disposed = false;

    // Dynamic imports to avoid SSR issues
    async function init() {
      const [
        { Terminal },
        { FitAddon },
        { WebLinksAddon },
      ] = await Promise.all([
        import("@xterm/xterm"),
        import("@xterm/addon-fit"),
        import("@xterm/addon-web-links"),
      ]);

      if (disposed) return;

      const fitAddon = new FitAddon();
      const webLinksAddon = new WebLinksAddon();

      const term = new Terminal({
        scrollback: 10000,
        cursorBlink: true,
        fontFamily: "monospace",
        fontSize: 14,
        theme: terminalTheme,
        allowProposedApi: true,
      });

      term.loadAddon(fitAddon);
      term.loadAddon(webLinksAddon);

      term.open(container!);
      fitAddon.fit();

      terminalRef.current = term;
      fitAddonRef.current = fitAddon;

      // Pipe terminal input to WebSocket
      term.onData((data: string) => {
        const ws = wsRef.current;
        if (ws && ws.readyState === WebSocket.OPEN) {
          ws.send(data);
        }
      });

      // Clipboard: handle paste with bracketed paste mode
      container!.addEventListener("paste", (e: ClipboardEvent) => {
        e.preventDefault();
        const text = e.clipboardData?.getData("text");
        if (!text) return;

        if (text.length > LARGE_PASTE_THRESHOLD) {
          console.warn(
            `[use-terminal] Large paste detected (${text.length} chars). Proceeding with bracketed paste mode.`
          );
        }

        // Wrap in bracketed paste mode
        const bracketedPaste = `\x1b[200~${text}\x1b[201~`;
        const ws = wsRef.current;
        if (ws && ws.readyState === WebSocket.OPEN) {
          ws.send(bracketedPaste);
        }
      });

      // ResizeObserver for dynamic resize
      const observer = new ResizeObserver(() => {
        if (resizeDebounceRef.current) {
          clearTimeout(resizeDebounceRef.current);
        }
        resizeDebounceRef.current = setTimeout(() => {
          if (disposed) return;
          fitAddon.fit();
          const ws = wsRef.current;
          if (ws && ws.readyState === WebSocket.OPEN) {
            ws.send(JSON.stringify({ type: "resize", cols: term.cols, rows: term.rows }));
          }
        }, 100);
      });
      observer.observe(container!);
      resizeObserverRef.current = observer;

      // Connect
      connect(term);
    }

    init();

    return () => {
      disposed = true;
      if (reconnectTimerRef.current) clearTimeout(reconnectTimerRef.current);
      if (resizeDebounceRef.current) clearTimeout(resizeDebounceRef.current);
      if (resizeObserverRef.current) resizeObserverRef.current.disconnect();
      if (wsRef.current) {
        wsRef.current.onclose = null; // Prevent reconnection on cleanup
        wsRef.current.close();
      }
      if (terminalRef.current) terminalRef.current.dispose();
    };
  }, [containerRef, sessionId, worktreePath, connect]);

  return { connectionState, retry };
}
