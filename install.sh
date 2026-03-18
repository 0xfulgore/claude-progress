#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Claude Code Task Progress Bar - Installer
# Animated status line + /progress slash command
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

RST=$'\e[0m'
GREEN=$'\e[32m'
CYAN=$'\e[36m'
YELLOW=$'\e[33m'
DIM=$'\e[2m'
BOLD=$'\e[1m'

echo ""
echo "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo "${CYAN}${BOLD}  📊 Claude Code Task Progress Bar${RST}"
echo "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo ""

# Detect script directory (works whether run from repo or piped)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null || echo ".")" && pwd)"

# ── 1. Install the /progress slash command skill ─────────────
echo "${GREEN}[1/3]${RST} Installing /progress skill..."
mkdir -p ~/.agents/skills/progress ~/.claude/skills
if [ -f "$SCRIPT_DIR/SKILL.md" ]; then
  cp "$SCRIPT_DIR/SKILL.md" ~/.agents/skills/progress/SKILL.md
else
  # Inline the skill if running standalone
  cat > ~/.agents/skills/progress/SKILL.md << 'SKILL_EOF'
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
SKILL_EOF
fi
ln -sfn ~/.agents/skills/progress ~/.claude/skills/progress 2>/dev/null || true
echo "  ${DIM}→ ~/.agents/skills/progress/SKILL.md${RST}"
echo "  ${DIM}→ ~/.claude/skills/progress (symlink)${RST}"

# ── 2. Install the animated status line script ───────────────
echo "${GREEN}[2/3]${RST} Installing animated status line..."
mkdir -p ~/.claude/hooks

if [ -f "$SCRIPT_DIR/task-progress-statusline.sh" ]; then
  cp "$SCRIPT_DIR/task-progress-statusline.sh" ~/.claude/hooks/task-progress-statusline.sh
else
  # Inline the status line script
  cat > ~/.claude/hooks/task-progress-statusline.sh << 'STATUSLINE_EOF'
#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Task Progress Status Line for Claude Code
# Colorful status bar with git, tasks, context, cost, duration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

input=$(cat)

# ── ANSI Colors ──────────────────────────────────────────────
RST=$'\e[0m'
DIM=$'\e[2m'
BOLD=$'\e[1m'
BLINK=$'\e[5m'
RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
BLUE=$'\e[34m'
MAGENTA=$'\e[35m'
CYAN=$'\e[36m'
WHITE=$'\e[37m'
BRIGHT_GREEN=$'\e[92m'
BRIGHT_YELLOW=$'\e[93m'
BRIGHT_CYAN=$'\e[96m'
BRIGHT_WHITE=$'\e[97m'
BG_DIM=$'\e[48;5;236m'

