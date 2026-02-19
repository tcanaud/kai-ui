"use client";

import type { PanelProps } from "@/app/lib/types";
import { PanelSlot } from "./panel-slot";

export function PlaybookPlaceholder({ sessionId, isActive }: PanelProps) {
  return (
    <PanelSlot type="playbook" sessionId={sessionId} isActive={isActive}>
      <div className="flex flex-col items-center justify-center h-full min-h-[200px] gap-4">
        <div className="flex gap-2">
          {["Step 1", "Step 2", "Step 3"].map((step, i) => (
            <div
              key={step}
              className={`text-xs px-2 py-1 rounded border font-mono ${
                i === 0
                  ? "border-neon-cyan text-neon-cyan bg-neon-cyan-dim/20"
                  : "border-border text-muted-foreground"
              }`}
            >
              {step}
            </div>
          ))}
        </div>
        <p className="text-sm text-muted-foreground font-mono text-center">
          Playbook Dashboard
        </p>
        <span className="text-xs text-neon-violet px-2 py-1 rounded border border-neon-violet-dim bg-neon-violet-dim/20">
          Coming in V1.3
        </span>
      </div>
    </PanelSlot>
  );
}
