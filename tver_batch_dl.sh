#!/bin/bash

# TVer一括ダウンロードスクリプト（字幕なし）

URL_FILE="tver_urls.txt"
MP4_DIR=/mnt/d/TVer
LOG_FILE=/home/mrsmmori/youtube/logs/tver_downloaded.log

mkdir -p "$MP4_DIR"
touch "$LOG_FILE"

if [ ! -f "$URL_FILE" ]; then
    echo "❌ URLリストファイル $URL_FILE が見つかりません。"
    exit 1
fi

while IFS= read -r url; do
    # 空行スキップ
    [[ -z "$url" ]] && continue

    # 既に処理済みか確認（ログ）
    if grep -qF "$url" "$LOG_FILE"; then
        echo "✅ 既に処理済み: $url"
        continue
    fi

    RAW_TITLE=$(yt-dlp --get-title "$url" 2>/dev/null)
    SAFE_TITLE=$(echo "$RAW_TITLE" | tr -d '/\?%*:|"<>')
    SAFE_TITLE=${SAFE_TITLE:0:50}
    FILE_PATH="$MP4_DIR/${SAFE_TITLE}-$(yt-dlp --get-id "$url").mp4"

    # 実際にファイルが存在するか確認
    if [ -f "$FILE_PATH" ]; then
        echo "✅ 既に保存済み: $FILE_PATH"
        echo "$url | $(basename "$FILE_PATH")" >> "$LOG_FILE"
        continue
    fi

    echo "▶️ ダウンロード開始: $SAFE_TITLE"

    yt-dlp \
        --merge-output-format mp4 \
        --ffmpeg-location /usr/bin/ffmpeg \
        -o "$MP4_DIR/${SAFE_TITLE}-%(id)s.%(ext)s" \
        "$url"

    if [ $? -eq 0 ]; then
        echo "$url | ${SAFE_TITLE}-%(id)s.mp4" >> "$LOG_FILE"
        echo "✅ ダウンロード完了: $SAFE_TITLE"
    else
        echo "❌ ダウンロード失敗: $url"
        echo "ℹ️ フォーマット一覧を確認するには:"
        echo "   yt-dlp -F \"$url\""
    fi

done < "$URL_FILE"

echo "🎉 一括ダウンロード処理が完了しました。"

