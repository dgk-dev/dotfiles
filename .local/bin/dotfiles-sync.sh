#!/bin/bash
# Dotfiles 자동 동기화 스크립트
# 변경된 파일이 있으면 자동으로 commit & push

CONFIG="/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME"

# 변경 사항 확인
if $CONFIG diff --quiet HEAD 2>/dev/null; then
    echo "변경 사항 없음"
    exit 0
fi

# 추적 중인 파일만 자동 커밋
$CONFIG add -u
$CONFIG commit -m "auto-sync: $(date '+%Y-%m-%d %H:%M')"
$CONFIG push origin main

echo "✅ Dotfiles 동기화 완료!"
