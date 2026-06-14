#!/bin/bash

# エラーが発生したら即座にスクリプトを終了
set -e

# バックアップを保存するディレクトリ（カレントディレクトリに自動作成されます）
BACKUP_DIR="./pip_backups"
mkdir -p "$BACKUP_DIR"

# タイムスタンプの生成（フォーマット: YYYYMMDD_HHMMSS）
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/requirements_${TIMESTAMP}.txt"

echo "========================================="
echo "💾 Starting Pip Environment Backup..."
echo "========================================="

# 1. パスのねじれを防ぐため、現在アクティブな仮想環境のPython経由でpipを検査
if ! python -m pip --version &> /dev/null; then
    echo "❌ Error: 'pip' via active Python not found. Ensure your virtualenv is activated."
    exit 1
fi

# 2. 現在の仮想環境のパッケージ一覧をタイムスタンプ付きでエクスポート（編集用ソースは除外）
echo "📝 Freezing installed packages from current environment..."
python -m pip freeze | grep -v "^-e" > "$BACKUP_FILE"

# 3. ファイルが正常に作成され、中身が空でないか検証
if [ -s "$BACKUP_FILE" ]; then
    echo "✅ Backup successfully created!"
    echo "📂 File Location: $BACKUP_FILE"
    echo "📊 Total Packages: $(wc -l < "$BACKUP_FILE")"
else
    echo "❌ Error: Failed to create backup or the file is empty."
    rm -f "$BACKUP_FILE"
    exit 1
fi

echo "========================================="