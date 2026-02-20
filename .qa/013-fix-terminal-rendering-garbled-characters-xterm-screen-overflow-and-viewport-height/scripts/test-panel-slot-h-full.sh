#!/bin/bash
if grep -q 'h-full flex flex-col' src/app/components/panels/panel-slot.tsx; then
  echo "PASS: h-full added to PanelSlot root"
  exit 0
else
  echo "FAIL: h-full missing"
  exit 1
fi
