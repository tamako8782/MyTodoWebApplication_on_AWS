// Terraformバージョンと必要なプロバイダーの設定
terraform {
  required_version = "1.9.8" // Terraformのバージョン要件
  required_providers {
    aws = {
      source  = "hashicorp/aws" // AWSプロバイダーを使用
      version = "5.79.0"     // AWSプロバイダーのバージョン要件
    }
    kubernetes = {
      source  = "hashicorp/kubernetes" // Kubernetesプロバイダーを使用
      version = "2.33.0"            // Kubernetesプロバイダーのバージョン要件
    }
  }
  // バックエンドの設定(別口で作成したS3、DynamoDBを使用する)
  backend "s3" {
    bucket         = "tamako8782-mytodowebapplication-tfstate"
    key            = "src_mytodowebapplication/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "tamako8782-mytodowebapplication-lock"
    encrypt        = true
  }
}

// AWSプロバイダーの設定
provider "aws" {
  region = var.region // AWSリージョンを指定

  // デフォルトで付与されるタグ
  default_tags {
    tags = {
      Project = "MyTodoWebApplication-for-AWS" // プロジェクト名として設定
    }
  }
}

// ローカル変数の定義
// 今回これらの変数は

// EKSクラスター情報を取得するためのデータソース
data "aws_eks_cluster" "eks" {
  name       = module.eks.cluster_name // モジュールからクラスター名を取得
  depends_on = [module.eks]            // クラスター作成が完了してから実行
}

// EKSクラスター認証情報を取得するためのデータソース
data "aws_eks_cluster_auth" "eks" {
  name       = module.eks.cluster_name // モジュールからクラスター名を取得
  depends_on = [module.eks]            // クラスター作成が完了してから実行
}

// Kubernetesプロバイダーの設定
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint                                    // クラスターのエンドポイント
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data) // CA証明書のデコード
  token                  = data.aws_eks_cluster_auth.eks.token                                  // クラスター認証トークン
}
