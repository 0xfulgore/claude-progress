# 📊 Claude Code Task Progress Bar

Animated progress bars for Claude Code tasks — always visible in the status bar.

![Status bar preview](https://img.shields.io/badge/Claude_Code-Skill-blue)

## What You Get

**Status bar** (always visible at the bottom):
```
Opus 4.6 │ ████░░░░░░ 42% │ services git:(main*) │ +156 -23 │ $2.47 │ ⏱ 6m
⠹ my-project [██████▓▓▓▓▓▒░░░░░░··] 1/3 ✓1 ▶1 ⏸1  ~20m ···
```

**`/progress` slash command** (full dashboard on demand):
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📊 Task Progress
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  #1  Client interface       [████████████████████] Done        ✓ done
  #2  Message parser         [▓▓▓▓▓▓▓▓▓▓··········] In Progress ← eng  ~10 min
  #3  Sync engine            [░░░░░░░░░░░░░░░░░░░░] Blocked     → 1,2  blocked
  #4  API endpoints          [····················] Pending             waiting

──────────────────────────────────────────────────────────────────
  Overall: [████▓▓▓▓░░░░░░░░····] 1/4 complete   ~35 min remaining
──────────────────────────────────────────────────────────────────

  ✓ 1 done · ▶ 1 active · ⏸ 1 blocked · ○ 1 pending
```

## Features

- **Animated spinner** (⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏) when tasks are actively being worked
- **Pulsing leading edge** on the progress bar (▓▒░▒ cycle)
- **Bouncing activity dots** (··· animation)
- **Git branch** with dirty indicator and ahead/behind counts
- **Context bar** that goes green → yellow → red
- **Cost tracking** with color warnings ($5+ = red, $2+ = yellow)
- **Session-scoped** — each tab shows its own tasks, not global state
- **Rough ETAs** based on task complexity
- **Team-aware** — shows team task progress when working with agent teams

## Install

### One-liner
```bash
bash <(curl -sL https://raw.githubusercontent.com/0xfulgore/claude-progress/main/install.sh)
```

### Manual
```bash
git clone https://github.com/0xfulgore/claude-progress.git
cd claude-progress
bash install.sh
```

### What the installer does
1. Copies `SKILL.md` to `~/.agents/skills/progress/`
2. Copies the status line script to `~/.claude/hooks/`
3. Updates `~/.claude/settings.json` to use the status line
4. Backs up your existing settings first

## Requirements

- Claude Code CLI
- `jq` (for parsing task JSON)
- `git` (for branch info — optional, gracefully degrades)
- `bc` (for cost formatting — usually pre-installed)

## Uninstall

```bash
rm -rf ~/.agents/skills/progress ~/.claude/skills/progress ~/.claude/hooks/task-progress-statusline.sh
# Then restore your statusLine in ~/.claude/settings.json (or remove the key)
```

## License

MIT
