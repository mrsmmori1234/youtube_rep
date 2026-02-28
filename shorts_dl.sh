#!/bin/bash
# shorts_dl.sh
# チャンネルの Shorts 一括ダウンロード（字幕なし）

# 保存先のベースディレクトリ
OUTBASE="/mnt/d/Youtube"

# ユーザーに入力を促す
read -p "ダウンロードするYouTube ShortsのURLを入力してください: " SHORTS_URL

# 入力が空なら終了
if [ -z "$SHORTS_URL" ]; then
    echo "URLが入力されていません。終了します。"
    exit 1
fi

# yt-dlp 実行
yt-dlp \
  --format "bestvideo+bestaudio/best" \
  --merge-output-format mp4 \
  --yes-playlist \
  --download-archive "/home/mrsmmori/youtube/logs/shorts_downloaded.txt" \
  --no-overwrites \
  --output "$OUTBASE/%(channel)s/Shorts/%(upload_date)s - %(title)s - %(id)s.%(ext)s" \
  "$SHORTS_URL"

echo "✅ Shorts ダウンロード完了しました。保存先: $OUTBASE"