# ── Animation ────────────────────────────────────────────────
TICK=$(date +%s)
SPINNERS=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
SPIN_IDX=$(( TICK % ${#SPINNERS[@]} ))
SPINNER="${SPINNERS[$SPIN_IDX]}"
PULSE_CHARS=("▓" "▒" "░" "▒")
PULSE_IDX=$(( TICK % ${#PULSE_CHARS[@]} ))
PULSE="${PULSE_CHARS[$PULSE_IDX]}"
DOTS_FRAMES=("·  " "·· " "···" " ··" "  ·" "   ")
DOTS_IDX=$(( TICK % ${#DOTS_FRAMES[@]} ))
DOTS="${DOTS_FRAMES[$DOTS_IDX]}"

# ── Parse stdin JSON ─────────────────────────────────────────
model=$(echo "$input" | jq -r '.model.display_name // .model.id // "Claude"' 2>/dev/null)
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0' 2>/dev/null)
cwd=$(echo "$input" | jq -r '.cwd // ""' 2>/dev/null)
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' 2>/dev/null)
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0' 2>/dev/null)
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0' 2>/dev/null)
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0' 2>/dev/null)
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0' 2>/dev/null)
agent_name=$(echo "$input" | jq -r '.agent.name // ""' 2>/dev/null)
session_id=$(echo "$input" | jq -r '.session_id // ""' 2>/dev/null)

# ── Helpers ──────────────────────────────────────────────────
context_color() {
  local pct=$1
  if [ "$pct" -ge 85 ] 2>/dev/null; then echo "$RED"
  elif [ "$pct" -ge 70 ] 2>/dev/null; then echo "$YELLOW"
  elif [ "$pct" -ge 50 ] 2>/dev/null; then echo "$BRIGHT_YELLOW"
  else echo "$GREEN"
  fi
}

colored_bar() {
  local pct=$1 width=${2:-12}
  local filled=$(( (pct * width + 50) / 100 ))
  local empty=$(( width - filled ))
  local color
  color=$(context_color "$pct")
  printf "%s" "${color}"
  for ((i=0; i<filled; i++)); do printf "█"; done
  printf "%s" "${DIM}"
  for ((i=0; i<empty; i++)); do printf "░"; done
  printf "%s" "${RST}"
}

format_duration() {
  local ms=$1
  local secs=$(( ms / 1000 ))
  if [ "$secs" -lt 60 ]; then
    echo "<1m"
  elif [ "$secs" -lt 3600 ]; then
    echo "$(( secs / 60 ))m"
  else
    local h=$(( secs / 3600 ))
    local m=$(( (secs % 3600) / 60 ))
    echo "${h}h ${m}m"
  fi
}

# ── Line 1: Model │ Context │ Git │ Cost │ Duration ──────────
parts=()
parts+=("${BRIGHT_CYAN}${BOLD}${model}${RST}")
ctx_color=$(context_color "$ctx_pct")
ctx_bar=$(colored_bar "$ctx_pct" 10)
parts+=("${ctx_bar} ${ctx_color}${ctx_pct}%${RST}")

if [ -n "$cwd" ]; then
  project=$(basename "$cwd")
  git_part=""
  if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
      dirty=""
      if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null | head -1)" ]; then
        dirty="${YELLOW}*${RST}"
      fi
      ab=""
      revlist=$(git -C "$cwd" rev-list --left-right --count "@{upstream}...HEAD" 2>/dev/null)
      if [ -n "$revlist" ]; then
        behind=$(echo "$revlist" | awk '{print $1}')
        ahead=$(echo "$revlist" | awk '{print $2}')
        [ "$ahead" -gt 0 ] 2>/dev/null && ab+=" ${GREEN}↑${ahead}${RST}"
        [ "$behind" -gt 0 ] 2>/dev/null && ab+=" ${RED}↓${behind}${RST}"
      fi
      git_part=" ${MAGENTA}git:(${RST}${CYAN}${branch}${dirty}${ab}${MAGENTA})${RST}"
    fi
  fi
  parts+=("${YELLOW}${project}${RST}${git_part}")
fi

if [ "$lines_added" -gt 0 ] 2>/dev/null || [ "$lines_removed" -gt 0 ] 2>/dev/null; then
  changes=""
  [ "$lines_added" -gt 0 ] 2>/dev/null && changes+="${GREEN}+${lines_added}${RST}"
  if [ "$lines_removed" -gt 0 ] 2>/dev/null; then
    [ -n "$changes" ] && changes+=" "
    changes+="${RED}-${lines_removed}${RST}"
  fi
  parts+=("${changes}")
fi

if [ "$(echo "$cost > 0" | bc 2>/dev/null)" = "1" ]; then
  cost_fmt=$(printf "%.2f" "$cost")
  if [ "$(echo "$cost >= 5" | bc 2>/dev/null)" = "1" ]; then
    parts+=("${RED}\$${cost_fmt}${RST}")
  elif [ "$(echo "$cost >= 2" | bc 2>/dev/null)" = "1" ]; then
    parts+=("${YELLOW}\$${cost_fmt}${RST}")
  else
    parts+=("${DIM}\$${cost_fmt}${RST}")
  fi
fi

if [ "$duration_ms" -gt 0 ] 2>/dev/null; then
  dur=$(format_duration "$duration_ms")
  parts+=("${DIM}⏱ ${dur}${RST}")
fi

if [ -n "$agent_name" ]; then
  parts+=("${MAGENTA}@${agent_name}${RST}")
fi

line1=""
for i in "${!parts[@]}"; do
  if [ "$i" -gt 0 ]; then
    line1+=" ${DIM}│${RST} "
  fi
  line1+="${parts[$i]}"
done

echo "$line1"

# ── Line 2: Task Progress (if tasks exist) ───────────────────

task_dir=""
latest_mtime=0

if [ -n "$session_id" ] && [ -d "$HOME/.claude/tasks/$session_id" ]; then
  task_dir="$HOME/.claude/tasks/$session_id/"
  latest_mtime=$(find "$task_dir" -name "*.json" -type f -exec stat -f "%m" {} \; 2>/dev/null | sort -rn | head -1)
fi

if [ -z "$task_dir" ] || [ -z "$latest_mtime" ] || [ "$latest_mtime" = "0" ]; then
  if [ -n "$agent_name" ]; then
    for team_cfg in ~/.claude/teams/*/config.json; do
      [ -f "$team_cfg" ] || continue
      team_dir=$(dirname "$team_cfg")
      team_name=$(basename "$team_dir")
      if [ -d "$HOME/.claude/tasks/$team_name" ]; then
        dir_mtime=$(find "$HOME/.claude/tasks/$team_name" -name "*.json" -type f -exec stat -f "%m" {} \; 2>/dev/null | sort -rn | head -1)
        if [ -n "$dir_mtime" ] && [ "$dir_mtime" -gt "$latest_mtime" ] 2>/dev/null; then
          latest_mtime=$dir_mtime
          task_dir="$HOME/.claude/tasks/$team_name/"
        fi
      fi
    done
  fi

  if [ -z "$task_dir" ] || [ "$latest_mtime" = "0" ]; then
    for dir in ~/.claude/tasks/*/; do
      [ -d "$dir" ] || continue
      dirname=$(basename "$dir")
      if [ -z "$agent_name" ]; then
        case "$dirname" in
          ????????-????-????-????-????????????) continue ;;
        esac
      fi
      newest=$(find "$dir" -name "*.json" -type f -exec stat -f "%m" {} \; 2>/dev/null | sort -rn | head -1)
      if [ -n "$newest" ] && [ "$newest" -gt "$latest_mtime" ] 2>/dev/null; then
        latest_mtime=$newest
        task_dir="$dir"
      fi
    done
  fi
fi

now=$(date +%s)
if [ -n "$task_dir" ] && [ "$latest_mtime" -gt 0 ] 2>/dev/null; then
  age=$(( now - latest_mtime ))
  [ "$age" -gt 21600 ] && task_dir=""
fi

if [ -n "$task_dir" ]; then
  total=0; completed=0; in_progress=0; blocked=0; pending_count=0

  for f in "$task_dir"*.json; do
    [ -f "$f" ] || continue
    status=$(jq -r '.status // "pending"' "$f" 2>/dev/null)
    blocked_by=$(jq -r '.blockedBy // [] | length' "$f" 2>/dev/null)
    total=$((total + 1))
    case "$status" in
      completed) completed=$((completed + 1)) ;;
      in_progress)
        if [ "$blocked_by" -gt 0 ] 2>/dev/null; then
          blocked=$((blocked + 1))
        else
          in_progress=$((in_progress + 1))
        fi ;;
      *)
        if [ "$blocked_by" -gt 0 ] 2>/dev/null; then
          blocked=$((blocked + 1))
        else
          pending_count=$((pending_count + 1))
        fi ;;
    esac
  done

  if [ "$total" -gt 0 ]; then
    bar_w=20
    c_chars=$(( (completed * bar_w) / total ))
    a_chars=$(( (in_progress * bar_w) / total ))
    b_chars=$(( (blocked * bar_w) / total ))
    p_chars=$(( bar_w - c_chars - a_chars - b_chars ))
    [ "$p_chars" -lt 0 ] && p_chars=0
    [ "$completed" -gt 0 ] && [ "$c_chars" -eq 0 ] && c_chars=1
    [ "$in_progress" -gt 0 ] && [ "$a_chars" -eq 0 ] && a_chars=1
    [ "$blocked" -gt 0 ] && [ "$b_chars" -eq 0 ] && b_chars=1
    over=$(( c_chars + a_chars + b_chars + p_chars - bar_w ))
    if [ "$over" -gt 0 ]; then
      p_chars=$(( p_chars - over ))
      [ "$p_chars" -lt 0 ] && p_chars=0
    fi
    under=$(( bar_w - c_chars - a_chars - b_chars - p_chars ))
    [ "$under" -gt 0 ] && p_chars=$(( p_chars + under ))

    bar="${GREEN}"
    for ((i=0; i<c_chars; i++)); do bar+="█"; done
    if [ "$a_chars" -gt 0 ]; then
      bar+="${BRIGHT_CYAN}"
      for ((i=0; i<a_chars-1; i++)); do bar+="▓"; done
      bar+="${BRIGHT_CYAN}${BOLD}${PULSE}${RST}"
    fi
    bar+="${YELLOW}"
    for ((i=0; i<b_chars; i++)); do bar+="░"; done
    bar+="${DIM}"
    for ((i=0; i<p_chars; i++)); do bar+="·"; done
    bar+="${RST}"

    remaining=$((total - completed))
    if [ "$remaining" -eq 0 ]; then
      eta="${GREEN}done!${RST}"
    elif [ "$in_progress" -gt 0 ]; then
      eta_min=$(( (remaining * 10 + in_progress - 1) / in_progress ))
      if [ "$eta_min" -lt 60 ]; then
        eta="${DIM}~${eta_min}m${RST}"
      else
        eta="${DIM}~$(( eta_min / 60 ))h${RST}"
      fi
    else
      eta="${DIM}waiting${RST}"
    fi

    team=$(basename "$task_dir")
    if [ ${#team} -gt 18 ]; then
      team="${team:0:15}..."
    fi

    counts=""
    [ "$completed" -gt 0 ] && counts+="${GREEN}✓${completed}${RST} "
    [ "$in_progress" -gt 0 ] && counts+="${BRIGHT_CYAN}▶${in_progress}${RST} "
    [ "$blocked" -gt 0 ] && counts+="${YELLOW}⏸${blocked}${RST} "
    [ "$pending_count" -gt 0 ] && counts+="${DIM}○${pending_count}${RST} "

    if [ "$completed" -eq "$total" ]; then
      printf "${GREEN}✨${RST} ${DIM}${team}${RST} [${bar}] ${BRIGHT_GREEN}${BOLD}${completed}/${total} complete${RST} ${counts} ${eta}\n"
    elif [ "$in_progress" -gt 0 ]; then
      printf "${BRIGHT_CYAN}${SPINNER}${RST} ${DIM}${team}${RST} [${bar}] ${BRIGHT_WHITE}${completed}/${total}${RST} ${counts} ${eta} ${BRIGHT_CYAN}${DOTS}${RST}\n"
    else
      printf "${YELLOW}⏸${RST} ${DIM}${team}${RST} [${bar}] ${BRIGHT_WHITE}${completed}/${total}${RST} ${counts} ${eta}\n"
    fi
  fi
fi
STATUSLINE_EOF
fi

chmod +x ~/.claude/hooks/task-progress-statusline.sh
echo "  ${DIM}→ ~/.claude/hooks/task-progress-statusline.sh${RST}"

# ── 3. Configure settings.json ───────────────────────────────
echo "${GREEN}[3/3]${RST} Configuring status line in settings..."

SETTINGS_FILE="$HOME/.claude/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
  # Check if statusLine already points to our script
  current=$(jq -r '.statusLine.command // ""' "$SETTINGS_FILE" 2>/dev/null)
  if [[ "$current" == *"task-progress-statusline"* ]]; then
    echo "  ${DIM}→ Already configured in settings.json${RST}"
  else
    # Backup existing settings
    cp "$SETTINGS_FILE" "${SETTINGS_FILE}.bak"
    echo "  ${DIM}→ Backed up settings to settings.json.bak${RST}"

    # Update statusLine
    jq '.statusLine = {"type": "command", "command": "~/.claude/hooks/task-progress-statusline.sh"}' \
      "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
    echo "  ${DIM}→ Updated statusLine in settings.json${RST}"
  fi
else
  # Create minimal settings
  cat > "$SETTINGS_FILE" << 'SETTINGS_EOF'
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/hooks/task-progress-statusline.sh"
  }
}
SETTINGS_EOF
  echo "  ${DIM}→ Created settings.json${RST}"
fi

# ── Done! ─────────────────────────────────────────────────────
echo ""
echo "${GREEN}${BOLD}✅ Installed!${RST}"
echo ""
echo "  ${BRIGHT_WHITE}What you get:${RST}"
echo "  ${CYAN}•${RST} ${BOLD}/progress${RST}  — Full ASCII dashboard with per-task progress bars"
echo "  ${CYAN}•${RST} ${BOLD}Status bar${RST} — Always-on animated bar at the bottom with:"
echo "      Model │ Context │ Git branch │ Lines changed │ Cost │ Duration"
echo "      + Task progress with animated spinner when work is active"
echo ""
echo "  ${DIM}Restart Claude Code for changes to take effect.${RST}"
echo ""
