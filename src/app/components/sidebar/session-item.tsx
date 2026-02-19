"use client";

import type { Session } from "@/app/lib/types";
import { GitBranch } from "lucide-react";

interface SessionItemProps {
  session: Session;
  isActive: boolean;
  onClick: () => void;
}

export function SessionItem({ session, isActive, onClick }: SessionItemProps) {
  return (
    <button
      onClick={onClick}
      className={`w-full text-left px-3 py-2.5 rounded-md transition-all duration-150 group ${
        isActive
          ? "bg-neon-cyan-dim/20 border-glow-cyan border"
          : "hover:bg-secondary/80 border border-transparent"
      }`}
    >
      <div className="flex items-center gap-2">
        <GitBranch
          className={`h-3.5 w-3.5 flex-shrink-0 ${
            isActive ? "text-neon-cyan" : "text-muted-foreground"
          }`}
        />
        <span
          className={`text-sm font-mono truncate ${
            isActive ? "text-neon-cyan text-glow-cyan" : "text-foreground"
          }`}
        >
          {session.name}
        </span>
      </div>
      <div className="mt-1 ml-5.5 flex items-center gap-2">
        <span className="text-xs text-muted-foreground truncate">
          {session.playbook}
        </span>
        <span
          className={`text-[10px] px-1.5 py-0.5 rounded font-mono ${
            session.status === "active"
              ? "text-neon-cyan bg-neon-cyan-dim/20"
              : "text-muted-foreground bg-secondary"
          }`}
        >
          {session.status}
        </span>
      </div>
    </button>
  );
}
