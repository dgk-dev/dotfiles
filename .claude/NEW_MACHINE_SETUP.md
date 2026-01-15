# New Machine Setup

## One-Click Setup (Warp Drive)

새 컴퓨터에서 Warp 로그인 후 Workflow 실행:

```bash
# dotfiles clone + 필수 도구 설치 + zoxide 설치
curl -fsSL https://raw.githubusercontent.com/dgk-dev/dotfiles/main/.local/bin/setup-new-machine.sh | bash
```

## Manual Setup

```bash
# 1. Clone dotfiles
git clone --bare https://github.com/dgk-dev/dotfiles.git $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config checkout
config config --local status.showUntrackedFiles no

# 2. Install & login Bitwarden CLI
npm install -g @bitwarden/cli
bw login
export BW_SESSION=$(bw unlock --raw)

# 3. Sync API keys from Bitwarden
~/.local/bin/sync-claude-env.sh

# 4. Run MCP setup
~/.local/bin/setup-claude-mcp.sh

# 5. Login to Claude
claude login
```

## What Gets Synced

| Item | Method | Location |
|------|--------|----------|
| .zshrc | Git (dotfiles) | `~/.zshrc` |
| ri.md | Git (dotfiles) | `~/.claude/commands/ri.md` |
| CLAUDE.md | Git (dotfiles) | `~/.claude/CLAUDE.md` |
| settings.json | Git (dotfiles) | `~/.claude/settings.json` |
| telegram-notify.sh | Git (dotfiles) | `~/.claude/hooks/telegram-notify.sh` |
| MCP setup script | Git (dotfiles) | `~/.local/bin/setup-claude-mcp.sh` |
| API keys sync | Git (dotfiles) | `~/.local/bin/sync-claude-env.sh` |
| setup script | Git (dotfiles) | `~/.local/bin/setup-new-machine.sh` |
| .wslconfig template | Git (dotfiles) | `~/.wslconfig.template` |
| **API keys** | **Bitwarden** | `~/.claude/.env.local` (generated) |

## API Keys in Bitwarden

| Key Name | Service |
|----------|---------|
| `neon-api-key` | Neon PostgreSQL |
| `notion-api-key` | Notion API |
| `openrouter-api-key` | OpenRouter |
| `magic-api-key` | 21st.dev Magic |
| `telegram-bot` | Telegram notifications |

## MCP Servers

- **context7-mcp**: Documentation lookup
- **sequential-thinking**: Complex reasoning
- **chrome-devtools**: Browser automation
- **memory-bank**: Project memory
- **neon**: PostgreSQL

## Warp Tips

1. **Settings Sync**: Settings > Account > Enable Settings Sync
2. **Warp Drive**: 부트스트랩 명령어를 Workflow로 저장
3. **Launch Configurations**: 프로젝트별 세션 설정

## Files NOT Synced (Security)

- `~/.claude/.env.local` - API keys (Bitwarden에서 생성)
- `~/.claude/.credentials.json` - Claude login tokens
- `~/.claude/settings.local.json` - Project permissions
