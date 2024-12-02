# AWS ECR (Elastic Container Registry) リポジトリの作成
resource "aws_ecr_repository" "tamako_ecr" {

  # リポジトリの名前を指定
  name = var.ecr_repo_name

  # リポジトリに付与するタグの定義
  tags = {
    Name = "tamako-ecr-for-kubernetes"
  }
}
