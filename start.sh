#!/bin/bash

# TNアプリケーション起動スクリプト

set -e

echo "=========================================="
echo "TN Application Docker Compose 起動"
echo "=========================================="

# tnappリポジトリの取得
TNAPP_DIR="./tnapp"
TNAPP_REPO="https://github.com/toshi0907/tnapp.git"

if [ ! -d "$TNAPP_DIR" ]; then
    echo "📦 tnappリポジトリをクローンします..."
    git clone "$TNAPP_REPO" "$TNAPP_DIR"
    echo "✅ tnappリポジトリをクローンしました"
    echo ""
else
    echo "📦 tnappリポジトリが既に存在します"
    echo "🔄 最新版に更新しますか? (y/N)"
    read -t 10 -n 1 UPDATE_REPO || UPDATE_REPO="n"
    echo ""
    if [[ "$UPDATE_REPO" =~ ^[Yy]$ ]]; then
        echo "🔄 tnappリポジトリを更新します..."
        cd "$TNAPP_DIR"
        git pull origin main
        cd ..
        echo "✅ tnappリポジトリを更新しました"
    else
        echo "⏩ 既存のtnappリポジトリを使用します"
    fi
    echo ""
fi

# .envファイルの存在確認（tnappディレクトリ内）
if [ ! -f "$TNAPP_DIR/.env" ]; then
    echo "⚠️  .envファイルが見つかりません"
    if [ -f "$TNAPP_DIR/.env.example" ]; then
        echo "📋 .env.exampleから.envを作成します..."
        cp "$TNAPP_DIR/.env.example" "$TNAPP_DIR/.env"
        echo "✅ .envファイルを作成しました"
        echo "⚠️  必要に応じて$TNAPP_DIR/.envファイルを編集してください"
    else
        echo "❌ .env.exampleも見つかりません"
        echo "   最低限の.envファイルを作成します..."
        cat > "$TNAPP_DIR/.env" << EOF
# サーバー設定
PORT=3000
NODE_ENV=production

# Basic認証設定
BASIC_AUTH_ENABLED=true

# リマインダー通知設定（必要に応じて設定）
WEBHOOK_URL=

# メール設定（必要に応じて設定）
SMTP_HOST=
SMTP_PORT=587
SMTP_SECURE=false
SMTP_AUTH_METHOD=PLAIN
SMTP_REQUIRE_TLS=true
SMTP_USER=
SMTP_PASS=
EMAIL_FROM=
EMAIL_TO=
EOF
        echo "✅ デフォルトの.envファイルを作成しました"
    fi
    echo ""
fi

# dataディレクトリの作成
if [ ! -d ./data ]; then
    echo "📁 dataディレクトリを作成します..."
    mkdir -p ./data
    echo "✅ dataディレクトリを作成しました"
    echo ""
fi

# Dockerfileの確認とコピー
if [ ! -f "$TNAPP_DIR/Dockerfile" ]; then
    if [ -f "./Dockerfile" ]; then
        echo "📋 Dockerfileをtnappディレクトリにコピーします..."
        cp ./Dockerfile "$TNAPP_DIR/"
        echo "✅ Dockerfileをコピーしました"
        echo ""
    else
        echo "❌ Dockerfileが見つかりません"
        exit 1
    fi
fi

# 既存のコンテナを停止・削除
echo "🧹 既存のコンテナをクリーンアップします..."
docker-compose down

# イメージのビルドとコンテナの起動
echo ""
echo "🔨 イメージをビルドします..."
docker-compose build

echo ""
echo "🚀 コンテナを起動します..."
docker-compose up -d

# 起動待機
echo ""
echo "⏳ アプリケーションの起動を待機しています..."
sleep 5

# ヘルスチェック
MAX_RETRIES=30
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if docker-compose ps | grep -q "healthy"; then
        echo ""
        echo "=========================================="
        echo "✅ TNアプリケーションが正常に起動しました！"
        echo "=========================================="
        echo ""
        echo "📍 アクセスURL:"
        echo "   - アプリケーション: http://localhost:3000"
        echo "   - API仕様書: http://localhost:3000/api-docs"
        echo ""
        echo "📊 ステータス確認:"
        docker-compose ps
        echo ""
        echo "📋 ログ表示:"
        echo "   docker-compose logs -f"
        echo ""
        echo "🛑 停止コマンド:"
        echo "   docker-compose down"
        echo ""
        exit 0
    fi
    
    if ! docker-compose ps | grep -q "Up"; then
        echo ""
        echo "❌ コンテナの起動に失敗しました"
        echo ""
        echo "📋 ログを確認してください:"
        docker-compose logs
        exit 1
    fi
    
    echo -n "."
    sleep 2
    RETRY_COUNT=$((RETRY_COUNT + 1))
done

echo ""
echo "⚠️  ヘルスチェックがタイムアウトしました"
echo "   コンテナは起動していますが、ヘルスチェックが完了していません"
echo ""
echo "📋 ログを確認してください:"
docker-compose logs

exit 1
