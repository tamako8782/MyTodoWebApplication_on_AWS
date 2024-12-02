#### Stage 1 開発環境用

FROM --platform=arm64 golang:1.23rc1-bookworm AS dev

# 作業ディレクトリを設定
WORKDIR /app

# ホストのコードをコンテナにコピー
COPY ./ /app

# 必要なパッケージをインストール（開発用）
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    sqlite3 \  
    tree \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# 開発環境で必要なポートを公開
EXPOSE 8080

CMD ["tail", "-f", "/dev/null"]


#### Stage 2 ビルドステージ
FROM --platform=arm64 golang:1.23rc1-bookworm AS build

# 作業ディレクトリを設定
WORKDIR /app/src

# go.modとgo.sumをコピーして依存パッケージを取得
COPY ./src/go.mod ./src/go.sum ./
RUN go mod download

# アプリケーションのソースコードをコピー
COPY ./src /app/src

# 本番用にGoアプリケーションをビルド
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o /app/bin/MyTodoApp /app/src


# Stage 3: 最小限の本番環境用ステージ
FROM --platform=arm64 gcr.io/distroless/static-debian12 AS prod

# 非rootユーザーを使用
USER nonroot:nonroot

# バイナリファイルをコピー
COPY --from=build /app/bin/MyTodoApp /MyTodoApp

# ポートを公開
EXPOSE 8080

# 本番用アプリケーションのエントリポイント
ENTRYPOINT ["/MyTodoApp"]

