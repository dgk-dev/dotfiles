#!/bin/bash
# ============================================
# API 키 입력 및 저장 스크립트
# pass (Password Store) 사용 - 업계 표준
# ============================================

set -e

STORE_DIR="$HOME/.password-store"
SECRETS_DIR="$STORE_DIR/claude"

# 필요한 API 키 목록
SECRETS=(
    "CONTEXT7_API_KEY"
    "NEON_API_KEY"
    "TELEGRAM_BOT_TOKEN"
    "TELEGRAM_CHAT_ID"
)

echo ""
echo "=========================================="
echo "  API 키 설정 (Password Store)"
echo "=========================================="
echo ""
echo "각 API 키를 입력하세요. 없으면 Enter로 건너뛰세요."
echo ""

changed=false

for secret in "${SECRETS[@]}"; do
    # 기존 값 확인
    existing=$(pass show "claude/$secret" 2>/dev/null || echo "")
    
    if [ -n "$existing" ]; then
        echo "✓ $secret: 이미 설정됨 (변경하려면 값 입력, 유지하려면 Enter)"
    else
        echo "○ $secret: 미설정"
    fi
    
    read -s -p "  값: " value
    echo ""
    
    if [ -n "$value" ]; then
        echo "$value" | pass insert -f "claude/$secret" > /dev/null 2>&1
        echo "  → 저장됨"
        changed=true
    fi
done

# 변경사항 있으면 push
if [ "$changed" = true ]; then
    echo ""
    echo "변경사항을 원격 저장소에 동기화 중..."
    cd "$STORE_DIR"
    git add -A
    git commit -m "Update secrets from $(hostname)" 2>/dev/null || true
    git push origin main 2>/dev/null || echo "  (push 실패 - 나중에 수동으로)"
fi

echo ""
echo "✅ 완료!"
