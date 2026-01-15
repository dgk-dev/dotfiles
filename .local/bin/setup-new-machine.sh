#!/bin/bash
# ============================================
# New Machine Setup Script
# ============================================
# Run this on a fresh WSL installation
# Warp Drive에서 "딸깍"으로 실행 가능
#
# Usage: curl -fsSL <gist-raw-url> | bash
# Or: ~/.local/bin/setup-new-machine.sh

set -e

echo "========================================"
echo "  New Machine Setup (WSL + Claude Code)"
echo "========================================"
echo ""

# ============================================
# 1. Check if dotfiles already cloned
# ============================================
if [ ! -d "$HOME/.cfg" ]; then
    echo "[1/6] Cloning dotfiles..."
    git clone --bare https://github.com/dgk-dev/dotfiles.git "$HOME/.cfg"

    # Backup existing files if any
    mkdir -p "$HOME/.config-backup"
    /usr/bin/git --git-dir="$HOME/.cfg/" --work-tree="$HOME" checkout 2>&1 | \
        grep -E "^\s+" | awk '{print $1}' | \
        xargs -I{} mv {} "$HOME/.config-backup/" 2>/dev/null || true

    # Checkout dotfiles
    /usr/bin/git --git-dir="$HOME/.cfg/" --work-tree="$HOME" checkout
    /usr/bin/git --git-dir="$HOME/.cfg/" --work-tree="$HOME" config --local status.showUntrackedFiles no
    echo "  Done!"
else
    echo "[1/6] Dotfiles already cloned, pulling latest..."
    /usr/bin/git --git-dir="$HOME/.cfg/" --work-tree="$HOME" pull origin main
    echo "  Done!"
fi

# ============================================
# 2. Install essential packages
# ============================================
echo ""
echo "[2/6] Installing essential packages..."
sudo apt update -qq
sudo apt install -y -qq curl git unzip keychain eza bat fd-find
echo "  Done!"

# ============================================
# 3. Install zoxide (if not present)
# ============================================
echo ""
echo "[3/6] Installing zoxide..."
if ! command -v zoxide &> /dev/null; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    echo "  Done!"
else
    echo "  Already installed!"
fi

# ============================================
# 4. Install Node.js via fnm (if not present)
# ============================================
echo ""
echo "[4/6] Installing Node.js via fnm..."
if ! command -v fnm &> /dev/null; then
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env)"
    fnm install --lts
    echo "  Done!"
else
    echo "  Already installed!"
fi

# Ensure npm is available
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)" 2>/dev/null || true

# ============================================
# 5. Install Claude Code (if not present)
# ============================================
echo ""
echo "[5/6] Installing Claude Code..."
if ! command -v claude &> /dev/null; then
    npm install -g @anthropic-ai/claude-code
    echo "  Done!"
else
    echo "  Already installed!"
fi

# ============================================
# 6. Setup Bitwarden & Claude MCP
# ============================================
echo ""
echo "[6/6] Claude Code MCP Setup..."
echo ""
echo "  To complete setup, run these commands:"
echo ""
echo "  # Install & login Bitwarden CLI"
echo "  npm install -g @bitwarden/cli"
echo "  bw login"
echo "  export BW_SESSION=\$(bw unlock --raw)"
echo ""
echo "  # Sync API keys & setup MCP"
echo "  ~/.local/bin/sync-claude-env.sh"
echo "  ~/.local/bin/setup-claude-mcp.sh"
echo ""

# ============================================
# 7. Copy .wslconfig to Windows (if exists)
# ============================================
if [ -f "$HOME/.wslconfig.template" ]; then
    # Try to find Windows user directory
    WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r' || echo "")
    if [ -n "$WIN_USER" ] && [ -d "/mnt/c/Users/$WIN_USER" ]; then
        cp "$HOME/.wslconfig.template" "/mnt/c/Users/$WIN_USER/.wslconfig"
        echo "  .wslconfig copied to Windows (restart WSL with 'wsl --shutdown')"
    fi
fi

echo ""
echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Restart terminal (or run: source ~/.zshrc)"
echo "  2. Run Bitwarden commands above"
echo "  3. Login to Claude: claude login"
echo ""
echo "Warp tip: Save this script URL to Warp Drive for one-click setup!"
echo ""
