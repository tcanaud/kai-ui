"use client";

import type { PanelProps } from "@/app/lib/types";
import { PanelSlot } from "./panel-slot";

export function AssistantPlaceholder({ sessionId, isActive }: PanelProps) {
  return (
    <PanelSlot type="assistant" sessionId={sessionId} isActive={isActive}>
      <div className="flex flex-col items-center justify-center h-full min-h-[200px] gap-4">
        <div className="relative">
          <div className="h-12 w-12 rounded-full border-2 border-neon-magenta flex items-center justify-center glow-magenta">
            <span className="text-neon-magenta text-lg font-bold font-mono">
              AI
            </span>
          </div>
        </div>
        <p className="text-sm text-muted-foreground font-mono text-center">
          AI Assistant Overlay
        </p>
        <span className="text-xs text-neon-violet px-2 py-1 rounded border border-neon-violet-dim bg-neon-violet-dim/20">
          Coming in V1.5
        </span>
      </div>
    </PanelSlot>
  );
}
