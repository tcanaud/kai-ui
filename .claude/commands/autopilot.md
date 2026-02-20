# /autopilot — Continuous Improvement Loop

**Input**: `$ARGUMENTS` — optional: `max_cycles=N` (default: 5)

You are the **Autopilot**. You run a continuous improve loop: fix all known bugs, discover new ones, triage them, repeat. You stop when there are no more bugs to fix or you hit the max cycle limit.

## Parse Arguments

Extract `MAX_CYCLES` from `$ARGUMENTS`. Default: `5` if not provided or not a number.

## State

Track these counters across the loop:
- `cycle`: current cycle number (starts at 1)
- `hotfixes_total`: total bugs fixed across all cycles
- `feedbacks_discovered`: total feedbacks created by QA
- `backlogs_created`: total backlogs created by triage

## The Loop

```
for cycle = 1 to MAX_CYCLES:

  ┌─ PHASE 1: Fix all known bugs ─────────────────────────┐
  │  Check .product/backlogs/promoted/ for critical-bug or  │
  │  bug items with priority critical or high.             │
  │  While bugs exist:                                     │
  │    → Run /playbook.run autohotfix                      │
  │    → Increment hotfixes_total                          │
  │    → Re-check for remaining bugs                       │
  │  If no bugs found: skip to Phase 2                     │
  └────────────────────────────────────────────────────────┘
          │
          ▼
  ┌─ PHASE 2: Discover new issues ─────────────────────────┐
  │  Ensure dev servers are running (kill ports 3000/3001,  │
  │  rm .next/dev/lock, npm run dev:all, wait for 200)     │
  │  → Run /playbook.run qa-mcp-chrome http://localhost:3000│
  │  → Record feedbacks_discovered                         │
  └────────────────────────────────────────────────────────┘
          │
          ▼
  ┌─ PHASE 3: Triage into backlogs ────────────────────────┐
  │  → Run /playbook.run pm-digest                         │
  │  → Record backlogs_created                             │
  └────────────────────────────────────────────────────────┘
          │
          ▼
  ┌─ PHASE 4: Auto-promote bug backlogs ──────────────────┐
  │  Scan .product/backlogs/open/ for bug or critical-bug  │
  │  items with priority critical or high.                 │
  │  For each: run /product.promote {BL-ID}                │
  │  → Check: any newly promoted bugs?                     │
  │    - Yes → continue to next cycle                      │
  │    - No  → STOP (nothing left to fix)                  │
  └────────────────────────────────────────────────────────┘
```

## Execution Protocol

### Phase 1: Hotfix Sweep

1. Use the Skill tool to invoke `product.backlog` with args: `"List all promoted backlogs with category critical-bug or bug AND priority critical or high. Report count and IDs."`
2. If count > 0:
   - Use the Skill tool to invoke `playbook.run` with args: `"autohotfix"`
   - After completion, re-check for remaining promoted bugs
   - Repeat until no more qualifying bugs exist
3. If count = 0: report "No promoted bugs — skipping to discovery" and proceed to Phase 2

### Phase 2: QA Discovery

1. **MANDATORY — Restart dev servers before QA**. You MUST execute these Bash commands yourself (not delegate to a subagent):
   ```bash
   lsof -ti :3000 | xargs kill -9 2>/dev/null; lsof -ti :3001 | xargs kill -9 2>/dev/null
   rm -f .next/dev/lock
   ```
   Then start servers in background:
   ```bash
   npm run dev:all &
   ```
   Then wait and verify (retry every 2s, up to 15s):
   ```bash
   for i in 1 2 3 4 5 6 7; do curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q 200 && break; sleep 2; done
   ```
   **Do NOT proceed to the next step until localhost:3000 returns HTTP 200.**
2. Use the Skill tool to invoke `playbook.run` with args: `"qa-mcp-chrome http://localhost:3000"`
3. Count new feedbacks in `.product/feedbacks/new/` and `.product/inbox/`

### Phase 3: PM Triage

1. Use the Skill tool to invoke `playbook.run` with args: `"pm-digest"`
2. Record `backlogs_created` count

### Phase 4: Auto-Promote Bug Backlogs

1. Scan `.product/backlogs/open/` for items with category `bug` or `critical-bug` AND priority `critical` or `high`
2. For each qualifying backlog found:
   - Use the Skill tool to invoke `product.promote` with args: `"{BL-ID}"`
   - Record the promotion
3. If any bugs were promoted: report count and continue to next cycle
4. If no qualifying bugs found in open: **STOP** — the app is clean

## Stop Conditions

Stop the loop when ANY of these is true:
- `cycle > MAX_CYCLES` — report: "Max cycles reached. {hotfixes_total} bugs fixed in {cycle} cycles."
- Phase 4 finds no qualifying bugs to promote — report: "App is clean. {hotfixes_total} bugs fixed in {cycle} cycles."
- A playbook fails with `stop` error policy — report the failure and halt

## Cycle Report

After each cycle, print:

```
═══ Autopilot Cycle {cycle}/{MAX_CYCLES} Complete ═══

Hotfixes this cycle: {N}
Feedbacks discovered: {N}
Backlogs created: {N}

Running totals:
  Total hotfixes: {hotfixes_total}
  Total feedbacks: {feedbacks_discovered}
  Total backlogs: {backlogs_created}

Status: {continuing to next cycle | stopping — no new bugs | stopping — max cycles}
```

## Final Report

When the loop ends:

```
═══════════════════════════════════════════
  AUTOPILOT COMPLETE
═══════════════════════════════════════════

Cycles completed: {cycle} / {MAX_CYCLES}
Stop reason: {no new bugs | max cycles | error}

Total hotfixes applied: {hotfixes_total}
Total feedbacks discovered: {feedbacks_discovered}
Total backlogs created: {backlogs_created}

Session logs: .playbooks/sessions/
═══════════════════════════════════════════
```

## Rules

- **Use playbooks as-is**: invoke `/playbook.run` for each sub-workflow. Do not bypass.
- **Fresh per playbook**: each `/playbook.run` invocation creates its own session. Let the playbook supervisor handle step orchestration.
- **No infinite loops**: always respect MAX_CYCLES. Default 5 is a safety net.
- **Servers stay up**: start them once in Phase 2 and let them run. Only restart if health check fails.
- **Commit hygiene**: autohotfix handles its own commits. Do not add extra commits between phases.
