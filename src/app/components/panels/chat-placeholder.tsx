"use client";

import type { PanelProps } from "@/app/lib/types";
import { PanelSlot } from "./panel-slot";

export function ChatPlaceholder({ sessionId, isActive }: PanelProps) {
  return (
    <PanelSlot type="chat" sessionId={sessionId} isActive={isActive}>
      <div className="flex flex-col items-center justify-center h-full min-h-[200px] gap-4">
        <div className="flex flex-col gap-2 w-full max-w-[200px]">
          <div className="self-end bg-neon-cyan-dim/20 border border-neon-cyan-dim rounded-lg px-3 py-1.5">
            <span className="text-xs font-mono text-neon-cyan">
              /implement T015
            </span>
          </div>
          <div className="self-start bg-secondary border border-border rounded-lg px-3 py-1.5">
            <span className="text-xs font-mono text-muted-foreground">
              Creating panel...
            </span>
          </div>
        </div>
        <p className="text-sm text-muted-foreground font-mono text-center">
          AI Chat
        </p>
        <span className="text-xs text-neon-violet px-2 py-1 rounded border border-neon-violet-dim bg-neon-violet-dim/20">
          Coming in V1.4
        </span>
      </div>
    </PanelSlot>
  );
}
