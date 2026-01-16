#!/bin/bash
# Claude Code Telegram Notification Hook
# Usage: telegram-notify.sh "이모지" "메시지"

EMOJI=$1
MESSAGE=$2

# 환경 변수에서 Bot Token과 Chat ID 읽기
if [ -f ~/.claude/.env.local ]; then
  source ~/.claude/.env.local
fi

# Telegram API 호출
if [ -n "${TELEGRAM_BOT_TOKEN}" ] && [ -n "${TELEGRAM_CHAT_ID}" ]; then
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d "chat_id=${TELEGRAM_CHAT_ID}" \
    -d "text=${EMOJI} ${MESSAGE}" \
    -d "parse_mode=HTML" > /dev/null 2>&1
fi
