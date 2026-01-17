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
claude mcp list 2>/dev/null | grep -E "^[a-z]" | cut -d: -f1 | while read -r server; do
    [ -n "$server" ] && claude mcp remove "$server" -s user 2>/dev/null || true
done

# Use jq to parse JSON
if ! command -v jq &>/dev/null; then
    echo "Installing jq..."
    sudo apt install -y -qq jq
fi

echo ""
echo "Adding MCP servers from config..."

# Process each server (avoid subshell variable scope issue)
server_count=$(jq '.servers | length' "$CONFIG_FILE")

for ((i=0; i<server_count; i++)); do
    name=$(jq -r ".servers[$i].name" "$CONFIG_FILE")
    cmd=$(jq -r ".servers[$i].command" "$CONFIG_FILE")
    args=$(jq -r ".servers[$i].args | join(\" \")" "$CONFIG_FILE")

    # Replace placeholders with actual keys
    args=$(echo "$args" | sed "s|\${CONTEXT7_API_KEY}|$CONTEXT7_API_KEY|g")
    args=$(echo "$args" | sed "s|\${NEON_API_KEY}|$NEON_API_KEY|g")

    # Build env arguments
    env_args=""
    if jq -e ".servers[$i].env" "$CONFIG_FILE" >/dev/null 2>&1; then
        while IFS="=" read -r key value; do
            [ -z "$key" ] && continue
            # Replace placeholders
            value=$(echo "$value" | sed "s|\${CONTEXT7_API_KEY}|$CONTEXT7_API_KEY|g")
            value=$(echo "$value" | sed "s|\${NEON_API_KEY}|$NEON_API_KEY|g")
            if [ -n "$value" ] && [ "$value" != "null" ]; then
                env_args="$env_args -e $key=$value"
            fi
        done < <(jq -r ".servers[$i].env | to_entries[] | \"\(.key)=\(.value)\"" "$CONFIG_FILE" 2>/dev/null)
    fi

    # Check if required keys are available
    skip=false
    if echo "$args $env_args" | grep -q '\${CONTEXT7_API_KEY}'; then
        echo "  ✗ $name (CONTEXT7_API_KEY not found - skipped)"
        skip=true
    fi
    if echo "$args" | grep -q '\${NEON_API_KEY}'; then
        echo "  ✗ $name (NEON_API_KEY not found - skipped)"
        skip=true
    fi

    if [ "$skip" = false ]; then
        # Build and execute command
        if eval "claude mcp add \"$name\" -s user $env_args -- $cmd $args" 2>/dev/null; then
            echo "  ✓ $name"
        else
            echo "  ✗ $name (failed)"
        fi
    fi
done

echo ""
echo "============================================"
echo "MCP setup complete!"
echo ""
echo "Verify with: claude mcp list"
