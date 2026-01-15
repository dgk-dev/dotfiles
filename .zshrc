# ============================================
# Minimal ZSH Configuration (Warp-optimized)
# ============================================
# Oh My Zsh, Starship, fzf 제거됨 - Warp가 대체
# 유지: zoxide, 실용 alias, 필수 도구만

# ============================================
# PATH
# ============================================
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# ============================================
# SSH Agent (keychain)
# ============================================
if command -v keychain &> /dev/null; then
    eval $(keychain --eval --quiet id_ed25519 2>/dev/null)
fi

# ============================================
# fnm (Fast Node Manager)
# ============================================
export PATH="$HOME/.local/share/fnm:$PATH"
if command -v fnm &> /dev/null; then
    eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"
fi

# ============================================
# uv (Python package manager)
# ============================================
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# ============================================
# zoxide (smart cd) - 필수!
# ============================================
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# ============================================
# History 설정
# ============================================
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

# ============================================
# Modern CLI Aliases (실용적인 것만)
# ============================================

# ls 대체 (eza)
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first --git'
    alias la='eza -a --icons --group-directories-first'
    alias lt='eza --tree --level=2 --icons'
    alias tree='eza --tree --icons --group-directories-first'
fi

# cat 대체 (batcat)
if command -v batcat &> /dev/null; then
    alias cat='batcat --paging=never'
    alias catn='batcat'
fi

# fd 대체
command -v fdfind &> /dev/null && alias fd='fdfind'

# lazygit
command -v lazygit &> /dev/null && alias lg='lazygit'

# ============================================
# Git Aliases
# ============================================
alias gst='git status'
alias gco='git checkout'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate'

# ============================================
# Docker Aliases
# ============================================
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'

# ============================================
# Navigation
# ============================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cls='clear'

# ============================================
# Dotfiles Management (bare git repo)
# ============================================
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# ============================================
# Claude Code
# ============================================
alias cc='claude --dangerously-skip-permissions'

# Claude Code MCP 환경변수
if [ -f ~/.claude/.env.local ]; then
    set -a
    source ~/.claude/.env.local
    set +a
fi

# ============================================
# VS Code PATH (WSL)
# ============================================
export PATH="$PATH:/mnt/c/Users/kangm/AppData/Local/Programs/Microsoft VS Code/bin"

# ============================================
# Simple Prompt (Warp UI가 정보 제공)
# ============================================
PROMPT='%F{blue}%~%f %F{green}❯%f '
