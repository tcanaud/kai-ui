"use client";

import type { PanelProps, PanelType } from "@/app/lib/types";
import { Terminal, Code, BookOpen, MessageSquare, Bot } from "lucide-react";

const panelIcons: Record<PanelType, React.ComponentType<{ className?: string }>> = {
  terminal: Terminal,
  editor: Code,
  playbook: BookOpen,
  chat: MessageSquare,
  assistant: Bot,
};

const panelLabels: Record<PanelType, string> = {
  terminal: "Terminal",
  editor: "Code Editor",
  playbook: "Playbook Dashboard",
  chat: "AI Chat",
  assistant: "AI Assistant",
};

interface PanelSlotProps extends PanelProps {
  type: PanelType;
  children: React.ReactNode;
}

export function PanelSlot({ type, isActive, children }: PanelSlotProps) {
  const Icon = panelIcons[type];
  const label = panelLabels[type];

  return (
    <div
      className={`flex flex-col rounded-lg border bg-card overflow-hidden transition-shadow ${
        isActive ? "border-glow-cyan" : "border-border"
      }`}
    >
      <div className="flex items-center gap-2 px-3 py-2 border-b border-border bg-secondary/50">
        <Icon className="h-4 w-4 text-neon-cyan" />
        <span className="text-xs font-mono text-muted-foreground uppercase tracking-wider">
          {label}
        </span>
      </div>
      <div className="flex-1 p-4 overflow-auto">{children}</div>
    </div>
  );
}
