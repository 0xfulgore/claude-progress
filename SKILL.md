---
name: progress
description: "Show visual progress bars for all tasks with status, owners, dependencies, and rough ETAs. Triggers on: progress, progress bar, task progress, show progress, status report, task status"
---

# Task Progress Dashboard

Render a visual ASCII progress dashboard for all tasks in the current task list.

## When to Use

- User asks for a progress report, status update, or progress bars
- User wants to see task completion status at a glance
- User invokes `/progress`

## Instructions

1. Call **TaskList** to get all current tasks
2. If there are no tasks, tell the user "No tasks found. Create tasks first with TaskCreate."
3. For each task, determine its visual state and render the dashboard below.

## Rendering Rules

### Progress Bar Characters

Use these exact characters for progress bars (20 chars wide):

- Completed: `█` (full block)
- In Progress: `▓` (dark shade — fill proportionally, default to 50% if unknown)
- Blocked: `░` (light shade — full bar)
- Pending: `·` (middle dot — full bar)

### Status Labels

| Task Status | Has blockedBy? | Display Label |
|-------------|---------------|---------------|
| completed   | —             | Done          |
| in_progress | no            | In Progress   |
| in_progress | yes           | Blocked       |
| pending     | no            | Pending       |
| pending     | yes           | Blocked       |

### ETA Estimation

Estimate rough ETAs using these heuristics:

- **Done**: Show "done" instead of ETA
- **In Progress**: Estimate based on task complexity from the description:
  - Simple (single file, small change, test, config): ~2-5 min
  - Medium (new function, handler, moderate logic): ~5-15 min
  - Complex (new module, multi-file, architecture): ~15-30 min
  - If the task has been in_progress and you know when it started, factor that in
- **Blocked**: Show "blocked" instead of ETA
- **Pending**: Show "waiting" instead of ETA

### Output Format

Render the dashboard as a fenced code block. Use this exact layout:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📊 Task Progress
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  #1  Task subject here       [████████████████████] Done        ✓ done
  #2  Task subject here       [▓▓▓▓▓▓▓▓▓▓··········] In Progress ← owner    ~5 min
  #3  Task subject here       [░░░░░░░░░░░░░░░░░░░░] Blocked     → 1,2      blocked
  #4  Task subject here       [····················] Pending                 waiting

──────────────────────────────────────────────────────────────────
  Overall: [████████▓▓▓▓░░░░····] 2/8 complete   ~25 min remaining
──────────────────────────────────────────────────────────────────

  ✓ 1 done · ▶ 1 active · ⏸ 1 blocked · ○ 1 pending
```

### Layout Details

- **Task ID**: Right-aligned `#N`
- **Subject**: Left-aligned, truncated to 24 chars with `…` if longer
- **Progress bar**: 20 characters wide in `[brackets]`
- **Status label**: Right of bar
- **Owner**: Show `← owner-name` for in_progress tasks with an owner
- **Dependencies**: Show `→ 1,2,3` for blocked tasks (list blocking task IDs)
- **ETA**: Right-aligned, show `~N min` for active, `done`/`blocked`/`waiting` for others

### Overall Progress Bar

- Fill proportionally: completed tasks = `█`, in_progress = `▓`, blocked = `░`, pending = `·`
- Show `X/Y complete`
- Estimate total remaining time by summing ETAs of non-complete tasks

### Summary Line

Count tasks by status and show: `✓ N done · ▶ N active · ⏸ N blocked · ○ N pending`

## Important Notes

- Always use a code block so the alignment is preserved
- If the task list changes between renders, always show the latest state
- ETAs are rough estimates — label them with `~` to indicate approximation
- Keep subject text readable — truncate long names rather than wrapping
- The emojis in the header/summary are part of the format (the user wants visual appeal)
