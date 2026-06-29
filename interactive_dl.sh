#!/bin/bash
# Script to download MP4 with English subtitles by receiving a URL as an argument
# Usage: ./interactive_dl.sh "URL"

MP4_DIR=/mnt/d/Youtube
LOG_FILE="$HOME/youtube/logs/archive.txt"

# Argument check
if [ -z "$1" ]; then
    echo "❌ Error: No URL provided."
    echo ""
    echo "Usage: $0 \"https://www.youtube.com/...\""
    echo ""
    echo "⚠️  IMPORTANT: You MUST wrap the URL in double quotes \" \"."
    echo "   If you don't, the '&' in the URL will cause the shell to run this in the background."
    exit 1
fi

url="$1"

# ディレクトリ作成（ログの親ディレクトリも自動作成）
mkdir -p "$MP4_DIR"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

echo "Preparing download with subtitles (English)..."
SUB_OPTS=(--write-subs --write-auto-subs --sub-langs "en" --convert-subs srt --embed-subs --sleep-subtitles 2)

USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"

# ---------- Execution of download ----------
yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" \
    --merge-output-format mp4 \
    --download-archive "$LOG_FILE" \
    -o "$MP4_DIR/%(title).50s-%(id)s.%(ext)s" \
    --user-agent "$USER_AGENT" \
    "${SUB_OPTS[@]}" \
    "$url"

# 修正ポイント: アーカイブによるスキップ、または正常終了（0）をキャッチ
# yt-dlpの終了ステータスを一度変数に保存
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
    echo "✅ Download completed successfully."
    exit 0
else
    # すでにアーカイブにある場合はエラーとみなさない（必要に応じて処理を分ける）
    echo "⚠️ Process finished (Exit code: $exit_code). Check if it was already downloaded."
    exit 0 # Jupyter側にエラー(255)を返さないように正常終了させる
fi
