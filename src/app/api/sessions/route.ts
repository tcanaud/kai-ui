import { NextResponse } from "next/server";
import { readdir, readFile } from "node:fs/promises";
import { join } from "node:path";
import { existsSync } from "node:fs";
import { execFile } from "node:child_process";

const SAFE_NAME_PATTERN = /^[a-z0-9][a-z0-9-]*$/;
const MAX_NAME_LENGTH = 100;

const projectRoot = process.env.KAI_PROJECT_ROOT || process.cwd();
const sessionsDir = join(projectRoot, ".playbooks", "sessions");

function parseSimpleYaml(content: string): Record<string, string> {
  const result: Record<string, string> = {};
  for (const line of content.split("\n")) {
    const match = line.match(/^(\w[\w-]*):\s*["']?(.+?)["']?\s*$/);
    if (match) {
      result[match[1]] = match[2];
    }
  }
  return result;
}

export async function GET() {
  try {
    if (!existsSync(sessionsDir)) {
      return NextResponse.json({ sessions: [] });
    }

    const entries = await readdir(sessionsDir, { withFileTypes: true });
    const sessions = [];

    for (const entry of entries) {
      if (!entry.isDirectory()) continue;
      const sessionFile = join(sessionsDir, entry.name, "session.yaml");
      if (!existsSync(sessionFile)) continue;

      const content = await readFile(sessionFile, "utf-8");
      const data = parseSimpleYaml(content);

      sessions.push({
        id: entry.name,
        name: data.name || entry.name,
        playbook: data.playbook || "unknown",
        feature: data.feature || entry.name,
        createdAt: data.created || new Date().toISOString(),
        status: data.status || "active",
        worktreePath: data.worktree_path || "",
      });
    }

    return NextResponse.json({ sessions });
  } catch (error) {
    return NextResponse.json(
      { error: "Failed to read sessions", details: String(error) },
      { status: 500 }
    );
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { playbook, feature } = body;

    if (!playbook) {
      return NextResponse.json(
        { error: "Missing required field: playbook" },
        { status: 400 }
      );
    }
    if (!feature) {
      return NextResponse.json(
        { error: "Missing required field: feature" },
        { status: 400 }
      );
    }

    if (typeof playbook !== "string" || playbook.length > MAX_NAME_LENGTH || !SAFE_NAME_PATTERN.test(playbook)) {
      return NextResponse.json(
        { error: "Invalid playbook name. Must be lowercase alphanumeric with hyphens, max 100 chars." },
        { status: 400 }
      );
    }
    if (typeof feature !== "string" || feature.length > MAX_NAME_LENGTH || !SAFE_NAME_PATTERN.test(feature)) {
      return NextResponse.json(
        { error: "Invalid feature name. Must be lowercase alphanumeric with hyphens, max 100 chars." },
        { status: 400 }
      );
    }

    const result = await new Promise<{ stdout: string; stderr: string; code: number }>(
      (resolve) => {
        execFile(
          "npx",
          ["@tcanaud/playbook", "start", playbook, feature],
          { cwd: projectRoot },
          (error, stdout, stderr) => {
            resolve({
              stdout: stdout || "",
              stderr: stderr || "",
              code: error?.code ?? 0,
            });
          }
        );
      }
    );

    if (result.code !== 0) {
      return NextResponse.json(
        {
          error: "Session creation failed",
          details: result.stderr || result.stdout,
          exitCode: result.code,
        },
        { status: 500 }
      );
    }

    // Re-read sessions to find the newly created one
    const getResponse = await GET();
    const data = await getResponse.json();
    const newSession = data.sessions?.find(
      (s: { feature: string }) => s.feature === feature
    );

    return NextResponse.json(
      { session: newSession || { id: feature, name: feature, playbook, feature, createdAt: new Date().toISOString(), status: "active", worktreePath: "" }, output: result.stdout },
      { status: 201 }
    );
  } catch (error) {
    return NextResponse.json(
      { error: "Failed to create session", details: String(error) },
      { status: 500 }
    );
  }
}
