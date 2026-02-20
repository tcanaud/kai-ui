/**
 * Contract: useTerminal hook
 *
 * Feature: 002-fix-terminal-websocket-initial-connection-failure
 *
 * This file documents the behavioral contract of the `useTerminal` hook
 * after the fix is applied. It is not executable — it serves as a reference
 * for implementation and test authoring.
 */

/**
 * The set of states the terminal WebSocket connection can be in.
 *
 * State machine (post-fix):
 *
 *   idle → connecting → connected → disconnected → reconnecting → connected
 *                    ↘ (retry)  ↗                              ↘ (retry)
 *                    connecting                                 reconnecting
 *                    ...
 *                    error ← (max retries exhausted from either connecting or reconnecting)
 *
 * Key invariant: "reconnecting" and "disconnected" MUST only appear after
 * at least one successful connection (hasEverConnected === true).
 */
export type ConnectionState =
  | "idle"
  | "connecting"
  | "connected"
  | "disconnected"
  | "reconnecting"
  | "error";

/**
 * State labeling rules (post-fix):
 *
 * connect() called, hasEverConnected=false → state = "connecting"
 * connect() called, hasEverConnected=true, attempts>0 → state = "reconnecting"
 * ws.onopen fires → hasEverConnected=true, state = "connected", attempts reset to 0
 * ws.onclose fires, hasEverConnected=false → NO state change; go to retry directly
 * ws.onclose fires, hasEverConnected=true → state = "disconnected", then retry
 * max retries reached → state = "error"
 * user calls retry() → hasEverConnected=false, attempts=0, state = "connecting"
 */

export interface UseTerminalContract {
  /**
   * Current connection state. Drives what overlay (if any) the user sees.
   */
  connectionState: ConnectionState;

  /**
   * Manually retry connection after "error" state.
   * Resets hasEverConnected and reconnect attempt counter.
   * Sets state to "connecting".
   */
  retry: () => void;
}

/**
 * Overlay message mapping (drives terminal-panel.tsx ConnectionOverlay):
 *
 * "idle"          → "Connecting..."              (spinner)
 * "connecting"    → "Connecting..."              (spinner)
 * "connected"     → (overlay hidden)
 * "disconnected"  → "Connection lost. Retrying..." (spinner)
 * "reconnecting"  → "Connection lost. Retrying..." (spinner)
 * "error"         → "Connection failed."         (Retry button)
 */
export type OverlayMessage =
  | "Connecting..."
  | "Connection lost. Retrying..."
  | "Connection failed.";
