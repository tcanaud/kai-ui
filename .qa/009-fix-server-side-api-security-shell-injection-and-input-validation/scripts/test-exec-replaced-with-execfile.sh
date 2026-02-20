#!/bin/bash
# Verify exec() is replaced with execFile()
FILE="src/app/api/sessions/route.ts"
if grep -q 'import.*execFile.*from.*node:child_process' "$FILE" && ! grep -q '`npx.*\${' "$FILE"; then
  echo "PASS: execFile used, no string interpolation"
  exit 0
else
  echo "FAIL: exec with string interpolation still present"
  exit 1
fi
