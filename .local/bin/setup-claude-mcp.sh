#!/bin/bash
# ============================================
# Claude Code MCP Server Setup Script v2.0
# ============================================
#
# 변경점 (v2.0):
#   - claude mcp add 대신 ~/.claude.json 직접 수정
#   - mcp-servers.json → mcp-config.json 으로 SSOT 변경
#   - 더 빠르고 안정적인 동기화
#
# SSOT (Single Source of Truth):
#   - MCP 서버 목록: ~/.claude/mcp-config.json
#   - API 키: ~/.claude/.env.local 또는 pass-store
#
# 동작 방식:
#   1. mcp-config.json 읽기
#   2. ${KEY_NAME} 패턴을 환경변수/pass-store 값으로 대체
#   3. ~/.claude.json의 mcpServers에 병합
#
# 새 MCP 추가 시:
#   1. mcp-config.json에 서버 추가
#   2. 필요시 .env.local에 API 키 추가
#   3. setup-claude-mcp.sh 실행
#
# ============================================

set -e

CONFIG_FILE="$HOME/.claude/mcp-config.json"
CLAUDE_JSON="$HOME/.claude.json"
ENV_FILE="$HOME/.claude/.env.local"

echo "🔧 Claude Code MCP Setup v2.0"
echo "============================================"

# ============================================
# 1. 필수 파일 확인
# ============================================
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: $CONFIG_FILE not found"
    exit 1
fi

if [ ! -f "$CLAUDE_JSON" ]; then
    echo "❌ Error: $CLAUDE_JSON not found"
    echo "   Claude Code를 먼저 실행해주세요."
    exit 1
fi

# jq 필수
if ! command -v jq &>/dev/null; then
    echo "📦 Installing jq..."
    sudo apt install -y -qq jq
fi

# ============================================
# 2. 환경변수 로드
# ============================================
if [ -f "$ENV_FILE" ]; then
    echo "📂 Loading environment from $ENV_FILE"
    set -a
    source "$ENV_FILE"
    set +a
fi

# ============================================
# 3. pass-store에서 키 로드 함수
# ============================================
load_key() {
    local key_name="$1"
    local value=""

    # 먼저 환경변수 확인
    value="${!key_name:-}"

    # 환경변수 없으면 pass-store 시도
    if [ -z "$value" ] && command -v pass &>/dev/null; then
        value=$(pass show "claude/$key_name" 2>/dev/null || echo "")
    fi

    echo "$value"
}

# ============================================
# 4. MCP 설정 처리
# ============================================
echo ""
echo "📋 Processing MCP servers..."

# mcp-config.json 읽기
mcp_config=$(cat "$CONFIG_FILE")

# 각 서버의 env에서 ${VAR} 패턴을 실제 값으로 대체
servers=$(echo "$mcp_config" | jq -r '.mcpServers | keys[]')

processed_servers="{}"

for server in $servers; do
    server_config=$(echo "$mcp_config" | jq ".mcpServers[\"$server\"]")

    # args 배열에서 ${VAR} 패턴 처리
    if echo "$server_config" | jq -e '.args' >/dev/null 2>&1; then
        args_count=$(echo "$server_config" | jq '.args | length')
        for ((i=0; i<args_count; i++)); do
            arg_value=$(echo "$server_config" | jq -r ".args[$i]")

            # ${VAR} 패턴 확인 및 대체
            if [[ "$arg_value" =~ ^\$\{([a-zA-Z_][a-zA-Z_0-9]*)\}$ ]]; then
                var_name="${BASH_REMATCH[1]}"
                actual_value=$(load_key "$var_name")

                if [ -n "$actual_value" ]; then
                    server_config=$(echo "$server_config" | jq ".args[$i] = \"$actual_value\"")
                else
                    echo "  ⚠️  $server: $var_name not found in args"
                fi
            fi
        done
    fi

    # env 객체가 있는 경우 처리
    if echo "$server_config" | jq -e '.env' >/dev/null 2>&1; then
        env_keys=$(echo "$server_config" | jq -r '.env | keys[]' 2>/dev/null || echo "")

        for env_key in $env_keys; do
            env_value=$(echo "$server_config" | jq -r ".env[\"$env_key\"]")

            # ${VAR} 패턴 확인 및 대체
            if [[ "$env_value" =~ ^\$\{([a-zA-Z_][a-zA-Z_0-9]*)\}$ ]]; then
                var_name="${BASH_REMATCH[1]}"
                actual_value=$(load_key "$var_name")

                if [ -n "$actual_value" ]; then
                    server_config=$(echo "$server_config" | jq ".env[\"$env_key\"] = \"$actual_value\"")
                else
                    echo "  ⚠️  $server: $var_name not found (skipping env var)"
                    server_config=$(echo "$server_config" | jq "del(.env[\"$env_key\"])")
                fi
            fi
        done

        # 빈 env 객체 정리
        if [ "$(echo "$server_config" | jq '.env | length')" -eq 0 ]; then
            server_config=$(echo "$server_config" | jq 'del(.env)')
        fi
    fi

    processed_servers=$(echo "$processed_servers" | jq ". + {\"$server\": $server_config}")
    echo "  ✓ $server"
done

# ============================================
# 5. ~/.claude.json 업데이트
# ============================================
echo ""
echo "💾 Updating $CLAUDE_JSON..."

# 백업 생성
cp "$CLAUDE_JSON" "$CLAUDE_JSON.bak"

# mcpServers 업데이트
updated_json=$(cat "$CLAUDE_JSON" | jq ".mcpServers = $processed_servers")

# 저장
echo "$updated_json" > "$CLAUDE_JSON"

echo ""
echo "============================================"
echo "✅ MCP setup complete!"
echo ""
echo "📝 Configured servers:"
echo "$processed_servers" | jq -r 'keys[]' | sed 's/^/   - /'
echo ""
echo "🔄 Claude Code를 재시작하면 적용됩니다."
echo "   또는 /mcp 명령어로 확인하세요."
