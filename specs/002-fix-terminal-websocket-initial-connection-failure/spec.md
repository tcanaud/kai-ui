# Feature Specification: Fix Terminal WebSocket Initial Connection Failure

**Feature Branch**: `001-fix-ws-initial-connect`
**Created**: 2026-02-20
**Status**: Draft
**Input**: User description: "Feature 002-fix-terminal-websocket-initial-connection-failure — Fix terminal WebSocket initial connection failure. The terminal panel displays 'Disconnected. Reconnecting...' on initial page load even when the sidecar WebSocket server at port 3001 is healthy. Root cause hypotheses: Session ID mismatch between Next.js render and WebSocket connection attempt; missing session context in URL; timing issue where WebSocket connection is attempted before session is established on sidecar. Acceptance criteria: (1) Navigating to localhost:3000 with running sidecar displays live terminal with shell prompt, (2) 'Disconnected. Reconnecting...' state not shown when sidecar is healthy, (3) WebSocket connection completes on initial page load without manual refresh."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - First-Time Terminal Load (Priority: P1)

A developer opens the application in their browser for the first time with the sidecar already running. They expect to see a live terminal prompt immediately — without any error state and without needing to refresh the page.

**Why this priority**: This is the core broken experience. Every user who opens the application hits this failure immediately. It is the primary symptom of the bug and fixing it delivers the full value of the terminal panel.

**Independent Test**: Can be fully tested by opening a browser to the app URL with the sidecar running and verifying that a shell prompt appears in the terminal panel without any intermediate error message.

**Acceptance Scenarios**:

1. **Given** the sidecar server is running and healthy, **When** a user navigates to the application URL in their browser, **Then** the terminal panel displays a live shell prompt within 3 seconds of the page becoming interactive.
2. **Given** the sidecar server is running and healthy, **When** a user navigates to the application URL, **Then** the "Disconnected. Reconnecting..." overlay is never displayed during the initial connection sequence.
3. **Given** the sidecar server is running and a session is pre-selected on load, **When** the terminal panel mounts, **Then** the WebSocket connection is established successfully on the first attempt without falling into the reconnection loop.

---

### User Story 2 - Stable Connection After Sidecar Restart (Priority: P2)

A developer whose connection was temporarily interrupted (e.g., sidecar restarted) sees the terminal recover cleanly and return to a live prompt again, without needing a page reload.

**Why this priority**: The reconnection behavior already exists and is partially functional. Ensuring it works correctly after the initial connection bug is fixed prevents regression and validates the fix is holistic.

**Independent Test**: Can be tested by starting the app, confirming the terminal connects, restarting the sidecar, and observing the terminal reconnects automatically and shows a live prompt.

**Acceptance Scenarios**:

1. **Given** the terminal is connected and the sidecar is restarted, **When** the sidecar becomes available again, **Then** the terminal reconnects and displays a live shell prompt without requiring a page reload.
2. **Given** a reconnection attempt is in progress, **When** the sidecar is not yet available, **Then** the "Connection lost. Retrying..." message is shown — not "Disconnected. Reconnecting..." — to clearly distinguish from an initial connection failure.

---

### User Story 3 - Accurate Connection Status Messages (Priority: P3)

A developer working in the application never sees a misleading status message. The overlay always accurately reflects what is actually happening with the connection.

**Why this priority**: A false or misleading connection state erodes trust in the application. This story ensures status messages are always semantically correct.

**Independent Test**: Can be tested by observing the connection overlay across three scenarios: initial load, sidecar restart, and sidecar unavailable — confirming the correct message appears in each case.

**Acceptance Scenarios**:

1. **Given** the terminal is making its initial connection, **When** the connection has not yet succeeded, **Then** "Connecting..." is shown.
2. **Given** the terminal was connected and the connection dropped, **When** a reconnection attempt is in progress, **Then** "Connection lost. Retrying..." is shown.
3. **Given** all reconnection attempts have failed, **When** the retry limit is reached, **Then** "Connection failed." is shown with a Retry button.

