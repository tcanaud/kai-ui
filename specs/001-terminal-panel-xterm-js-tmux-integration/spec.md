# Feature Specification: Terminal Panel — xterm.js + tmux Integration

**Feature Branch**: `001-terminal-panel-xterm-js-tmux-integration`
**Created**: 2026-02-20
**Status**: Draft
**Input**: User description: "Replace the terminal placeholder with a functional xterm.js terminal embedded in the panel. Connect to the session's worktree tmux session for persistent terminal state. Scope: Embed xterm.js in the terminal panel slot, Connect to worktree tmux session via WebSocket backend, Support copy/paste scrollback theming (cyberpunk palette), Auto-attach to existing tmux session on panel load, Handle terminal resize when panel is resized."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Interactive Terminal in Panel (Priority: P1)

As a developer using the kai UI, I want to see a fully interactive terminal in the terminal panel slot so that I can run commands directly within the workspace without switching to an external terminal application. When I open or navigate to a session, the terminal panel displays a live shell prompt instead of the current placeholder graphic, and I can type commands, see output, and interact with the shell normally.

**Why this priority**: This is the foundational capability. Without an embedded terminal rendering real shell I/O, none of the other stories (persistence, theming, resize) have meaning. A working terminal alone already replaces the placeholder and delivers immediate value.

**Independent Test**: Can be fully tested by opening a session, verifying the terminal panel renders a shell prompt, typing a command (e.g., `ls`), and confirming output appears. Delivers the core value of an in-app terminal.

**Acceptance Scenarios**:

1. **Given** a session is loaded in the UI, **When** the terminal panel renders, **Then** a live terminal with a shell prompt is displayed in the panel slot (replacing the placeholder).
2. **Given** the terminal panel is displayed, **When** the user types a command and presses Enter, **Then** the command executes and output is displayed in the terminal.
3. **Given** the terminal panel is displayed, **When** the user runs an interactive program (e.g., `top`, `vim`), **Then** the terminal correctly handles interactive/full-screen TUI rendering.

---

### User Story 2 - Persistent Terminal via tmux Session (Priority: P1)

As a developer, I want the terminal to connect to the session's worktree tmux session so that my terminal state (running processes, command history, open programs) persists across page reloads and reconnections. If I navigate away and come back, or refresh the browser, I see exactly the same terminal state I left.

**Why this priority**: Persistence is critical for a real development workflow. Without it, every navigation or refresh kills running processes and loses context, making the terminal unreliable for actual work.

**Independent Test**: Can be tested by running a long-running command (e.g., `sleep 300`), refreshing the page, and verifying the command is still running and visible in the terminal upon reconnection.

**Acceptance Scenarios**:

1. **Given** a session with an existing tmux session, **When** the terminal panel loads, **Then** it automatically attaches to the existing tmux session showing previous state.
2. **Given** a session without an existing tmux session, **When** the terminal panel loads for the first time, **Then** a new tmux session is created and attached.
3. **Given** the user is connected to a tmux session, **When** the user refreshes the browser or navigates away and returns, **Then** the terminal reconnects to the same tmux session with all state preserved (running processes, scrollback, working directory).
4. **Given** the WebSocket connection drops unexpectedly, **When** the connection is restored, **Then** the terminal re-attaches to the tmux session automatically without user intervention.

---

### User Story 3 - Copy, Paste, and Scrollback (Priority: P2)

As a developer, I want to be able to copy text from the terminal, paste text into the terminal, and scroll back through previous output so that I can work with terminal content efficiently just like in a native terminal application.

**Why this priority**: Copy/paste and scrollback are essential usability features for any terminal. Without them the terminal is functional but frustrating to use for real work.

**Independent Test**: Can be tested by running a command that produces long output, scrolling up to review it, selecting text and copying it, and pasting external text into the terminal.

**Acceptance Scenarios**:

1. **Given** the terminal has output exceeding the visible area, **When** the user scrolls up (mouse wheel or keyboard), **Then** previous output is visible and the user can scroll through the full scrollback buffer.
2. **Given** text is visible in the terminal, **When** the user selects text and triggers copy (Ctrl/Cmd+C or right-click context), **Then** the selected text is placed on the system clipboard.
3. **Given** text is on the system clipboard, **When** the user triggers paste (Ctrl/Cmd+V or right-click context), **Then** the clipboard content is inserted into the terminal at the cursor position.

---

### User Story 4 - Cyberpunk-Themed Terminal (Priority: P2)

As a developer, I want the terminal to use the existing cyberpunk color palette (neon cyan, violet, dark backgrounds) consistent with the rest of the kai UI so that the terminal feels native to the application rather than a foreign embed.

**Why this priority**: Visual consistency with the existing UI matters for product quality, but the terminal is usable without custom theming. This can ship independently once the terminal renders.

**Independent Test**: Can be tested by visually inspecting the terminal and comparing its colors (background, foreground, cursor, ANSI colors) against the kai UI design tokens and surrounding panel styling.

**Acceptance Scenarios**:

