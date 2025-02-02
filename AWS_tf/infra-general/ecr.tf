
resource "aws_ecr_repository" "tamako_ecr" {
  name = var.ecr_repo_name


  tags = {
    Name = "tamako-ecr-for-kubernetes"
  }
}
