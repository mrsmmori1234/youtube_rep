#!/bin/bash
# interactive_dl_embed.sh

MP4_DIR="/mnt/d/Youtube"
LOG_FILE="$HOME/youtube/logs/archive.txt"

# 引数チェック
if [ -z "$1" ]; then
    echo "❌ エラー: URLが指定されていません。"
    echo ""
    echo "Usage: $0 \"URL\""
    echo ""
    echo "⚠️  重要: URLは必ずダブルクォート \" \" で囲んでください。"
    exit 1
fi

url="$1"

mkdir -p "$MP4_DIR"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"

echo "🚀 字幕埋め込みモードでダウンロードを開始します (英語)..."

# 字幕オプション: 日本語と英語を優先的に取得し、srtに変換して埋め込む
SUB_OPTS=(--write-subs --write-auto-subs --sub-langs "en" --convert-subs srt --embed-subs --sleep-subtitles 2)

yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" \
    --merge-output-format mp4 \
    --download-archive "$LOG_FILE" \
    -o "$MP4_DIR/%(title).50s-%(id)s.%(ext)s" \
    --user-agent "$USER_AGENT" \
    "${SUB_OPTS[@]}" \
    "$url"

if [[ $? -eq 0 ]]; then
    echo "✅ ダウンロードと字幕の埋め込みが完了しました。"
else
    echo "❌ ダウンロードに失敗しました: $url"
fi