1. **Given** the terminal panel is displayed, **When** the user views the terminal, **Then** the terminal background, foreground, and cursor colors match the kai cyberpunk palette.
2. **Given** the terminal displays colored output (e.g., `ls --color`, git diff), **When** ANSI colors are rendered, **Then** they map to the cyberpunk palette variants (neon cyan, neon violet, etc.) rather than default xterm colors.
3. **Given** the terminal is embedded in the panel slot, **When** viewed alongside other panels, **Then** the terminal visually integrates with the panel header bar, borders, and surrounding UI elements.

---

### User Story 5 - Terminal Resizes with Panel (Priority: P2)

As a developer, I want the terminal to resize correctly when the panel dimensions change (e.g., browser resize, panel drag-to-resize) so that the terminal always fills its available space and programs that depend on terminal dimensions (like `vim`, `htop`) render correctly.

**Why this priority**: Resize handling prevents broken layouts and garbled TUI applications. It is essential for a polished experience but the terminal is still minimally usable at a fixed size.

**Independent Test**: Can be tested by resizing the browser window, verifying the terminal content reflows, and confirming that a full-screen TUI application (e.g., `htop`) renders correctly at the new dimensions.

**Acceptance Scenarios**:

1. **Given** the terminal panel is displayed, **When** the browser window is resized, **Then** the terminal adjusts its column and row count to fill the panel and notifies the backend of the new dimensions.
2. **Given** a full-screen TUI application is running (e.g., `vim`), **When** the panel is resized, **Then** the TUI application re-renders correctly at the new dimensions without artifacts.
3. **Given** the panel is in the mobile layout (stacked panels), **When** the terminal panel expands or collapses, **Then** the terminal dimensions update accordingly.

---

### Edge Cases

- What happens when the tmux server is not running or tmux is not installed on the backend host? The system should display a clear error message in the terminal panel indicating the dependency is unavailable.
- What happens when two browser tabs open the same session simultaneously? Both should attach to the same tmux session and see synchronized output (tmux natively supports this).
- What happens when the WebSocket connection fails on initial load? The terminal panel should display a connection error with a retry button rather than a blank or broken state.
- What happens when the user resizes the panel very quickly in succession? The system should debounce resize events to avoid flooding the backend with dimension updates.
- What happens when the user pastes a very large block of text (e.g., 10,000+ characters)? The paste should be handled gracefully, ideally using bracketed paste mode to avoid line-by-line execution.
- What happens when the session's worktree directory no longer exists on disk? The terminal should start in a fallback directory (e.g., home) and display a warning.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST replace the terminal placeholder component with a functional terminal emulator in the terminal panel slot.
- **FR-002**: System MUST connect the terminal emulator to the session's worktree tmux session via a real-time bidirectional communication channel.
- **FR-003**: System MUST automatically attach to an existing tmux session when the terminal panel loads, if one already exists for the session.
- **FR-004**: System MUST create a new tmux session (with the working directory set to the session's worktree) when no existing tmux session is found.
- **FR-005**: System MUST preserve terminal state (running processes, scrollback, working directory) across page reloads and reconnections.
- **FR-006**: System MUST support text selection and copy-to-clipboard from terminal output.
- **FR-007**: System MUST support paste-from-clipboard into the terminal input.
- **FR-008**: System MUST provide scrollback buffer allowing users to scroll through previous terminal output.
- **FR-009**: System MUST apply a cyberpunk color theme (matching the existing kai UI palette: neon cyan, neon violet, dark backgrounds) to the terminal.
- **FR-010**: System MUST map ANSI color codes to cyberpunk palette variants for consistent visual styling.
- **FR-011**: System MUST dynamically resize the terminal (columns and rows) when the panel dimensions change and communicate the new dimensions to the backend.
- **FR-012**: System MUST debounce resize events to prevent excessive backend communication during rapid panel resizing.
- **FR-013**: System MUST display a clear error state in the terminal panel when the backend connection cannot be established, with an option to retry.
- **FR-014**: System MUST automatically attempt to reconnect when the communication channel drops unexpectedly.
- **FR-015**: System MUST support bracketed paste mode for safe handling of multi-line paste operations.

### Key Entities

- **Terminal Session**: Represents the connection between the UI terminal panel and a backend tmux session. Key attributes: session identifier, associated worktree path, connection state (connecting, connected, disconnected, error), terminal dimensions (columns, rows).
- **tmux Session**: A server-side persistent terminal multiplexer session scoped to a worktree. Key attributes: session name (derived from session ID), working directory, creation time, attached client count.
- **Terminal Theme**: The color configuration applied to the terminal emulator. Key attributes: background color, foreground color, cursor color, selection color, ANSI color map (16 standard colors mapped to cyberpunk palette).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can execute shell commands in the terminal panel and see output within 1 second of pressing Enter (under normal conditions).
- **SC-002**: Terminal state survives a full page refresh 100% of the time when the backend tmux session is healthy.
- **SC-003**: The terminal first renders a usable shell prompt within 3 seconds of the panel becoming visible.
- **SC-004**: Users can copy text from the terminal and paste it into an external application, and vice versa, on all supported browsers.
- **SC-005**: Full-screen TUI applications (e.g., vim, htop) render correctly after a panel resize event, with no visual artifacts.
- **SC-006**: The terminal panel visually matches the kai cyberpunk design system, passing visual review by the design owner.
- **SC-007**: The terminal gracefully handles connection failures by showing an actionable error state (not a blank panel) within 5 seconds of detecting a connection issue.
