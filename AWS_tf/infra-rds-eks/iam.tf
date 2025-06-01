// LoadBalancerをOIDCを使ってサービスアカウントがアクセスできるようにする //////////////////////////////////////////

// IAMポリシーは、以下のコマンドでダウンロードして同じフォルダにあらかじめ配置すること:
// curl -o alb-ingress-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
resource "aws_iam_policy" "tamako_aws_loadbalancer_controller_policy" {
  name   = "EKSIngressAWSLoadBalancerController"
  policy = file("${path.module}/alb-ingress-policy.json")
}


module "iam_assumable_role_admin" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.0"

  create_role                  = true
  role_name                    = "EKSIngressAWSLoadBalancerController"
  provider_url                 = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns             = [aws_iam_policy.tamako_aws_loadbalancer_controller_policy.arn]
  oidc_subjects_with_wildcards = ["system:serviceaccount:*:*"]
}

resource "kubernetes_service_account" "tamako_aws_loadbalancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_admin.iam_role_arn
    }
  }
  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}


// secretsmanagerをOIDCを使ってサービスアカウントがアクセスできるようにする //////////////////////////////////////////

resource "aws_iam_policy" "tamako_secretsmanager_policy" {
  name = "EKSSSecretsManagerPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          data.terraform_remote_state.general.outputs.secretsmanager_secret_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRoleWithWebIdentity"
        ]
        Resource = "*"
      }
    ]
  })

}


module "iam_assumable_role_secretsmanager" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.0"

  create_role                  = true
  role_name                    = "EKSSecretsManagerRole"
  provider_url                 = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns             = [aws_iam_policy.tamako_secretsmanager_policy.arn]
  oidc_subjects_with_wildcards = ["system:serviceaccount:tamakoapp:secrets-access"]
}

resource "kubernetes_namespace" "tamako_ns_tamakoapp" {
  metadata {
    name = "tamakoapp"
  }
  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}

resource "kubernetes_service_account" "tamako_secretsmanager_serviceaccount" {
  metadata {
    name      = "secrets-access"
    namespace = "tamakoapp"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_secretsmanager.iam_role_arn
    }
  }
    lifecycle {
    ignore_changes = [
      metadata
    ]
  }
  depends_on = [
    kubernetes_namespace.tamako_ns_tamakoapp
  ]
}

