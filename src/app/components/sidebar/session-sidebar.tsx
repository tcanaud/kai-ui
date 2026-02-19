"use client";

import type { Session } from "@/app/lib/types";
import { SessionItem } from "./session-item";
import { NewSessionDialog } from "./new-session-dialog";
import { Zap } from "lucide-react";

interface SessionSidebarProps {
  sessions: Session[];
  activeSessionId: string | null;
  onSessionSelect: (id: string) => void;
  onSessionCreated: () => void;
}

export function SessionSidebar({
  sessions,
  activeSessionId,
  onSessionSelect,
  onSessionCreated,
}: SessionSidebarProps) {
  return (
    <div className="flex flex-col h-full bg-sidebar">
      {/* Header */}
      <div className="px-4 py-4 border-b border-sidebar-border">
        <div className="flex items-center gap-2">
          <Zap className="h-5 w-5 text-neon-cyan" />
          <h1 className="text-lg font-mono font-bold text-neon-cyan text-glow-cyan">
            kai ui
          </h1>
        </div>
      </div>

      {/* Session list */}
      <div className="flex-1 overflow-y-auto px-3 py-3 space-y-1">
        {sessions.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-12 text-center">
            <div className="text-3xl mb-3 text-neon-cyan-dim">⚡</div>
            <p className="text-sm text-muted-foreground mb-1">
              No sessions yet
            </p>
            <p className="text-xs text-muted-foreground">
              Create your first worktree session
            </p>
          </div>
        ) : (
          sessions.map((session) => (
            <SessionItem
              key={session.id}
              session={session}
              isActive={session.id === activeSessionId}
              onClick={() => onSessionSelect(session.id)}
            />
          ))
        )}
      </div>

      {/* New session button */}
      <div className="px-3 py-3 border-t border-sidebar-border">
        <NewSessionDialog onSessionCreated={onSessionCreated} />
      </div>
    </div>
  );
}
