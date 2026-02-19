"use client";

import type { PanelProps } from "@/app/lib/types";
import { PanelSlot } from "./panel-slot";

export function TerminalPlaceholder({ sessionId, isActive }: PanelProps) {
  return (
    <PanelSlot type="terminal" sessionId={sessionId} isActive={isActive}>
      <div className="flex flex-col items-center justify-center h-full min-h-[200px] gap-4">
        <div className="text-4xl text-neon-cyan text-glow-cyan">▶_</div>
        <p className="text-sm text-muted-foreground font-mono text-center">
          xterm.js + tmux integration
        </p>
        <span className="text-xs text-neon-violet px-2 py-1 rounded border border-neon-violet-dim bg-neon-violet-dim/20">
          Coming in V1.1
        </span>
      </div>
    </PanelSlot>
  );
}
