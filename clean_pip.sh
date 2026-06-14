#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "========================================="
echo "🚨 WARNING: Starting Total Pip Environment Purge..."
echo "========================================="

# 1. 修正：現在アクティブな仮想環境のPython経由でpipを検査
if ! python -m pip --version &> /dev/null; then
    echo "❌ Error: 'pip' via active Python not found. Ensure your virtualenv is activated."
    exit 1
fi

# 2. 修正：python -m pip freeze を使用してパッケージを取得
INSTALLED_PACKAGES=$(python -m pip freeze | grep -v "^-e")

if [ -z "$INSTALLED_PACKAGES" ]; then
    echo "✨ Environment is already completely clean. Nothing to delete!"
    echo "========================================="
    exit 0
fi

# 3. Count packages to be destroyed
COUNT=$(echo "$INSTALLED_PACKAGES" | wc -l)
echo "🔥 Found $COUNT packages slated for destruction."
echo "⚠️  This will completely empty out your current Python environment."
read -p "Are you absolutely sure you want to proceed? (y/N): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "❌ Operation cancelled by user."
    echo "========================================="
    exit 0
fi

echo "-----------------------------------------"
echo "🧹 Uninstalling all packages..."

# 4. 修正：python -m pip を経由して一括削除を実行
echo "$INSTALLED_PACKAGES" | xargs python -m pip uninstall -y

echo "-----------------------------------------"
echo "✨ Verification check:"
REMAINING=$(python -m pip freeze)

if [ -z "$REMAINING" ]; then
    echo "✅ Success! Your environment is now 100% clean and pristine."
else
    echo "⚠️  Warning: Some configuration leaks detected:"
    echo "$REMAINING"
fi
echo "========================================="