---

### Edge Cases

- What happens when the sidecar is not running at all when the app is opened? The terminal should show "Connection failed." with a Retry button after exhausting retries, not an indefinite reconnecting loop.
- What happens when a session ID is not yet resolved at the time the terminal panel mounts? The terminal must wait until a valid session ID is available before attempting any connection.
- What happens if the session list is empty on first load? No terminal connection should be attempted and no error state should be shown — only the empty state prompting the user to create a session.
- What happens when the browser tab is backgrounded and then brought back? The connection should remain stable or gracefully recover without showing a false disconnected state.
- What happens if the worktree path is missing from the session data? The terminal should not attempt to connect and should show an appropriate error state.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The terminal panel MUST NOT attempt a WebSocket connection until a valid session ID is fully resolved and available from the session data.
- **FR-002**: The terminal panel MUST NOT display "Disconnected. Reconnecting..." during an initial connection attempt — this state is reserved for connections that previously succeeded and then dropped.
- **FR-003**: The terminal panel MUST establish a WebSocket connection successfully on the first attempt when the sidecar is healthy and a valid session ID is present.
- **FR-004**: The terminal panel MUST show "Connecting..." during the initial connection phase, before any connection for this session has ever succeeded.
- **FR-005**: The terminal panel MUST show "Connection lost. Retrying..." only when reconnecting after a previously successful connection drops.
- **FR-006**: The terminal panel MUST show "Connection failed." with a Retry button only when the maximum number of reconnection attempts has been exhausted.
- **FR-007**: When no sessions exist, the terminal panel MUST NOT be rendered and MUST NOT attempt any WebSocket connection.
- **FR-008**: The terminal panel MUST successfully connect when the sidecar is healthy, regardless of whether session data was loaded synchronously or asynchronously on page load.
- **FR-009**: The connection status displayed to the user MUST accurately reflect the actual connection lifecycle at all times.

### Key Entities

- **Session**: Represents a user's active work context. Has a unique identifier and an associated worktree path. A valid session must exist and be resolved before any terminal connection is attempted.
- **WebSocket Connection**: The channel between the browser terminal panel and the sidecar server. Has a defined lifecycle: idle → connecting → connected → (disconnected → reconnecting)* → error.
- **Sidecar Server**: The local background process that manages terminal sessions. Considered healthy when it accepts WebSocket connections on the expected port.
- **Connection State**: The current status of the WebSocket link. Drives what overlay message (if any) the user sees in the terminal panel.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: When the sidecar is running and healthy, the terminal panel displays a live shell prompt within 3 seconds of the page becoming fully interactive, 100% of the time.
- **SC-002**: The "Disconnected. Reconnecting..." overlay is never displayed during an initial connection sequence when the sidecar is healthy.
- **SC-003**: Users never need to manually refresh the page to establish the initial terminal connection when the sidecar is available.
- **SC-004**: Connection status messages are accurate 100% of the time — the correct overlay is shown for the correct situation (connecting vs. reconnecting vs. failed).
- **SC-005**: After a sidecar restart, the terminal automatically recovers and shows a live prompt with no page reload required.

## Assumptions

- The sidecar server is a prerequisite that the user starts separately before opening the application. The application does not start the sidecar automatically.
- A session must already exist (created by the user or pre-loaded from disk) before a terminal connection can be established. The fix does not need to auto-create sessions.
- The session ID is derived from server-side data fetched via an API call on page load. The race condition between this async fetch and the terminal panel mounting is a key area to address.
- The WebSocket URL format is correct and does not need to change — only the connection timing and state management logic needs to be fixed.
- The fix should not alter the reconnection retry logic or retry limits — only the initial connection sequencing and connection state labeling.
- "Healthy sidecar" means the sidecar process is running and accepting WebSocket connections on the expected local port.
