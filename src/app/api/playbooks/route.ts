import { NextResponse } from "next/server";
import { readdir, readFile } from "node:fs/promises";
import { join } from "node:path";
import { existsSync } from "node:fs";

const projectRoot = process.env.KAI_PROJECT_ROOT || process.cwd();
const playbooksDir = join(projectRoot, ".playbooks", "playbooks");

function extractFrontmatter(content: string): Record<string, string> {
  const result: Record<string, string> = {};
  const match = content.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return result;
  for (const line of match[1].split("\n")) {
    const kv = line.match(/^(\w[\w-]*):\s*["']?(.+?)["']?\s*$/);
    if (kv) result[kv[1]] = kv[2];
  }
  return result;
}

export async function GET() {
  try {
    if (!existsSync(playbooksDir)) {
      return NextResponse.json({ playbooks: [] });
    }

    const entries = await readdir(playbooksDir);
    const playbooks = [];

    for (const entry of entries) {
      if (!entry.endsWith(".yaml") && !entry.endsWith(".yml")) continue;
      if (entry.startsWith("_")) continue;
      const name = entry.replace(/\.ya?ml$/, "");
      if (name.endsWith(".tpl") || name.endsWith("-old")) continue;
      const content = await readFile(join(playbooksDir, entry), "utf-8");
      const data = extractFrontmatter(content);

      playbooks.push({
        name,
        title: data.title || name,
        description: data.description || "",
      });
    }

    return NextResponse.json({ playbooks });
  } catch (error) {
    return NextResponse.json(
      { error: "Failed to read playbooks", details: String(error) },
      { status: 500 }
    );
  }
}
