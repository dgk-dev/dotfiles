# Claude Code New Machine Setup

## Quick Start

```bash
# 1. Clone dotfiles (if not already done)
git clone --bare https://github.com/dgk-dev/dotfiles.git $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config checkout

# 2. Run MCP setup
~/.local/bin/setup-claude-mcp.sh

# 3. (Optional) Add Neon API key
export NEON_API_KEY="your_api_key_here"
~/.local/bin/setup-claude-mcp.sh  # Re-run to add neon
```

## What Gets Synced

| Item | Method | Location |
|------|--------|----------|
| ri.md (workflow) | Git (dotfiles) | `~/.claude/commands/ri.md` |
| CLAUDE.md | Git (dotfiles) | `~/.claude/CLAUDE.md` |
| MCP servers | Script | `~/.local/bin/setup-claude-mcp.sh` |
| Memory Bank | Per-project Git | `<project>/.memory-bank/` |

## MCP Servers Included

- **context7-mcp**: Documentation lookup
- **sequential-thinking**: Complex reasoning
- **chrome-devtools**: Browser automation
- **memory-bank**: Project memory (stored in project root)
- **neon**: PostgreSQL (requires API key)

## Sensitive Data

Neon API key is NOT stored in dotfiles. Options:
1. Add to `~/.claude/.env.local` (gitignored)
2. Set as environment variable before running script
3. Add manually: `claude mcp add neon -s user -- npx -y @neondatabase/mcp-server-neon start YOUR_KEY`
