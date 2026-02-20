"use client";

import { useState, useCallback } from "react";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { Menu } from "lucide-react";
import type { Session } from "@/app/lib/types";
import { SessionSidebar } from "../sidebar/session-sidebar";

interface MobileNavProps {
  sessions: Session[];
  activeSessionId: string | null;
  onSessionSelect: (id: string) => void;
  onSessionCreated: () => void;
}

export function MobileNav({
  sessions,
  activeSessionId,
  onSessionSelect,
  onSessionCreated,
}: MobileNavProps) {
  const [open, setOpen] = useState(false);

  const handleSessionSelect = useCallback(
    (id: string) => {
      setOpen(false);
      onSessionSelect(id);
    },
    [onSessionSelect]
  );

  const handleCloseSheet = useCallback(() => {
    setOpen(false);
  }, []);

  return (
    <Sheet open={open} onOpenChange={setOpen}>
      <SheetTrigger asChild>
        <Button
          variant="ghost"
          size="icon"
          className="lg:hidden fixed top-3 left-3 z-50 bg-card/80 backdrop-blur border border-border glow-cyan"
        >
          <Menu className="h-5 w-5 text-neon-cyan" />
        </Button>
      </SheetTrigger>
      <SheetContent side="left" className="w-72 p-0 bg-sidebar border-sidebar-border">
        <SessionSidebar
          sessions={sessions}
          activeSessionId={activeSessionId}
          onSessionSelect={handleSessionSelect}
          onSessionCreated={onSessionCreated}
          onNavigate={handleCloseSheet}
        />
      </SheetContent>
    </Sheet>
  );
}
