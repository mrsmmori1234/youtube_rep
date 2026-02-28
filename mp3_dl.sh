#!/bin/bash

# ダウンロード先ディレクトリ
DOWNLOAD_DIR=/mnt/d/Youtube_Music
LOG_FILE=/home/mrsmmori/youtube/logs/downloaded.log

mkdir -p "$DOWNLOAD_DIR"
touch "$LOG_FILE"

while true; do
    # URLを入力
    read -p "ダウンロードするYouTube URLを入力してください（終了は空入力）: " url
    [[ -z "$url" ]] && break

    # 既にログにある場合はスキップ
    if grep -qF "$url" "$LOG_FILE"; then
        echo "既にダウンロード済み: $url"
        continue
    fi

    echo "MP3ダウンロード中: $url"

    # yt-dlpでダウンロード
    yt-dlp --extract-audio --audio-format mp3 --audio-quality 0 --no-video \
        --rm-cache-dir -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" "$url"

    if [ $? -eq 0 ]; then
        echo "$url" >> "$LOG_FILE"
        echo "ダウンロード完了: $url"
    else
        echo "ダウンロード失敗: $url"
    fi
done

# .webmファイルの削除
echo ".webmファイルを削除中..."
find "$DOWNLOAD_DIR" -type f -name "*.webm" -delete

echo "ダウンロードとクリーンアップが完了しました。"

