#!/bin/bash
# Claude Code MCP Server Setup Script
# Run this on a new machine after installing Claude Code

set -e

echo "Setting up Claude Code MCP servers..."

# Remove existing servers first (ignore errors if they don't exist)
claude mcp remove context7-mcp -s user 2>/dev/null || true
claude mcp remove sequential-thinking -s user 2>/dev/null || true
claude mcp remove chrome-devtools -s user 2>/dev/null || true
claude mcp remove memory-bank -s user 2>/dev/null || true
claude mcp remove neon -s user 2>/dev/null || true

# Add MCP servers
echo "Adding context7-mcp..."
claude mcp add context7-mcp -s user -- npx -y @upstash/context7-mcp@latest

echo "Adding sequential-thinking..."
claude mcp add sequential-thinking -s user -- npx -y @modelcontextprotocol/server-sequential-thinking@latest

echo "Adding chrome-devtools..."
claude mcp add chrome-devtools -s user -- npx -y chrome-devtools-mcp@latest

echo "Adding memory-bank (project-relative storage)..."
claude mcp add memory-bank -s user -e MEMORY_BANK_ROOT=. -- npx -y @allpepper/memory-bank-mcp

# Neon requires API key - try Bitwarden first, then env var
NEON_API_KEY=""

# Try Bitwarden CLI
if command -v bw &> /dev/null && [ -n "$BW_SESSION" ]; then
    echo "Fetching Neon API key from Bitwarden..."
    NEON_API_KEY=$(bw get notes "neon-api-key" 2>/dev/null) || true
fi

# Fallback to environment variable
if [ -z "$NEON_API_KEY" ] && [ -n "$NEON_API_KEY_ENV" ]; then
    NEON_API_KEY="$NEON_API_KEY_ENV"
fi

if [ -n "$NEON_API_KEY" ]; then
    echo "Adding neon..."
    claude mcp add neon -s user -- npx -y @neondatabase/mcp-server-neon start "$NEON_API_KEY"
else
    echo ""
    echo "WARNING: Neon API key not found. Options:"
    echo "  1. Unlock Bitwarden: bw unlock"
    echo "  2. Set env var: export NEON_API_KEY_ENV=your_key"
    echo "  3. Add manually: claude mcp add neon -s user -- npx -y @neondatabase/mcp-server-neon start YOUR_KEY"
fi

echo ""
echo "MCP setup complete! Verify with: claude mcp list"
