# User Global Settings

## ri.md 백업 규칙

`~/.claude/commands/ri.md` 수정 후에는 항상 dotfiles repo에 커밋+푸시:

```bash
/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME add ~/.claude/commands/ri.md
/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME commit -m "chore(claude): update ri.md"
/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME push origin main
```

Repo: https://github.com/dgk-dev/dotfiles
