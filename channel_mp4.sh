#!/bin/bash
# channel_mp4.sh
# 各URLから最新2本だけダウンロード、既存はスキップ
# 字幕は英語のみ

OUTBASE="/mnt/d/Youtube"
DOWNLOAD_ARCHIVE="/home/mrsmmori/youtube/logs/downloaded.txt"
OUTPUT_TEMPLATE="$OUTBASE/%(playlist_title)s/%(upload_date>%Y-%m-%d)s - %(title)s - %(id)s.%(ext)s"

CHANNELS=(
  "https://www.youtube.com/@ShigeTravel/videos|n"
  "https://www.youtube.com/@BappaShota/videos|n"
  "https://www.youtube.com/@iketomo-ch/videos|n"
  "https://www.youtube.com/@ai_masaou/videos|n"
)

mkdir -p "$OUTBASE"
touch "$DOWNLOAD_ARCHIVE"

for entry in "${CHANNELS[@]}"; do
    url="${entry%%|*}"
    flag="${entry##*|}"

    echo "----"
    echo "処理中: $url (subs=$flag)"

    if [[ "$flag" =~ ^([yY])$ ]]; then
        SUB_OPTS=( --write-subs --write-auto-subs --sub-lang "en" --sub-format srt --convert-subs srt )
    else
        SUB_OPTS=()
    fi

    # 最新2本の動画IDを取得
    ids=$(yt-dlp --get-id --playlist-end 2 "$url")

    # すべて既にDL済みかチェック
    all_downloaded=true
    for id in $ids; do
        if ! grep -q "$id" "$DOWNLOAD_ARCHIVE"; then
            all_downloaded=false
            break
        fi
    done

    if $all_downloaded; then
        echo "➡️ 最新2本はすでにDL済み。スキップします。"
        continue
    fi

    # DL実行
    yt-dlp \
      --format "bestvideo+bestaudio/best" \
      --merge-output-format mp4 \
      --download-archive "$DOWNLOAD_ARCHIVE" \
      --no-overwrites \
      --playlist-end 2 \
      --ignore-errors \
      --output "$OUTPUT_TEMPLATE" \
      "${SUB_OPTS[@]}" \
      "$url"

    echo "完了: $url"
done

echo "✅ 全処理完了"

