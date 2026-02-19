"use client";

import type { PanelProps } from "@/app/lib/types";
import { PanelSlot } from "./panel-slot";

export function EditorPlaceholder({ sessionId, isActive }: PanelProps) {
  return (
    <PanelSlot type="editor" sessionId={sessionId} isActive={isActive}>
      <div className="flex flex-col items-center justify-center h-full min-h-[200px] gap-4">
        <div className="font-mono text-sm text-muted-foreground space-y-1">
          <div>
            <span className="text-neon-magenta">const</span>{" "}
            <span className="text-neon-cyan">editor</span>{" "}
            <span className="text-muted-foreground">=</span>{" "}
            <span className="text-neon-violet">await</span>{" "}
            <span className="text-foreground">loadCodeServer</span>
            <span className="text-muted-foreground">();</span>
          </div>
        </div>
        <p className="text-sm text-muted-foreground font-mono text-center">
          code-server integration
        </p>
        <span className="text-xs text-neon-violet px-2 py-1 rounded border border-neon-violet-dim bg-neon-violet-dim/20">
          Coming in V1.2
        </span>
      </div>
    </PanelSlot>
  );
}
