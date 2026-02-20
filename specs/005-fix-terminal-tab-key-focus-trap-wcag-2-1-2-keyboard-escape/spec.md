# Spec: Fix Terminal Tab Key Focus Trap — WCAG 2.1.2 Keyboard Escape

**Feature**: 005-fix-terminal-tab-key-focus-trap-wcag-2-1-2-keyboard-escape
**Status**: hotfix
**Created**: 2026-02-20

## Problem

The xterm.js terminal component intercepted all keyboard events including Tab and Shift+Tab, creating a keyboard focus trap. Users navigating with a keyboard could not escape the terminal once focused, violating WCAG 2.1 Success Criterion 2.1.2 (No Keyboard Trap).

## Fix

A custom key event handler is attached to the xterm terminal instance via `term.attachCustomKeyEventHandler`. When the user presses Tab or Shift+Tab (without Alt, Ctrl, or Meta modifiers), the handler returns `false`, allowing the browser's native focus management to move focus to the next or previous focusable element. All other keys continue to be handled by xterm as terminal input.

---

## User Story 1 — Tab key escapes terminal focus

**As a** keyboard-only user,
**I want** pressing Tab while the terminal is focused to move focus to the next interactive element,
**So that** I am not trapped inside the terminal widget.

### US1.AC1

Given the terminal is focused (the xterm canvas has browser focus),
When the user presses the Tab key (no modifier keys),
Then browser focus moves to the next focusable element outside the terminal,
And the terminal does not process Tab as a terminal input character.

### US1.AC2

Given the terminal is focused,
When the user presses Shift+Tab,
Then browser focus moves to the previous focusable element,
And the terminal does not process Shift+Tab as a terminal input character.

### US1.AC3

Given the terminal is focused,
When the user presses Tab with Alt, Ctrl, or Meta held down,
Then xterm processes the key normally as terminal input (the custom handler returns true),
And browser focus does NOT move away from the terminal.

---

## User Story 2 — Surrounding terminal functionality remains intact

**As a** developer using the terminal,
**I want** normal typing and terminal interactions to be unaffected by the Tab-key fix,
**So that** the hotfix does not regress core terminal behaviour.

### US2.AC1

Given the terminal is connected and focused,
When the user types regular characters (letters, numbers, Enter, arrow keys),
Then input is sent to the PTY and the terminal responds normally.

### US2.AC2

Given the terminal is focused,
When the user presses Ctrl+C,
Then the interrupt signal is sent to the PTY (xterm processes it, not the browser).
