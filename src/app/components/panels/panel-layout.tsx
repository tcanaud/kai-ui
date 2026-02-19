"use client";

import { useState, useCallback } from "react";
import { TerminalPlaceholder } from "./terminal-placeholder";
import { EditorPlaceholder } from "./editor-placeholder";
import { PlaybookPlaceholder } from "./playbook-placeholder";
import { ChatPlaceholder } from "./chat-placeholder";
import { AssistantPlaceholder } from "./assistant-placeholder";

interface PanelLayoutProps {
  sessionId: string;
  isMobile?: boolean;
}

export function PanelLayout({ sessionId, isMobile = false }: PanelLayoutProps) {
  const [activePanel, setActivePanel] = useState<string | null>(null);

  const handlePanelClick = useCallback((panelId: string) => {
    setActivePanel((prev) => (prev === panelId ? null : panelId));
  }, []);

  if (isMobile) {
    return (
      <div className="flex flex-col gap-3 p-3">
        <div onClick={() => handlePanelClick("terminal")}>
          <TerminalPlaceholder sessionId={sessionId} isActive={activePanel === "terminal"} />
        </div>
        <div onClick={() => handlePanelClick("editor")}>
          <EditorPlaceholder sessionId={sessionId} isActive={activePanel === "editor"} />
        </div>
        <div onClick={() => handlePanelClick("playbook")}>
          <PlaybookPlaceholder sessionId={sessionId} isActive={activePanel === "playbook"} />
        </div>
        <div onClick={() => handlePanelClick("chat")}>
          <ChatPlaceholder sessionId={sessionId} isActive={activePanel === "chat"} />
        </div>
        <div onClick={() => handlePanelClick("assistant")}>
          <AssistantPlaceholder sessionId={sessionId} isActive={activePanel === "assistant"} />
        </div>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-3 grid-rows-2 gap-3 p-4 h-full">
      {/* Top row: Terminal (large) + Editor */}
      <div className="col-span-2 row-span-1" onClick={() => handlePanelClick("terminal")}>
        <TerminalPlaceholder sessionId={sessionId} isActive={activePanel === "terminal"} />
      </div>
      <div className="col-span-1 row-span-1" onClick={() => handlePanelClick("editor")}>
        <EditorPlaceholder sessionId={sessionId} isActive={activePanel === "editor"} />
      </div>
      {/* Bottom row: Playbook + Chat + Assistant */}
      <div onClick={() => handlePanelClick("playbook")}>
        <PlaybookPlaceholder sessionId={sessionId} isActive={activePanel === "playbook"} />
      </div>
      <div onClick={() => handlePanelClick("chat")}>
        <ChatPlaceholder sessionId={sessionId} isActive={activePanel === "chat"} />
      </div>
      <div onClick={() => handlePanelClick("assistant")}>
        <AssistantPlaceholder sessionId={sessionId} isActive={activePanel === "assistant"} />
      </div>
    </div>
  );
}
