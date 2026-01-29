#!/bin/bash
# ============================================
# Claude Code MCP Server Setup Script
# ============================================
#
# SSOT (Single Source of Truth):
#   - MCP 서버 목록: ~/.claude/mcp-servers.json
#   - API 키: pass-store (claude/KEY_NAME)
#
# 동작 방식:
#   1. mcp-servers.json 읽기
#   2. ${KEY_NAME} 패턴 자동 감지
#   3. pass-store에서 해당 키 로드
#   4. 플레이스홀더 대체 후 claude mcp add 실행
#
# 새 MCP 추가 시:
#   1. mcp-servers.json에 서버 추가 (${KEY_NAME} 사용)
#   2. secrets add KEY_NAME
#   3. sync 실행 (또는 터미널 재시작)
#
# ============================================

set -e

CONFIG_FILE="$HOME/.claude/mcp-servers.json"

echo "Setting up Claude Code MCP servers..."

# ============================================
# 1. Config 파일 확인
# ============================================
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found"
    exit 1
fi

# jq 필수
if ! command -v jq &>/dev/null; then
    echo "Installing jq..."
    sudo apt install -y -qq jq
fi

# ============================================
# 2. 동적 키 로딩 함수
# ============================================
# pass-store에서 키 로드 (fallback: 환경변수)
load_key() {
    local key_name="$1"
    local value=""

    if command -v pass &>/dev/null; then
        value=$(pass show "claude/$key_name" 2>/dev/null || echo "")
    fi

    [ -z "$value" ] && value="${!key_name:-}"
    echo "$value"
}

# 문자열에서 ${KEY_NAME} 패턴을 찾아 pass-store 값으로 대체
substitute_keys() {
    local input="$1"
    local result="$input"

    # ${...} 패턴 추출 후 각각 대체 (숫자 포함 변수명 지원)
    while [[ "$result" =~ \$\{([a-zA-Z_][a-zA-Z_0-9]*)\} ]]; do
        local key_name="${BASH_REMATCH[1]}"
        local key_value=$(load_key "$key_name")

        if [ -n "$key_value" ]; then
            result="${result//\$\{$key_name\}/$key_value}"
        else
            # 키를 찾지 못하면 루프 종료 (무한루프 방지)
            break
        fi
    done

    echo "$result"
}

# ============================================
# 3. 기존 MCP 서버 제거
# ============================================
echo "Removing existing MCP servers..."
claude mcp list 2>/dev/null | grep -E "^[a-z]" | cut -d: -f1 | while read -r server; do
    [ -n "$server" ] && claude mcp remove "$server" -s user 2>/dev/null || true
done

# ============================================
# 4. mcp-servers.json에서 서버 추가
# ============================================
echo ""
echo "Adding MCP servers from config..."

server_count=$(jq '.servers | length' "$CONFIG_FILE")

for ((i=0; i<server_count; i++)); do
    name=$(jq -r ".servers[$i].name" "$CONFIG_FILE")
    cmd=$(jq -r ".servers[$i].command" "$CONFIG_FILE")

    # args를 JSON 문자열로 가져와서 키 대체
    args_raw=$(jq -r ".servers[$i].args | join(\" \")" "$CONFIG_FILE")
    args=$(substitute_keys "$args_raw")

    # 미해결 플레이스홀더 확인 (키 없음)
    if [[ "$args" =~ \$\{([a-zA-Z_][a-zA-Z_0-9]*)\} ]]; then
        echo "  ✗ $name (${BASH_REMATCH[1]} not found - skipped)"
        continue
    fi

    # env 처리
    env_args=""
    if jq -e ".servers[$i].env" "$CONFIG_FILE" >/dev/null 2>&1; then
        while IFS="=" read -r key value; do
            [ -z "$key" ] && continue
            value=$(substitute_keys "$value")

            # 미해결 플레이스홀더 확인
            if [[ "$value" =~ \$\{([a-zA-Z_][a-zA-Z_0-9]*)\} ]]; then
                echo "  ✗ $name (${BASH_REMATCH[1]} not found - skipped)"
                continue 2
            fi

            [ -n "$value" ] && [ "$value" != "null" ] && env_args="$env_args -e $key=$value"
        done < <(jq -r ".servers[$i].env | to_entries[] | \"\(.key)=\(.value)\"" "$CONFIG_FILE" 2>/dev/null)
    fi

    # MCP 서버 추가
    if eval "claude mcp add \"$name\" -s user $env_args -- $cmd $args" 2>/dev/null; then
        echo "  ✓ $name"
    else
        echo "  ✗ $name (failed)"
    fi
done

# ============================================
# 5. Remote MCP 서버 추가 (OAuth 방식)
# ============================================
echo ""
echo "Adding remote MCP servers..."

# Sentry - OAuth 인증 (각 PC에서 최초 1회 브라우저 인증 필요)
if claude mcp add --transport http sentry https://mcp.sentry.dev/mcp -s user 2>/dev/null; then
    echo "  ✓ sentry (remote)"
else
    echo "  ✗ sentry (failed)"
fi

echo ""
echo "============================================"
echo "MCP setup complete!"
echo "Verify with: claude mcp list"
