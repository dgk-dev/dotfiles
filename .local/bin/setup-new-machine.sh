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
echo "[3/9] Installing essential packages..."
sudo apt update -qq
sudo apt install -y -qq curl git unzip keychain eza bat fd-find
echo "  Done!"

# ============================================
# 4. Install GitHub CLI (gh)
# ============================================
echo ""
echo "[4/9] Installing GitHub CLI..."
if ! command -v gh &> /dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update -qq
    sudo apt install -y -qq gh
    echo "  Done!"
else
    echo "  Already installed!"
fi

# ============================================
# 5. Setup SSH Key + GitHub Registration
# ============================================
echo ""
echo "[5/9] Setting up SSH key..."
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "  Generating new SSH key..."
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "dgk.dev@gmail.com" -f "$HOME/.ssh/id_ed25519" -N ""
    echo "  Done!"
else
    echo "  SSH key already exists!"
fi

# Register SSH key with GitHub
echo ""
echo "  Registering SSH key with GitHub..."
if ! gh auth status &>/dev/null; then
    echo "  Please login to GitHub:"
    gh auth login -p ssh -h github.com -w
fi

# Add SSH key to GitHub if not already added
KEY_TITLE="WSL-$(hostname)-$(date +%Y%m%d)"
if ! gh ssh-key list | grep -q "$(cat ~/.ssh/id_ed25519.pub | awk '{print $2}')"; then
    gh ssh-key add ~/.ssh/id_ed25519.pub --title "$KEY_TITLE"
    echo "  SSH key added to GitHub!"
else
    echo "  SSH key already registered!"  
fi

# ============================================
# 6. Install zoxide (if not present)
# ============================================
echo ""
echo "[6/9] Installing zoxide..."
if ! command -v zoxide &> /dev/null; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    echo "  Done!"
else
    echo "  Already installed!"
fi

# ============================================
# 7. Install Node.js via fnm (if not present)
# ============================================
echo ""
echo "[7/9] Installing Node.js via fnm..."
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
# 8. Install Claude Code (if not present)
# ============================================
echo ""
echo "[8/9] Installing Claude Code..."
if ! command -v claude &> /dev/null; then
    npm install -g @anthropic-ai/claude-code
    echo "  Done!"
else
    echo "  Already installed!"
fi

# ============================================
# 9. Copy .wslconfig to Windows (if exists)
# ============================================
echo ""
echo "[9/9] Copying .wslconfig to Windows..."
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
echo "  2. Login to Claude: claude login"
echo "  3. Setup API keys in ~/.claude/.env.local"
echo ""
echo "Warp tip: Save this script URL to Warp Drive!"
echo ""
