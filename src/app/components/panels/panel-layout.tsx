"use client";

import { useState, useCallback, type KeyboardEvent } from "react";
import { TerminalPanel } from "./terminal-panel";
import { EditorPlaceholder } from "./editor-placeholder";
import { PlaybookPlaceholder } from "./playbook-placeholder";
import { ChatPlaceholder } from "./chat-placeholder";
import { AssistantPlaceholder } from "./assistant-placeholder";

interface PanelLayoutProps {
  sessionId: string;
  worktreePath?: string;
  isMobile?: boolean;
}

const PANEL_LABELS: Record<string, string> = {
  terminal: "Terminal",
  editor: "Editor",
  playbook: "Playbook",
  chat: "Chat",
  assistant: "Assistant",
};

export function PanelLayout({ sessionId, worktreePath = "", isMobile = false }: PanelLayoutProps) {
  const [activePanel, setActivePanel] = useState<string | null>(null);

  const handlePanelClick = useCallback((panelId: string) => {
    setActivePanel((prev) => (prev === panelId ? null : panelId));
  }, []);

  const handlePanelKeyDown = useCallback(
    (panelId: string, e: KeyboardEvent) => {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        handlePanelClick(panelId);
      }
    },
    [handlePanelClick]
  );

  const panelProps = (panelId: string, extraClassName?: string) => {
    const isTerminal = panelId === "terminal";
    return {
      ...(isTerminal ? {} : { role: "button" as const, tabIndex: 0 }),
      "aria-label": `${PANEL_LABELS[panelId]} panel`,
      "aria-pressed": activePanel === panelId,
      onClick: () => handlePanelClick(panelId),
      onKeyDown: isTerminal ? undefined : (e: KeyboardEvent<HTMLDivElement>) => handlePanelKeyDown(panelId, e),
      className: `${extraClassName ?? ""} focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white focus-visible:ring-offset-1 focus-visible:ring-offset-background rounded-md cursor-pointer`.trim(),
    };
  };

  if (isMobile) {
    return (
      <div className="flex flex-col gap-3 p-3">
        <div {...panelProps("terminal")}>
          <TerminalPanel sessionId={sessionId} isActive={activePanel === "terminal"} worktreePath={worktreePath} />
        </div>
        <div {...panelProps("editor")}>
          <EditorPlaceholder sessionId={sessionId} isActive={activePanel === "editor"} />
        </div>
        <div {...panelProps("playbook")}>
          <PlaybookPlaceholder sessionId={sessionId} isActive={activePanel === "playbook"} />
        </div>
        <div {...panelProps("chat")}>
          <ChatPlaceholder sessionId={sessionId} isActive={activePanel === "chat"} />
        </div>
        <div {...panelProps("assistant")}>
          <AssistantPlaceholder sessionId={sessionId} isActive={activePanel === "assistant"} />
        </div>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-3 grid-rows-2 gap-3 p-4 h-full">
      {/* Top row: Terminal (large) + Editor */}
      <div {...panelProps("terminal", "col-span-2 row-span-1")}>
        <TerminalPanel sessionId={sessionId} isActive={activePanel === "terminal"} worktreePath={worktreePath} />
      </div>
      <div {...panelProps("editor", "col-span-1 row-span-1")}>
        <EditorPlaceholder sessionId={sessionId} isActive={activePanel === "editor"} />
      </div>
      {/* Bottom row: Playbook + Chat + Assistant */}
      <div {...panelProps("playbook")}>
        <PlaybookPlaceholder sessionId={sessionId} isActive={activePanel === "playbook"} />
      </div>
      <div {...panelProps("chat")}>
        <ChatPlaceholder sessionId={sessionId} isActive={activePanel === "chat"} />
      </div>
      <div {...panelProps("assistant")}>
        <AssistantPlaceholder sessionId={sessionId} isActive={activePanel === "assistant"} />
      </div>
    </div>
  );
}
