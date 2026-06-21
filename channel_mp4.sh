#!/bin/bash
# channel_mp4.sh
# Download only the latest 2 videos from each URL, skip existing
# Subtitles in English only (if flag is y)

# 絶対パスを定義することで Jupyter/Cron 等からの実行を安定させます
USER_HOME="/home/mrsmmori"
BASE_DIR="$USER_HOME/youtube"
OUTBASE="/mnt/d/Youtube"
DOWNLOAD_ARCHIVE="$BASE_DIR/logs/archive.txt"
OUTPUT_TEMPLATE="$OUTBASE/%(playlist_title)s/%(upload_date>%Y-%m-%d)s - %(title)s - %(id)s.%(ext)s"
CHANNEL_LIST="$BASE_DIR/channels.txt"

# 仮想環境の yt-dlp を直接指定（パス解決の失敗を防ぐ）
FFMPEG_PATH=$(command -v ffmpeg || echo "/usr/bin/ffmpeg")
# 必要なバイナリ（ffmpeg等）が含まれるパスを確実に追加
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$USER_HOME/.local/bin:$PATH"

# プログレスバーの制御文字が Jupyter でエラーを起こさないよう環境変数を設定
export PYTHONUNBUFFERED=1

# 文字コードとロケールを固定し、日本語タイトルの処理を安定させる
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

YT_DLP="$USER_HOME/.pyenv/versions/3.12.2/envs/youtube-env/bin/yt-dlp"
if [ ! -x "$YT_DLP" ]; then
    YT_DLP="yt-dlp" # フォールバック
fi

if [ ! -f "$CHANNEL_LIST" ]; then
    echo "❌ Error: Channel list file not found: $CHANNEL_LIST"
    exit 1
fi

if ! command -v "$YT_DLP" &> /dev/null; then
    echo "❌ Error: yt-dlp not found. Make sure the virtualenv is activated correctly."
    exit 1
fi

mkdir -p "$OUTBASE"
touch "$DOWNLOAD_ARCHIVE"

# Read from file, ignoring comments (#) and empty lines
mapfile -t CHANNELS < <(grep -v -E '^\s*#|^\s*$' "$CHANNEL_LIST" || true)

for entry in "${CHANNELS[@]}"; do
    # Extract URL and flag. Defaults flag to 'n' if no '|' is present.
    if [[ "$entry" == *"|"* ]]; then
        url="${entry%%|*}"
        flag="${entry##*|}"
    else
        url="$entry"
        flag="n"
    fi

    # 改行コード(\r)を除去してクリーンアップ
    url=$(echo "$url" | tr -d '\r')

    [[ -z "$url" ]] && continue

    echo "----"
    echo "Processing: $url (subs=$flag)"

    if [[ "$flag" =~ ^([yY])$ ]]; then
        SUB_OPTS=( --write-subs --write-auto-subs --sub-lang "en" --sub-format srt --convert-subs srt --embed-subs )
    else
        SUB_OPTS=()
    fi

    # Execute DL
    "$YT_DLP" \
      --format "bestvideo[height<=720]+bestaudio/best[height<=720]" \
      --merge-output-format mp4 \
      --download-archive "$DOWNLOAD_ARCHIVE" \
      --no-overwrites \
      --playlist-end 2 \
      --ignore-errors \
      --no-progress \
      --no-warnings \
      --newline \
      --ffmpeg-location "$FFMPEG_PATH" \
      --output "$OUTPUT_TEMPLATE" \
      "${SUB_OPTS[@]}" \
      "$url"

    echo "Completed: $url"
done

echo "✅ All processes completed"
exit 0
