// Terraformバージョンと必要なプロバイダーの設定
terraform {
  required_version = "1.9.8" // Terraformのバージョン要件
  required_providers {
    aws = {
      source  = "hashicorp/aws" // AWSプロバイダーを使用
      version = "5.79.0"        // AWSプロバイダーのバージョン要件
    }

  }
  // バックエンドの設定(別口で作成したS3、DynamoDBを使用する)
  backend "s3" {
    bucket         = "tamako8782-mytodowebapplication-tfstate"
    key            = "src_mytodowebapplication_general/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "tamako8782-mytodowebapplication-lock"
    encrypt        = true
  }
}

