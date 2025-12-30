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

# Neon requires API key - check if set
if [ -n "$NEON_API_KEY" ]; then
    echo "Adding neon (with API key from env)..."
    claude mcp add neon -s user -- npx -y @neondatabase/mcp-server-neon start "$NEON_API_KEY"
else
    echo ""
    echo "WARNING: NEON_API_KEY not set. Skipping neon server."
    echo "To add manually: claude mcp add neon -s user -- npx -y @neondatabase/mcp-server-neon start YOUR_API_KEY"
fi

echo ""
echo "MCP setup complete! Verify with: claude mcp list"
