## 開発用ステージ
FROM --platform=arm64 node:20-alpine AS dev
ENV NODE_ENV=development

RUN apk update && apk add --no-cache git tree curl vim 
WORKDIR /app

COPY ./myapp/package.json ./myapp/package-lock.json ./
RUN npm install 
COPY ./myapp/ /app

EXPOSE 3000

CMD ["sh", "-c", "npm start"]


## ビルド用ステージ
FROM --platform=arm64 node:20-alpine AS build
ENV NODE_ENV=production

WORKDIR /app

COPY ./myapp/package.json ./myapp/package-lock.json ./
RUN npm install 
COPY ./myapp/ /app/

# React アプリケーションをビルド
RUN npm run build

## 本番用ステージ 
FROM nginx:1.27-alpine AS prod

# React のビルドされたファイルを Nginx にコピー
COPY --from=build /app/build /usr/share/nginx/html

# デフォルトの Nginx 設定を削除
RUN rm /etc/nginx/conf.d/default.conf

# Nginx 設定ファイルをコンテナにコピー
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

# ポート 80 を公開
EXPOSE 80

# Nginx をフォアグラウンドで実行
CMD ["nginx", "-g", "daemon off;"]

