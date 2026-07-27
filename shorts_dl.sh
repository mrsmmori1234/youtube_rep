#!/bin/bash
# shorts_dl.sh
# Batch download of Shorts from a channel (no subtitles, optimized for speed/size)

# Base directory for saving
OUTBASE="/mnt/d/Youtube"
LOG_FILE="$HOME/youtube/logs/downloaded.txt"

mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# 1. Pythonの引数($1)からURLを取得する（なければその場で入力を促すフォールバック）
if [ -n "$1" ]; then
    SHORTS_URL="$1"
else
    read -p "Enter the YouTube Shorts / Channel URL to download: " SHORTS_URL
fi

# Exit if input is empty
if [ -z "$SHORTS_URL" ]; then
    echo "No URL entered. Exiting."
    exit 1
fi

# Execute yt-dlp (画質上限を720pに制限し、mp4互換で高速結合)
yt-dlp \
  --sleep-requests 1 \
  --sleep-interval 1 \
  --max-sleep-interval 10 \
  --format "bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/best[height<=720][ext=mp4]/best" \
  --merge-output-format mp4 \
  --yes-playlist \
  --match-filter "original_url *= '/shorts/'" \
  --download-archive "$LOG_FILE" \
  --no-overwrites \
  --output "$OUTBASE/%(channel)s/Shorts/%(upload_date)s - %(title)s - %(id)s.%(ext)s" \
  "$SHORTS_URL"

echo "✅ Shorts download completed. Saved to: $OUTBASE"
