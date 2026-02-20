import type { Session, Playbook } from "./types";

export async function fetchSessions(): Promise<Session[]> {
  const res = await fetch("/api/sessions");
  if (!res.ok) throw new Error("Failed to fetch sessions");
  const data = await res.json();
  return data.sessions;
}

export async function createSession(
  playbook: string,
  feature: string,
  signal?: AbortSignal
): Promise<{ session: Session; output: string }> {
  const res = await fetch("/api/sessions", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ playbook, feature }),
    signal,
  });
  if (!res.ok) {
    const data = await res.json();
    throw new Error(data.details || data.error || "Failed to create session");
  }
  return res.json();
}

export async function fetchPlaybooks(): Promise<Playbook[]> {
  const res = await fetch("/api/playbooks");
  if (!res.ok) throw new Error("Failed to fetch playbooks");
  const data = await res.json();
  return data.playbooks;
}
