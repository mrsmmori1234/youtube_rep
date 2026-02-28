#!/usr/bin/env bash

URL="https://www.youtube.com/watch?v=wdvQ0qmAerA"

if [ -z "$URL" ]; then
  echo "Usage: $0 <youtube_url>"
  exit 1
fi

LOG=$(yt-dlp --simulate -v "$URL" 2>&1)

echo "$LOG"

echo
echo "==== BOT CHECK RESULT ===="

if echo "$LOG" | grep -Eiq "429|not a bot|robot|captcha|suspicious traffic|too many requests"; then
  echo "❌ BOT判定の可能性が高い"
  exit 2
elif echo "$LOG" | grep -Eiq "unable to extract|connection closed"; then
  echo "⚠ グレー（疑われ始めている可能性）"
  exit 1
else
  echo "✅ BOT判定はされていない"
  exit 0
fi
