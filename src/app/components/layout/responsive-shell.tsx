"use client";

import type { Session } from "@/app/lib/types";
import { SessionSidebar } from "../sidebar/session-sidebar";
import { MobileNav } from "./mobile-nav";

interface ResponsiveShellProps {
  sessions: Session[];
  activeSessionId: string | null;
  onSessionSelect: (id: string) => void;
  onSessionCreated: () => void;
  children: React.ReactNode;
}

export function ResponsiveShell({
  sessions,
  activeSessionId,
  onSessionSelect,
  onSessionCreated,
  children,
}: ResponsiveShellProps) {
  return (
    <div className="flex h-screen overflow-hidden">
      {/* Desktop sidebar */}
      <div className="hidden lg:flex lg:w-72 lg:flex-shrink-0 border-r border-border">
        <SessionSidebar
          sessions={sessions}
          activeSessionId={activeSessionId}
          onSessionSelect={onSessionSelect}
          onSessionCreated={onSessionCreated}
        />
      </div>

      {/* Mobile hamburger */}
      <MobileNav
        sessions={sessions}
        activeSessionId={activeSessionId}
        onSessionSelect={onSessionSelect}
        onSessionCreated={onSessionCreated}
      />

      {/* Main content */}
      <main id="main-content" className="flex-1 overflow-auto">{children}</main>
    </div>
  );
}
