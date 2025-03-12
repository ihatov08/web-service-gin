# ビルドステージとしてgolangイメージを使用
FROM golang:1.24-bullseye AS builder

# 作業ディレクトリを設定
WORKDIR /myapp

# 依存関係ファイルをコピー
COPY go.mod go.sum ./
# 依存関係をダウンロード
RUN go mod download

# アプリケーションのソースコードをコピー
COPY . .
# アプリケーションをビルド
RUN go build -trimpath -ldflags "-w -s" -o app

# 実行ステージとしてdebianイメージを使用
FROM debian:bullseye-slim AS runner

# パッケージリストを更新
RUN apt-get update

# ビルドステージからビルド済みアプリケーションをコピー
COPY --from=builder /myapp/app .

# アプリケーションを実行
CMD ["./app"]

# 開発ステージとしてgolangイメージを使用
FROM golang:1.24 AS dev

# 作業ディレクトリを設定
WORKDIR /myapp
# airツールをインストール
RUN go install github.com/air-verse/air@latest
# 依存関係ファイルをコピー
COPY go.mod go.sum ./
# 依存関係をダウンロード
RUN go mod download

# アプリケーションのソースコードをコピー
COPY . .

# airツールを使用してアプリケーションを実行
CMD ["air", "-c", ".air.toml"]