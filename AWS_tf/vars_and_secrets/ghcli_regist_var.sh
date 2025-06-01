#!/bin/bash

###################github variablesへの登録のために実施###################

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

## リポジトリ情報を設定 #########################
OWNER="tamako8782"
REPO=$PROJECT_DIR_NAME
# 読み込み元ファイルを設定
VARFILE="$PROJECT_HOME/AWS_tf/vars_and_secrets/vars.yml"


## yqとghがインストールされていることを確認 #########################

if ! command -v yq &> /dev/null; then
    echo "yq could not be found, please install it."
    exit 1
fi

if ! command -v gh &> /dev/null; then
    echo "gh CLI could not be found, please install it."
    exit 1
fi

## vars.ymlから変数を読み込む #########################

VARIABLES=$(yq eval 'keys | .[]' "$VARFILE")

## 変数をGitHub Actionsの変数として設定 #########################

for TF_VAR_KEY in $VARIABLES; do
    VALUE=$(yq eval ".$TF_VAR_KEY" "$VARFILE")
    if gh variable set "$TF_VAR_KEY" -b "$VALUE" -R "$OWNER/$REPO"; then
        echo "Variable $TF_VAR_KEY has been set."
    else
        echo "Failed to set variable $TF_VAR_KEY."
    fi
done

echo "Variables have been set."



################################################
## please create "vars.yml" in the following format:
# EXAMPLE:
# TF_VAR_KEY1: "value1"
# TF_VAR_KEY2: "value2"
################################################