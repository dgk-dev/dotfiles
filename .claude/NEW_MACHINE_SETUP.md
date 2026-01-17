# New Machine Setup

## One-Click Setup (Warp Drive)

새 컴퓨터에서 Warp 로그인 후 실행:

```bash
curl -fsSL https://raw.githubusercontent.com/dgk-dev/dotfiles/main/.local/bin/setup-new-machine.sh | bash
```

이 스크립트가 자동으로:
1. Dotfiles clone
2. 필수 패키지 설치 (zsh, eza, bat, fd, gnupg, pass 등)
3. SSH 키 생성 + GitHub 등록
4. pass 저장소 clone + GPG 키 임포트
5. Node.js (fnm) 설치
6. Claude Code 설치
7. MCP 서버 설정

## Manual Setup

```bash
# 1. Clone dotfiles
git clone --bare https://github.com/dgk-dev/dotfiles.git $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config checkout
config config --local status.showUntrackedFiles no

# 2. Setup pass (Password Store)
~/.local/bin/setup-pass.sh

# 3. Run MCP setup
~/.local/bin/setup-claude-mcp.sh

# 4. Login to Claude
claude login
```

## Secrets Management

`pass` (Password Store)를 사용하여 API 키를 관리합니다.

### 사용 가능한 명령어

```bash
# 모든 키 목록
secrets list

# 특정 키 편집
secrets edit CONTEXT7_API_KEY

# 새 키 추가
secrets add NEW_API_KEY

# 키 값 보기
secrets show NEON_API_KEY

# 대화형 모드 (모든 키 설정)
secrets

# .env.local 재생성
secrets regen
```

### 저장되는 API 키

| Key | Service |
|-----|---------|
| `ANTHROPIC_API_KEY` | Claude API |
| `OPENROUTER_API_KEY` | OpenRouter |
| `CONTEXT7_API_KEY` | Context7 MCP |
| `NEON_API_KEY` | Neon PostgreSQL |
| `NOTION_API_KEY` | Notion API |
| `TELEGRAM_BOT_TOKEN` | Telegram |
| `TELEGRAM_CHAT_ID` | Telegram |
| `MAGIC_API_KEY` | 21st.dev Magic |

## What Gets Synced

| Item | Method | Location |
|------|--------|----------|
| .zshrc | Git (dotfiles) | `~/.zshrc` |
| ri.md | Git (dotfiles) | `~/.claude/commands/ri.md` |
| CLAUDE.md | Git (dotfiles) | `~/.claude/CLAUDE.md` |
| settings.json | Git (dotfiles) | `~/.claude/settings.json` |
| telegram-notify.sh | Git (dotfiles) | `~/.claude/hooks/telegram-notify.sh` |
| setup-claude-mcp.sh | Git (dotfiles) | `~/.local/bin/setup-claude-mcp.sh` |
| setup-pass.sh | Git (dotfiles) | `~/.local/bin/setup-pass.sh` |
| setup-secrets.sh | Git (dotfiles) | `~/.local/bin/setup-secrets.sh` |
| setup-new-machine.sh | Git (dotfiles) | `~/.local/bin/setup-new-machine.sh` |
| **API keys** | **pass (GPG)** | `~/.password-store/claude/` |

## MCP Servers

| Server | API Key | Description |
|--------|---------|-------------|
| context7-mcp | CONTEXT7_API_KEY | 라이브러리 문서 조회 |
| sequential-thinking | - | 복잡한 추론 |
| chrome-devtools | - | 브라우저 자동화 (WSL→Windows) |
| memory-bank | - | 프로젝트 메모리 |
| neon | NEON_API_KEY | PostgreSQL |

## Files NOT Synced (Security)

- `~/.claude/.env.local` - API keys (pass에서 생성)
- `~/.claude/.credentials.json` - Claude login tokens
- `~/.claude/settings.local.json` - Project permissions
- `~/.password-store/` - GPG encrypted secrets

## Warp Tips

1. **Settings Sync**: Settings > Account > Enable Settings Sync
2. **Warp Drive**: 부트스트랩 명령어를 Workflow로 저장
3. **Launch Configurations**: 프로젝트별 세션 설정
