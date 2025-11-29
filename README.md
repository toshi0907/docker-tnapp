# TN API Server (Docker Compose版)

[toshi0907/tnapp](https://github.com/toshi0907/tnapp) をDocker Composeで簡単に起動できる環境です。

## 機能

- **ブックマーク管理API**: CRUD操作、検索、カテゴリ・タグ機能
- **リマインダー管理API**: スケジューリング、Webhook/Email通知
- **Swagger UI**: インタラクティブなAPI仕様書（`http://localhost:3000/api-docs`）
- **JSONファイル永続化**: データはボリュームマウントで永続化
- **自動ヘルスチェック**: コンテナの健全性監視

## 必要な環境

- Docker
- Docker Compose

## セットアップ

### 1. リポジトリのクローン

```bash
git clone https://github.com/toshi0907/tnapp.git
cd tnapp
```

### 2. 環境変数の設定

`.env.example` を `.env` にコピーして、必要に応じて設定を変更します。

```bash
cp .env.example .env
```

`.env` ファイルの主な設定項目：

```bash
# サーバー設定
PORT=3000
NODE_ENV=production

# リマインダー通知設定（Webhook）
WEBHOOK_URL=https://webhook.site/your-webhook-url

# メール設定（Gmail SMTP）
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-gmail-app-password
EMAIL_FROM=your-email@gmail.com
EMAIL_TO=notification@example.com

# Basic認証設定
BASIC_AUTH_ENABLED=true
```

**Gmail SMTP設定の注意点:**
- `SMTP_PASS` には通常のGoogleアカウントのパスワードではなく、**アプリパスワード**を使用してください
- アプリパスワードの生成方法は[こちら](https://support.google.com/accounts/answer/185833)

### 3. データディレクトリの作成

```bash
mkdir -p data
```

### 4. Docker Composeでの起動

#### 通常起動

```bash
docker-compose up -d
```

#### ログを確認しながら起動

```bash
docker-compose up
```

#### ビルドから実行

```bash
docker-compose up --build -d
```

### 5. アクセス確認

サーバーが起動したら、以下のURLにアクセスできます：

- **ホームページ**: http://localhost:3000
- **API仕様書（Swagger UI）**: http://localhost:3000/api-docs
- **ブックマーク管理画面**: http://localhost:3000/bookmark
- **リマインダー管理画面**: http://localhost:3000/reminder
- **ヘルスチェック**: http://localhost:3000/health

## 基本的なコマンド

### コンテナの起動

```bash
docker-compose up -d
```

### コンテナの停止

```bash
docker-compose down
```

### コンテナの再起動

```bash
docker-compose restart
```

### ログの確認

```bash
# すべてのログを表示
docker-compose logs

# リアルタイムでログを追跡
docker-compose logs -f

# 特定のサービスのログを表示
docker-compose logs tnapp
```

### コンテナの状態確認

```bash
docker-compose ps
```

### コンテナに入る

```bash
docker-compose exec tnapp sh
```

### データの完全削除（ボリュームも含む）

```bash
docker-compose down -v
```

## データの永続化

`./data` ディレクトリがコンテナ内の `/app/data` にマウントされ、以下のファイルが永続化されます：

- `bookmarks.json`: ブックマークデータ
- `reminders.json`: リマインダーデータ

データをバックアップする場合は、`./data` ディレクトリをコピーしてください。

## 開発モード

開発時にソースコードの変更を反映させたい場合は、`docker-compose.yml` の以下のコメントを解除してください：

```yaml
volumes:
  - ./data:/app/data
  # 開発時のホットリロード用（開発環境の場合）
  - ./src:/app/src        # ← コメント解除
  - ./public:/app/public  # ← コメント解除
```

さらに、`.env` で `NODE_ENV=development` に変更してください。

## API の使い方

### ヘルスチェック

```bash
curl http://localhost:3000/health
```

### ブックマーク一覧取得

```bash
curl http://localhost:3000/api/bookmarks
```

### リマインダー一覧取得

```bash
curl http://localhost:3000/api/reminders
```

詳細なAPI仕様は [Swagger UI](http://localhost:3000/api-docs) を参照してください。

## トラブルシューティング

### ポートが既に使用されている

`docker-compose.yml` の `ports` セクションを変更してください：

```yaml
ports:
  - "3001:3000"  # ホスト側のポートを3001に変更
```

### コンテナが起動しない

ログを確認してください：

```bash
docker-compose logs tnapp
```

### データが保存されない

`./data` ディレクトリのパーミッションを確認してください：

```bash
ls -la ./data
```

必要に応じて、パーミッションを変更してください：

```bash
chmod 755 ./data
```

### メール通知が送信されない

1. `.env` ファイルでSMTP設定が正しいか確認
2. Gmailの場合、アプリパスワードを使用しているか確認
3. ログでエラーメッセージを確認：

```bash
docker-compose logs -f tnapp
```

## 本番環境での使用

本番環境で使用する場合は、以下を推奨します：

1. **環境変数をセキュアに管理**
   - `.env` ファイルを `.gitignore` に追加
   - Docker Secretsやその他の秘密管理ツールを使用

2. **リバースプロキシの使用**
   - Nginx等のリバースプロキシを前段に配置
   - HTTPS対応

3. **ログローテーションの設定**
   - Docker のログドライバーを設定

4. **バックアップの自動化**
   - `./data` ディレクトリの定期バックアップ

## ライセンス

元のプロジェクト [toshi0907/tnapp](https://github.com/toshi0907/tnapp) のライセンスに従います。

## 関連リンク

- [元のリポジトリ](https://github.com/toshi0907/tnapp)
- [Docker公式ドキュメント](https://docs.docker.com/)
- [Docker Compose公式ドキュメント](https://docs.docker.com/compose/)