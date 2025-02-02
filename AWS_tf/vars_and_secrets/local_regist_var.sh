#!/bin/bash

################### ローカル環境に変数を設定するために実施 ###################

# プロジェクトディレクトリ名を設定
PROJECT_DIR_NAME="MyTodoWebApplication_on_AWS"

# プロジェクトディレクトリの絶対パスを検索
PROJECT_DIR_PATH=$(find $HOME/Desktop/repo -type d -name "$PROJECT_DIR_NAME" 2>/dev/null | head -n 1)

## 絶対パスが見つかった場合、環境変数に設定
if [ -n "$PROJECT_DIR_PATH" ]; then
    export PROJECT_HOME="$PROJECT_DIR_PATH"
    echo "PROJECT_HOME is set to $PROJECT_HOME"
else
    echo "Error: Project directory '$PROJECT_DIR_NAME' not found."
    exit 1
fi

# 読み込み元ファイルを設定
VARFILE="$PROJECT_HOME/AWS_tf/vars_and_secrets/vars.yml"

# yqがインストールされていることを確認
if ! command -v yq &> /dev/null; then
    echo "yq could not be found, please install it."
    exit 1
fi

# vars.ymlから変数を1行ずつ読み込む
yq eval 'keys | .[]' "$VARFILE" | while read -r TF_VAR_KEY; do
    VALUE=$(yq eval ".$TF_VAR_KEY" "$VARFILE")
    export "$TF_VAR_KEY"="$VALUE"
    echo "Exported $TF_VAR_KEY with value $VALUE"
done

echo "All variables have been exported to the local environment."

################################################
## please create "vars.yml" in the following format:
# EXAMPLE:
# TF_VAR_KEY1: "value1"
# TF_VAR_KEY2: "value2"
################################################