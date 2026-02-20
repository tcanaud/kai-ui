"use client";

import { useState, useEffect, useCallback } from "react";
import type { Session } from "@/app/lib/types";
import { fetchSessions } from "@/app/lib/sessions";
import { ResponsiveShell } from "./components/layout/responsive-shell";
import { PanelLayout } from "./components/panels/panel-layout";
import { Zap } from "lucide-react";

function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(false);
  useEffect(() => {
    const mql = window.matchMedia(query);
    setMatches(mql.matches);
    const handler = (e: MediaQueryListEvent) => setMatches(e.matches);
    mql.addEventListener("change", handler);
    return () => mql.removeEventListener("change", handler);
  }, [query]);
  return matches;
}

export default function Home() {
  const [sessions, setSessions] = useState<Session[]>([]);
  const [activeSessionId, setActiveSessionId] = useState<string | null>(null);
  const isMobile = useMediaQuery("(max-width: 1023px)");

  const loadSessions = useCallback(async () => {
    try {
      const data = await fetchSessions();
      setSessions(data);
      if (data.length > 0 && !activeSessionId) {
        setActiveSessionId(data[0].id);
      }
    } catch {
      // Sessions dir may not exist yet
    }
  }, [activeSessionId]);

  useEffect(() => {
    loadSessions();
  }, [loadSessions]);

  const activeSession = sessions.find((s) => s.id === activeSessionId);

  return (
    <ResponsiveShell
      sessions={sessions}
      activeSessionId={activeSessionId}
      onSessionSelect={setActiveSessionId}
      onSessionCreated={loadSessions}
    >
      {activeSession ? (
        <PanelLayout sessionId={activeSession.id} worktreePath={activeSession.worktreePath} isMobile={isMobile} />
      ) : (
        <div className="flex flex-col items-center justify-center h-full gap-6">
          <div className="relative">
            <Zap className="h-16 w-16 text-neon-cyan glow-cyan-strong" />
          </div>
          <div className="text-center">
            <h2 className="text-2xl font-mono font-bold text-neon-cyan text-glow-cyan mb-2">
              kai ui
            </h2>
            <p className="text-muted-foreground text-sm max-w-md">
              Select a session from the sidebar or create a new one to get started.
            </p>
          </div>
        </div>
      )}
    </ResponsiveShell>
  );
}
