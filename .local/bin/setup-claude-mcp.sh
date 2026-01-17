#!/bin/bash
# ============================================
# Claude Code MCP Server Setup Script
# pass (Password Store)에서 API 키 가져와서 설정
# ============================================

set -e

echo "Setting up Claude Code MCP servers..."

# Load API keys from pass
CONTEXT7_KEY=""
NEON_KEY=""

if command -v pass &> /dev/null; then
    echo "Loading API keys from pass..."
    CONTEXT7_KEY=$(pass show claude/CONTEXT7_API_KEY 2>/dev/null || echo "")
    NEON_KEY=$(pass show claude/NEON_API_KEY 2>/dev/null || echo "")
fi

# Fallback to environment variables
[ -z "$CONTEXT7_KEY" ] && CONTEXT7_KEY="${CONTEXT7_API_KEY:-}"
[ -z "$NEON_KEY" ] && NEON_KEY="${NEON_API_KEY:-}"

# Remove existing servers first (ignore errors if they don't exist)
echo "Removing existing MCP servers..."
claude mcp remove context7-mcp -s user 2>/dev/null || true
claude mcp remove sequential-thinking -s user 2>/dev/null || true
claude mcp remove chrome-devtools -s user 2>/dev/null || true
claude mcp remove memory-bank -s user 2>/dev/null || true
claude mcp remove neon -s user 2>/dev/null || true

# Add MCP servers
echo ""
echo "Adding MCP servers..."

# 1. context7-mcp (requires API key)
if [ -n "$CONTEXT7_KEY" ]; then
    echo "  ✓ context7-mcp (with API key)"
    claude mcp add context7-mcp -s user \
        -e CONTEXT7_API_KEY="$CONTEXT7_KEY" \
        -- npx -y @upstash/context7-mcp@latest
else
    echo "  ✗ context7-mcp (API key not found - skipped)"
    echo "    → 나중에: secrets add CONTEXT7_API_KEY"
fi

# 2. sequential-thinking (no key required)
echo "  ✓ sequential-thinking"
claude mcp add sequential-thinking -s user \
    -- npx -y @modelcontextprotocol/server-sequential-thinking@latest

# 3. chrome-devtools (WSL → Windows Chrome)
echo "  ✓ chrome-devtools (browser-url mode)"
claude mcp add chrome-devtools -s user \
    -- npx -y chrome-devtools-mcp@latest -- --browser-url=http://127.0.0.1:9222

# 4. memory-bank (project-relative storage)
echo "  ✓ memory-bank"
claude mcp add memory-bank -s user \
    -e MEMORY_BANK_ROOT=. \
    -- npx -y @allpepper/memory-bank-mcp

# 5. neon (requires API key)
if [ -n "$NEON_KEY" ]; then
    echo "  ✓ neon (with API key)"
    claude mcp add neon -s user \
        -- npx -y @neondatabase/mcp-server-neon start "$NEON_KEY"
else
    echo "  ✗ neon (API key not found - skipped)"
    echo "    → 나중에: secrets add NEON_API_KEY"
fi

echo ""
echo "============================================"
echo "MCP setup complete!"
echo ""
echo "Verify with: claude mcp list"
echo ""

# Show missing keys warning
missing_keys=()
[ -z "$CONTEXT7_KEY" ] && missing_keys+=("CONTEXT7_API_KEY")
[ -z "$NEON_KEY" ] && missing_keys+=("NEON_API_KEY")

if [ ${#missing_keys[@]} -gt 0 ]; then
    echo "⚠️  Missing API keys:"
    for key in "${missing_keys[@]}"; do
        echo "   - $key"
    done
    echo ""
    echo "Add with: secrets add <KEY_NAME>"
    echo "Then re-run: setup-claude-mcp.sh"
fi
