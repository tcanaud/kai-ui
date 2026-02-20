"use client";

import "@xterm/xterm/css/xterm.css";
import { useRef } from "react";
import { useTerminal } from "@/app/lib/use-terminal";
import type { ConnectionState } from "@/app/lib/use-terminal";
import { PanelSlot } from "./panel-slot";
import type { PanelProps } from "@/app/lib/types";

interface TerminalPanelProps extends PanelProps {
  worktreePath: string;
}

function ConnectionOverlay({
  state,
  onRetry,
}: {
  state: ConnectionState;
  onRetry: () => void;
}) {
  if (state === "connected") return null;

  let message: string;
  let showRetry = false;

  switch (state) {
    case "idle":
    case "connecting":
      message = "Connecting...";
      break;
    case "reconnecting":
      message = "Connection lost. Retrying...";
      break;
    case "disconnected":
      message = "Connection lost. Retrying...";
      break;
    case "error":
      message = "Connection failed.";
      showRetry = true;
      break;
  }

  return (
    <div className="absolute inset-0 z-10 flex flex-col items-center justify-center bg-[#0a0a0f]/90 backdrop-blur-sm">
      <p className="text-sm font-mono text-neon-cyan text-glow-cyan mb-3">
        {message}
      </p>
      {showRetry && (
        <button
          onClick={onRetry}
          className="px-4 py-1.5 text-xs font-mono border border-neon-cyan text-neon-cyan rounded hover:bg-neon-cyan/10 transition-colors"
        >
          Retry
        </button>
      )}
      {!showRetry && (
        <div className="flex gap-1">
          <span className="w-1.5 h-1.5 rounded-full bg-neon-cyan animate-pulse" />
          <span className="w-1.5 h-1.5 rounded-full bg-neon-cyan animate-pulse delay-150" />
          <span className="w-1.5 h-1.5 rounded-full bg-neon-cyan animate-pulse delay-300" />
        </div>
      )}
    </div>
  );
}

export function TerminalPanel({
  sessionId,
  isActive,
  worktreePath,
}: TerminalPanelProps) {
  const terminalRef = useRef<HTMLDivElement>(null);
  const { connectionState, retry } = useTerminal({
    containerRef: terminalRef,
    sessionId,
    worktreePath,
  });

  return (
    <PanelSlot type="terminal" sessionId={sessionId} isActive={isActive}>
      <div className="relative w-full h-full min-h-[200px]" style={{ background: "#0a0a0f" }}>
        <ConnectionOverlay state={connectionState} onRetry={retry} />
        <div
          ref={terminalRef}
          className="w-full h-full"
          style={{ background: "#0a0a0f" }}
        />
      </div>
    </PanelSlot>
  );
}
