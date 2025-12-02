# ベースイメージとしてNode.js 18を使用
FROM node:18-alpine AS base

# タイムゾーンを日本に設定
ENV TZ=Asia/Tokyo

# 作業ディレクトリの設定
WORKDIR /app

# パッケージマネージャーのキャッシュを活用するため、まずpackage.jsonとpackage-lock.jsonをコピー
COPY package*.json ./

# 依存関係のインストール（本番用と開発用の両方）
RUN npm install

# ソースコードをコピー
COPY . .

# データディレクトリの作成
RUN mkdir -p /app/data

# ポート3000を公開
EXPOSE 3000

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# アプリケーションの起動
CMD ["npm", "start"]
