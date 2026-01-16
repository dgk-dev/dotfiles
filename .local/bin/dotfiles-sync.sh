#!/bin/bash
# Dotfiles 양방향 동기화 스크립트
# Remote 먼저 pull → 로컬 변경 push

CONFIG="/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME"
LOCK_FILE="/tmp/dotfiles-sync.lock"
LAST_SYNC="$HOME/.local/log/dotfiles-last-sync"

# 로그 디렉토리 생성
mkdir -p "$HOME/.local/log"

# 최근 5분 이내 동기화했으면 건너뛰기
if [ -f "$LAST_SYNC" ]; then
    LAST_TIME=$(cat "$LAST_SYNC" 2>/dev/null)
    LAST_EPOCH=$(date -d "$LAST_TIME" +%s 2>/dev/null || echo 0)
    NOW_EPOCH=$(date +%s)
    DIFF=$((NOW_EPOCH - LAST_EPOCH))
    if [ $DIFF -lt 300 ]; then
        exit 0
    fi
fi

# 중복 실행 방지
if [ -f "$LOCK_FILE" ]; then
    exit 0
fi
touch "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

# 1. Remote에서 먼저 pull (remote가 항상 우선)
$CONFIG pull --rebase origin main 2>/dev/null || true

# 2. 로컬 변경 사항 확인
if ! $CONFIG diff --quiet HEAD 2>/dev/null; then
    # 추적 중인 파일만 자동 커밋
    $CONFIG add -u
    $CONFIG commit -m "auto-sync: $(hostname) $(date '+%Y-%m-%d %H:%M')" 2>/dev/null || true
    $CONFIG push origin main 2>/dev/null
    echo "✅ Dotfiles synced"
else
    echo "✅ Dotfiles up to date"
fi

# 마지막 동기화 시간 기록
date > "$LAST_SYNC"
