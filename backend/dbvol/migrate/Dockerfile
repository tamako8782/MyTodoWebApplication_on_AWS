FROM alpine:3.18 AS prod

# 必要なパッケージのインストールとマイグレーションツールのセットアップ
RUN apk --no-cache add curl mysql-client bash vim git && \
    curl -L https://github.com/golang-migrate/migrate/releases/download/v4.11.0/migrate.linux-amd64.tar.gz | tar xvz && \
    mv ./migrate.linux-amd64 /usr/bin/migrate

# マイグレーションファイルをコンテナにコピー
COPY ./ /migrations

# MySQLに接続してマイグレーションを実行
CMD ["sh", "-c", "migrate -path /migrations -database \"mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@tcp(${MYSQL_HOST}:3306)/${MYSQL_DATABASE}\" up"]
