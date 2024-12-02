// Terraformバージョンと必要なプロバイダーの設定
terraform {
  required_version = "1.9.8" // Terraformのバージョン要件
  required_providers {
    aws = {
      source  = "hashicorp/aws" // AWSプロバイダーを使用
      version = "5.76.0"     // AWSプロバイダーのバージョン要件
    }
  }
// バックエンドの設定(S3、DynamoDBが作成されたあとに使用されるべき)
  backend "s3" {
        bucket = "tamako8782-mytodowebapplication-tfstate"
        key = "tfstate_manage/terraform.tfstate"
        region = "ap-northeast-1"
        dynamodb_table = "tamako8782-mytodowebapplication-lock"
        encrypt = true
    }

}

// AWSプロバイダーの設定
provider "aws" {
  region = var.region // AWSリージョンを指定
  
  // デフォルトで付与されるタグ
  default_tags {
    tags = {
      Project = "tfstate-management" // プロジェクト名として設定
    }
  }
}

