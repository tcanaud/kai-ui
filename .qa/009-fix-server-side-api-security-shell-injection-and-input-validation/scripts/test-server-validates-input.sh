#!/bin/bash
# Verify server-side validation exists
FILE="src/app/api/sessions/route.ts"
if grep -q 'SAFE_NAME_PATTERN' "$FILE" && grep -q 'MAX_NAME_LENGTH' "$FILE"; then
  echo "PASS: Server-side validation constants present"
  exit 0
else
  echo "FAIL: Missing server-side validation"
  exit 1
fi
