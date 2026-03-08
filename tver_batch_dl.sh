#!/bin/bash

# TVer batch download script (no subtitles)

URL_FILE="/home/mrsmmori/youtube/tver_urls.txt"
MP4_DIR="/mnt/d/TVer"
LOG_FILE="$HOME/youtube/logs/archive.txt" # 複数のスクリプトでDL履歴を共有

mkdir -p "$MP4_DIR"
touch "$LOG_FILE"

if [ ! -f "$URL_FILE" ]; then
    echo "❌ URLリストファイルが見つかりません: $URL_FILE"
    exit 1
fi

echo "▶️ バッチダウンロードを開始します。ダウンロード済みのファイルは高速にスキップされます。"

# whileループを廃止し、-a (--batch-file) オプションでURLリストを直接yt-dlpに渡します。
# これにより、yt-dlpの起動が1回で済み、大幅に高速化されます。
# --download-archive がダウンロード済みIDを記録し、次回以降の実行時に瞬時にスキップします。
# ファイル名の整形 (-o) もyt-dlpの機能で行い、外部コマンド呼び出しをなくします。
yt-dlp \
    -a "$URL_FILE" \
    --merge-output-format mp4 \
    --ffmpeg-location /usr/bin/ffmpeg \
    --download-archive "$LOG_FILE" \
    --no-overwrites \
    --ignore-errors \
    -o "$MP4_DIR/%(title:.50)s-%(id)s.%(ext)s"

echo "🎉 バッチダウンロード処理が完了しました。"
