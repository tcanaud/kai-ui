#!/usr/bin/env node
import { existsSync } from "node:fs";
import { resolve } from "node:path";
import { spawn, exec } from "node:child_process";
import { platform } from "node:os";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const projectRoot = process.cwd();

// Validate kai project root
if (!existsSync(resolve(projectRoot, ".features"))) {
  console.error(
    "\x1b[31mError:\x1b[0m Not a kai-enabled project root."
  );
  console.error(
    "Expected to find a .features/ directory in the current directory."
  );
  console.error(`\nCurrent directory: ${projectRoot}`);
  console.error("\nRun this command from a kai project root.");
  process.exit(1);
}

const packageDir = join(__dirname, "..");

console.log("\x1b[36m⚡ kai ui\x1b[0m starting...");

// Start Next.js dev server
const next = spawn("npx", ["next", "dev"], {
  cwd: packageDir,
  stdio: "inherit",
  env: {
    ...process.env,
    KAI_PROJECT_ROOT: projectRoot,
  },
});

// Open browser after a short delay
setTimeout(() => {
  const url = "http://localhost:3000";
  const cmd =
    platform() === "darwin"
      ? `open "${url}"`
      : platform() === "win32"
        ? `start "${url}"`
        : `xdg-open "${url}"`;

  exec(cmd, (err) => {
    if (err) {
      console.log(`\n  Open \x1b[36m${url}\x1b[0m in your browser`);
    }
  });
}, 3000);

next.on("close", (code) => {
  process.exit(code ?? 0);
});

process.on("SIGINT", () => {
  next.kill("SIGINT");
});
