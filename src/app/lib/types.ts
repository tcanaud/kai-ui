export type PanelType = "terminal" | "editor" | "playbook" | "chat" | "assistant";

export interface PanelProps {
  sessionId: string;
  isActive: boolean;
}

export interface Session {
  id: string;
  name: string;
  playbook: string;
  feature: string;
  createdAt: string;
  status: string;
  worktreePath: string;
}

export interface Playbook {
  name: string;
  title: string;
  description: string;
}
