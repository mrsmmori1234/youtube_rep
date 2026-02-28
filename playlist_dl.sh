#!/bin/bash
# interactive_playlist_dl.sh

OUTBASE="/mnt/d/Youtube"

read -p "ダウンロードするYouTubeプレイリストまたはチャンネルのURLを入力してください: " PLAYLIST_URL
if [ -z "$PLAYLIST_URL" ]; then
    echo "URLが入力されていません。終了します。"
    exit 1
fi

read -p "人気の高い順（再生数順）に並び替えますか？ (y/n): " SORT_CHOICE
SORT_OPTS=""
if [[ "$SORT_CHOICE" == "y" || "$SORT_CHOICE" == "Y" ]]; then
    # 再生数で並び替えるための互換性の高いオプション
    SORT_OPTS="--match-filter !is_live --sort-format view_count"
    echo "💡 人気順（再生回数が多い順）にソートを試みます。"
fi

echo "ダウンロードする件数または範囲を指定してください"
read -p "開始番号 (デフォルト: 1): " START_NUM
read -p "終了番号 (例: 30): " END_NUM

START_NUM=${START_NUM:-1}
RANGE_OPTS="--playlist-start $START_NUM"
if [ -n "$END_NUM" ]; then
    RANGE_OPTS="$RANGE_OPTS --playlist-end $END_NUM"
fi

read -p "字幕もダウンロードしますか？ (y/n): " SUB_CHOICE
SUB_OPTS=""
if [[ "$SUB_CHOICE" == "y" || "$SUB_CHOICE" == "Y" ]]; then
    SUB_OPTS="--write-subs --write-auto-subs --sub-langs ja,en --sub-format srt"
fi

# 実行
# エラー回避のため --order-by ではなく、最新の推奨形式 --parse-metadata 等の代わりに
# 直接 view_count を参照する指定に変更
yt-dlp \
  --format "bv*+ba/b" \
  --merge-output-format mp4 \
  --yes-playlist \
  --match-filter "!is_live" \
  $RANGE_OPTS \
  --download-archive "/home/mrsmmori/youtube/logs/shorts_downloaded.txt" \
  --no-overwrites \
  --output "$OUTBASE/%(uploader)s/%(title)s - %(id)s.%(ext)s" \
  $SUB_OPTS \
  --ignore-errors \
  --sleep-interval 5 \
  --max-sleep-interval 30 \
  --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
  "$PLAYLIST_URL"

echo "✅ 処理が完了しました。保存先: $OUTBASE"
