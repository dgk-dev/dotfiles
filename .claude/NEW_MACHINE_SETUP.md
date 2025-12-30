# Claude Code New Machine Setup

## Quick Start

```bash
# 1. Clone dotfiles (if not already done)
git clone --bare https://github.com/dgk-dev/dotfiles.git $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config checkout

# 2. Install & login Bitwarden CLI
npm install -g @bitwarden/cli
bw login
export BW_SESSION=$(bw unlock --raw)

# 3. Sync API keys from Bitwarden
~/.local/bin/sync-claude-env.sh

# 4. Run MCP setup
~/.local/bin/setup-claude-mcp.sh
```

## What Gets Synced

| Item | Method | Location |
|------|--------|----------|
| ri.md (workflow) | Git (dotfiles) | `~/.claude/commands/ri.md` |
| CLAUDE.md | Git (dotfiles) | `~/.claude/CLAUDE.md` |
| MCP setup script | Git (dotfiles) | `~/.local/bin/setup-claude-mcp.sh` |
| API keys sync script | Git (dotfiles) | `~/.local/bin/sync-claude-env.sh` |
| API keys | Bitwarden | `~/.claude/.env.local` (generated) |
| Memory Bank | Per-project Git | `<project>/.memory-bank/` |

## API Keys in Bitwarden

| Key Name | Service |
|----------|---------|
| `neon-api-key` | Neon PostgreSQL |
| `notion-api-key` | Notion API |
| `openrouter-api-key` | OpenRouter |
| `magic-api-key` | 21st.dev Magic |
| `telegram-bot` | Telegram notifications |

## MCP Servers Included

- **context7-mcp**: Documentation lookup
- **sequential-thinking**: Complex reasoning
- **chrome-devtools**: Browser automation
- **memory-bank**: Project memory (stored in project root)
- **neon**: PostgreSQL (auto-fetches key from Bitwarden)
