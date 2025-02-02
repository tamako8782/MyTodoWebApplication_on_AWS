// Terraformバージョンと必要なプロバイダーの設定
terraform {
  required_version = "1.9.8" // Terraformのバージョン要件
  required_providers {
    aws = {
      source  = "hashicorp/aws" // AWSプロバイダーを使用
      version = "5.79.0"        // AWSプロバイダーのバージョン要件
    }
    kubernetes = {
      source  = "hashicorp/kubernetes" // Kubernetesプロバイダーを使用
      version = "2.33.0"               // Kubernetesプロバイダーのバージョン要件
    }
    # helm = {
    #   source  = "hashicorp/helm"
    #   version = "2.17.0"
    # }
    # kustomization = {
    #   source  = "kbst/kustomization"
    #   version = "0.9.0"
    # }
  }

  // バックエンドの設定(別口で作成したS3、DynamoDBを使用する)
  backend "s3" {
    bucket         = "tamako8782-mytodowebapplication-tfstate"
    key            = "src_mytodowebapplication_cfn_dns/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "tamako8782-mytodowebapplication-lock"
    encrypt        = true
  }
}

data "terraform_remote_state" "infra_rds_eks" {
  backend = "s3"
  config = {
    bucket = "tamako8782-mytodowebapplication-tfstate"
    key    = "src_mytodowebapplication/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "general" {
  backend = "s3"
  config = {
    bucket = "tamako8782-mytodowebapplication-tfstate"
    key    = "src_mytodowebapplication_general/terraform.tfstate"
    region = "ap-northeast-1"
  }
}


// EKSクラスター情報を取得するためのデータソース
data "aws_eks_cluster" "eks" {
  name = data.terraform_remote_state.infra_rds_eks.outputs.tamako_eks_cluster_name // モジュールからクラスター名を取得
  // クラスター作成が完了してから実行
}

// EKSクラスター認証情報を取得するためのデータソース
data "aws_eks_cluster_auth" "eks" {
  name = data.terraform_remote_state.infra_rds_eks.outputs.tamako_eks_cluster_name // モジュールからクラスター名を取得

}

// Kubernetesプロバイダーの設定
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint                                    // クラスターのエンドポイント
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data) // CA証明書のデコード
  token                  = data.aws_eks_cluster_auth.eks.token                                  // クラスター認証トークン
}

# 一旦以下のproviderはコメントアウトしておく
#provider "helm" {
#  kubernetes {
#    host                   = data.aws_eks_cluster.eks.endpoint
#    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
#    token                  = data.aws_eks_cluster_auth.eks.token
#  }
#}
#
#provider "kustomization" {
#  kubeconfig_raw = templatefile("${path.module}/kubeconfig.tpl", {
#    cluster_endpoint = data.aws_eks_cluster.eks.endpoint
#    cluster_ca       = data.aws_eks_cluster.eks.certificate_authority[0].data
#    cluster_name     = data.aws_eks_cluster.eks.name
#    aws_region       = "ap-northeast-1"
#  })
#}
