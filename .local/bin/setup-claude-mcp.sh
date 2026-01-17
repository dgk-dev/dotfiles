#!/bin/bash
# ============================================
# Claude Code MCP Server Setup Script
# mcp-servers.json 파일을 읽어서 MCP 서버 설정
# API 키는 pass-store에서 주입
# ============================================

set -e

CONFIG_FILE="$HOME/.claude/mcp-servers.json"

echo "Setting up Claude Code MCP servers..."

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found"
    exit 1
fi

# Load API keys from pass (or environment)
load_key() {
    local key_name="$1"
    local value=""

    # Try pass first
    if command -v pass &>/dev/null; then
        value=$(pass show "claude/$key_name" 2>/dev/null || echo "")
    fi

    # Fallback to environment variable
    if [ -z "$value" ]; then
        value="${!key_name:-}"
    fi

    echo "$value"
}

CONTEXT7_API_KEY=$(load_key "CONTEXT7_API_KEY")
NEON_API_KEY=$(load_key "NEON_API_KEY")

# Remove existing servers first
echo "Removing existing MCP servers..."
claude mcp list 2>/dev/null | grep -E "^[a-z]" | awk '{print $1}' | while read server; do
    claude mcp remove "$server" -s user 2>/dev/null || true
done

# Parse JSON and add servers
echo ""
echo "Adding MCP servers from config..."

# Use jq to parse JSON
if ! command -v jq &>/dev/null; then
    echo "Installing jq..."
    sudo apt install -y -qq jq
fi

# Process each server
jq -c '.servers[]' "$CONFIG_FILE" | while read -r server; do
    name=$(echo "$server" | jq -r '.name')
    command=$(echo "$server" | jq -r '.command')
    args=$(echo "$server" | jq -r '.args | join(" ")')

    # Replace placeholders with actual keys
    args=$(echo "$args" | sed "s|\${CONTEXT7_API_KEY}|$CONTEXT7_API_KEY|g")
    args=$(echo "$args" | sed "s|\${NEON_API_KEY}|$NEON_API_KEY|g")

    # Build env arguments
    env_args=""
    if echo "$server" | jq -e '.env' >/dev/null 2>&1; then
        while IFS="=" read -r key value; do
            # Replace placeholders
            value=$(echo "$value" | sed "s|\${CONTEXT7_API_KEY}|$CONTEXT7_API_KEY|g")
            value=$(echo "$value" | sed "s|\${NEON_API_KEY}|$NEON_API_KEY|g")
            if [ -n "$value" ] && [ "$value" != "null" ]; then
                env_args="$env_args -e $key=\"$value\""
            fi
        done < <(echo "$server" | jq -r '.env | to_entries[] | "\(.key)=\(.value)"')
    fi

    # Check if required keys are available
    skip=false
    if [[ "$args" == *'${CONTEXT7_API_KEY}'* ]] || [[ "$env_args" == *'${CONTEXT7_API_KEY}'* ]]; then
        if [ -z "$CONTEXT7_API_KEY" ]; then
            echo "  ✗ $name (CONTEXT7_API_KEY not found - skipped)"
            skip=true
        fi
    fi
    if [[ "$args" == *'${NEON_API_KEY}'* ]]; then
        if [ -z "$NEON_API_KEY" ]; then
            echo "  ✗ $name (NEON_API_KEY not found - skipped)"
            skip=true
        fi
    fi

    if [ "$skip" = false ]; then
        # Build and execute command
        eval "claude mcp add \"$name\" -s user $env_args -- $command $args" 2>/dev/null && \
            echo "  ✓ $name" || echo "  ✗ $name (failed)"
    fi
done

echo ""
echo "============================================"
echo "MCP setup complete!"
echo ""
echo "Verify with: claude mcp list"
