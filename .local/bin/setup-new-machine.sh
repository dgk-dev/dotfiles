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
# 0. Cleanup existing installations
# ============================================
echo "[0/7] Cleaning up existing installations..."

# Remove oh-my-zsh if exists (Warp replaces it)
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "  Removing oh-my-zsh..."
    rm -rf "$HOME/.oh-my-zsh"
fi

# Remove old zsh plugins (will use Warp's features)
rm -rf "$HOME/.zsh" 2>/dev/null || true
rm -f "$HOME/.zcompdump"* 2>/dev/null || true

# Remove starship (Warp has built-in prompt)
rm -f "$HOME/.config/starship.toml" 2>/dev/null || true

# Remove fzf (Warp has built-in fuzzy finder)
rm -rf "$HOME/.fzf" 2>/dev/null || true
rm -f "$HOME/.fzf.zsh" 2>/dev/null || true
rm -f "$HOME/.fzf.bash" 2>/dev/null || true

echo "  Done!"

# ============================================
# 1. Install zsh if not present
# ============================================
echo ""
echo "[1/8] Checking zsh..."
if ! command -v zsh &> /dev/null; then
    echo "  Installing zsh..."
    sudo apt update -qq
    sudo apt install -y -qq zsh
    chsh -s $(which zsh)
    echo "  Done!"
else
    echo "  Already installed!"
fi

# ============================================
# 2. Check if dotfiles already cloned
# ============================================
if [ ! -d "$HOME/.cfg" ]; then
    echo "[2/8] Cloning dotfiles..."
    git clone --bare https://github.com/dgk-dev/dotfiles.git "$HOME/.cfg"

    # Setup gopass password store from GitHub
    if ! [ -d "$HOME/.password-store" ]; then
        echo "  Setting up gopass password store..."
        gopass clone git@github.com:dgk-dev/gopass.git "$HOME/.password-store" 2>/dev/null || true
    fi

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
    echo "[2/8] Dotfiles already cloned, pulling latest..."
    /usr/bin/git --git-dir="$HOME/.cfg/" --work-tree="$HOME" pull origin main
    echo "  Done!"
fi

# ============================================
# 3. Install essential packages
# ============================================
echo ""
echo "[3/8] Installing essential packages..."
sudo apt update -qq
sudo apt install -y -qq curl git unzip keychain eza bat fd-find gopass
echo "  Done!"

# ============================================
# 4. Install zoxide (if not present)
# ============================================
echo ""
echo "[4/8] Installing zoxide..."
if ! command -v zoxide &> /dev/null; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    echo "  Done!"
else
    echo "  Already installed!"
fi

# ============================================
# 5. Install Node.js via fnm (if not present)
# ============================================
echo ""
echo "[5/8] Installing Node.js via fnm..."
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
# 6. Install Claude Code (if not present)
# ============================================
echo ""
echo "[6/8] Installing Claude Code..."
if ! command -v claude &> /dev/null; then
    npm install -g @anthropic-ai/claude-code
    echo "  Done!"
else
    echo "  Already installed!"
fi

# ============================================
# 7. Setup gopass config
# ============================================
echo ""
echo "[7/8] Setting up gopass configuration..."
if [ ! -f "$HOME/.config/gopass/config.yml" ]; then
    mkdir -p "$HOME/.config/gopass"
    cat > "$HOME/.config/gopass/config.yml" << 'EOF'
autosync: true
autoclip: true
autoclip_time: 45
noconfirm: false
notifications: true
safecontent: false
EOF
    echo "  Done!"
else
    echo "  Config already exists!"
fi

# ============================================
# 8. Setup Claude MCP
# ============================================
echo ""
echo "[8/8] Claude Code MCP Setup..."
echo ""
echo "  To complete setup, run these commands:"
echo ""
echo "  # Verify gopass is synced"
echo "  gopass sync"
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
echo "  2. Verify gopass: gopass ls"
echo "  3. Login to Claude: claude login"
echo ""
echo "Warp tip: Save this script URL to Warp Drive for one-click setup!"
echo ""
