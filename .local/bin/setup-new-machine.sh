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

# If running via curl|bash, re-execute from temp file for TTY support
if [ ! -t 0 ] && [ -z "$SETUP_REEXEC" ]; then
    SCRIPT_URL="https://raw.githubusercontent.com/dgk-dev/dotfiles/main/.local/bin/setup-new-machine.sh"
    TEMP_SCRIPT=$(mktemp)
    curl -fsSL "$SCRIPT_URL" -o "$TEMP_SCRIPT"
    chmod +x "$TEMP_SCRIPT"
    SETUP_REEXEC=1 exec bash "$TEMP_SCRIPT"
fi

echo "========================================"
echo "  New Machine Setup (WSL + Claude Code)"
echo "========================================"
echo ""

# ============================================
# 0. Cleanup existing installations
# ============================================
echo "[0/10] Cleaning up existing installations..."

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
echo "[1/10] Checking zsh..."
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
    echo "[2/10] Cloning dotfiles..."
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
    echo "[2/10] Dotfiles already cloned, pulling latest..."
    # Force reset to avoid local changes conflict
    # Note: bare repo doesn't have remote tracking branches, so use FETCH_HEAD
    /usr/bin/git --git-dir="$HOME/.cfg/" --work-tree="$HOME" fetch origin main
    /usr/bin/git --git-dir="$HOME/.cfg/" --work-tree="$HOME" reset --hard FETCH_HEAD
    echo "  Done!"
fi

# ============================================
# 3. Install essential packages
# ============================================
echo ""
echo "[3/10] Installing essential packages..."
sudo apt update -qq
sudo apt install -y -qq curl git unzip keychain eza bat fd-find gnupg pass
echo "  Done!"

# ============================================
# 4. Install GitHub CLI (gh)
# ============================================
echo ""
echo "[4/10] Installing GitHub CLI..."
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
echo "[5/10] Setting up SSH key..."
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
# 6. Setup pass + API keys
# ============================================
echo ""
echo "[6/10] Setting up pass and API keys..."
if [ -f "$HOME/.local/bin/setup-pass.sh" ]; then
    bash "$HOME/.local/bin/setup-pass.sh"
else
    echo "  setup-pass.sh not found, skipping..."
fi

echo ""
echo "[7/10] Installing zoxide..."
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
echo "[8/10] Installing Node.js via fnm..."
if ! command -v fnm &> /dev/null; then
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env)"
    fnm install --lts
    echo "  Done!"
else
    echo "  Already installed!"
fi

# Ensure npm is available (try both fnm and nvm)
export PATH="$HOME/.local/share/fnm:$PATH"
if [ -d "$HOME/.nvm" ]; then
    export PATH="$HOME/.nvm/versions/node/$(basename $HOME/.nvm/*/bin 2>/dev/null | head -1)/bin:$PATH"
elif command -v fnm &> /dev/null; then
    eval "$(fnm env)" >>/dev/null 2>&1 || true
fi

# ============================================
# 8. Install Claude Code (if not present)
# ============================================
echo ""
echo "[9/10] Installing Claude Code..."
if ! command -v claude &> /dev/null; then
    curl -fsSL https://claude.ai/install.sh | bash
    echo "  Done!"
else
    echo "  Already installed!"
fi

# Setup Claude Code MCP servers
echo ""
echo "[9.5/10] Setting up Claude Code MCP servers..."
if [ -f "$HOME/.local/bin/setup-claude-mcp.sh" ]; then
    bash "$HOME/.local/bin/setup-claude-mcp.sh"
else
    echo "  setup-claude-mcp.sh not found, skipping..."
fi

# ============================================
# 9. Setup WSL mirrored networking for Chrome DevTools MCP
# ============================================
echo ""
echo "[10/10] Setting up WSL mirrored networking..."
# Check if .wslconfig already has mirrored mode
WSLCONFIG_EXISTS=$(powershell.exe -Command "Test-Path \"\$env:USERPROFILE\\.wslconfig\"" 2>/dev/null | tr -d '\r')
if [ "$WSLCONFIG_EXISTS" = "True" ]; then
    HAS_MIRRORED=$(powershell.exe -Command "Get-Content \"\$env:USERPROFILE\\.wslconfig\" | Select-String 'networkingMode=mirrored'" 2>/dev/null | tr -d '\r')
    if [ -n "$HAS_MIRRORED" ]; then
        echo "  .wslconfig already configured!"
    else
        # Append mirrored mode to existing config
        powershell.exe -Command "Add-Content -Path \"\$env:USERPROFILE\\.wslconfig\" -Value \"\`n[wsl2]\`nnetworkingMode=mirrored\"" 2>/dev/null
        echo "  Added mirrored networking to .wslconfig"
        NEED_WSL_RESTART=1
    fi
else
    # Create new .wslconfig
    powershell.exe -Command 'Set-Content -Path "$env:USERPROFILE\.wslconfig" -Value "[wsl2]`nnetworkingMode=mirrored"' 2>/dev/null
    echo "  Created .wslconfig with mirrored networking"
    NEED_WSL_RESTART=1
fi

echo ""
echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
if [ "$NEED_WSL_RESTART" = "1" ]; then
echo "  0. Restart WSL: wsl --shutdown (run in PowerShell)"
fi
echo "  1. Restart terminal (or run: source ~/.zshrc)"
echo "  2. Login to Claude: claude login"
echo "  3. For Chrome DevTools MCP: run 'chrome-debug' before 'claude'"
echo ""
echo "Warp tip: Save this script URL to Warp Drive!"
echo ""
