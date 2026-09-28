#!/bin/bash
# Script to download MP4 with optional English subtitles
# Usage: ./interactive_dl.sh [-y] "URL"

MP4_DIR="/mnt/d/Youtube"
LOG_FILE="$HOME/youtube/logs/archive.txt"
COOKIES_FILE="$HOME/youtube/cookies.txt"

# ---------- 1. オプション解析 (-y フラグ) ----------
DL_SUBS=false

while getopts "y" opt; do
  case ${opt} in
    y )
      DL_SUBS=true
      ;;
    \? )
      echo "Usage: $0 [-y] \"URL\""
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# ---------- 2. URL引数チェック ----------
if [ -z "$1" ]; then
    echo "❌ Error: No URL provided."
    echo ""
    echo "Usage: $0 [-y] \"https://www.youtube.com/...\""
    echo "       -y : Download English subtitles"
    echo ""
    echo "⚠️  IMPORTANT: You MUST wrap the URL in double quotes \" \"."
    echo "    If you don't, the '&' in the URL will cause the shell to run this in the background."
    exit 1
fi

url="$1"

# ディレクトリおよび必要なファイルの準備
mkdir -p "$MP4_DIR"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# ---------- 3. 基本オプション設定 ----------
YTDLP_OPTS=(
    # --- フォーマット・出力設定 ---
    -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]"
    --merge-output-format mp4
    --download-archive "$LOG_FILE"
    -o "$MP4_DIR/%(title).50s-%(id)s.%(ext)s"

    # --- 429 Error / BAN対策（レートリミット・ウェイト） ---
    --sleep-requests 1.5           # APIリクエスト間のウェイト(秒)
    --sleep-interval 3              # ダウンロード間の最低待機(秒)
    --max-sleep-interval 8          # ダウンロード間の最大待機(秒 - ランダム化)
    --limit-rate 10M               # 通信速度を10MB/sに抑えてボット検知を回避

    # --- ブラウザヘッダー設定 ---
    --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
)

# ---------- 4. 字幕オプションの条件追加 ----------
if [ "$DL_SUBS" = true ]; then
    echo "📝 Subtitle download enabled (English)."
    YTDLP_OPTS+=(
        --write-subs
        --write-auto-subs
        --sub-langs "en"
        --convert-subs srt
        --embed-subs
        --sleep-subtitles 2
    )
else
    echo "🚀 Subtitle download skipped (Use -y to enable)."
fi

# ---------- 5. Cookiesの適用 ----------
if [ -f "$COOKIES_FILE" ]; then
    echo "🍪 Using cookies from $COOKIES_FILE"
    YTDLP_OPTS+=(--cookies "$COOKIES_FILE")
fi

# ---------- 6. Impersonate ターゲットの判定 ----------
AVAILABLE_TARGET=$(yt-dlp --list-impersonate-targets 2>/dev/null | grep -E "chrome" | head -n 1 | awk '{print $1}')

if [ -n "$AVAILABLE_TARGET" ]; then
    echo "🎭 Using impersonate target: $AVAILABLE_TARGET"
    YTDLP_OPTS+=(--impersonate "$AVAILABLE_TARGET")
fi

# ---------- 7. ダウンロード実行 ----------
yt-dlp "${YTDLP_OPTS[@]}" "$url"
exit_code=$?

# ---------- 終了判定 ----------
if [[ $exit_code -eq 0 ]]; then
    echo "✅ Download completed successfully."
    exit 0
else
    echo "⚠️ Process finished (Exit code: $exit_code). Check if it was already downloaded or rate-limited."
    exit 0
fi
