// AWS Load Balancer ControllerのためのIAMロール設定 ///////////////////////////
// 1. 必要なIAMポリシーを定義
// 2. OIDCを利用してIAMロールを作成
// 3. Kubernetes上のServiceAccountにIAMロールを関連付け

// Step 1: AWS Load Balancer Controller用のIAMポリシーを作成
// IAMポリシーは、以下のコマンドでダウンロードして同じフォルダにあらかじめ配置すること:
// curl -o alb-ingress-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
resource "aws_iam_policy" "tamako_aws_loadbalancer_controller_policy" {
  name   = "EKSIngressAWSLoadBalancerController"          // ポリシー名
  policy = file("${path.module}/alb-ingress-policy.json") // ローカルの同フォルダに保存したポリシーファイルを参照
}

// Step 2: IAMロールの作成
// EKSクラスターのOIDCプロバイダーを利用して、ロードバランサーコントローラー用のIAMロールを作成
module "iam_assumable_role_admin" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc" // AWS公式のIAMモジュールを使用
  version = "~> 4.0"

  create_role                  = true                                                           // IAMロールを新規作成する
  role_name                    = "EKSIngressAWSLoadBalancerController"                          // 作成するIAMロール名
  provider_url                 = replace(module.eks.cluster_oidc_issuer_url, "https://", "")    // EKSのOIDCプロバイダーURL
  role_policy_arns             = [aws_iam_policy.tamako_aws_loadbalancer_controller_policy.arn] // 上で作成したポリシーを付与
  oidc_subjects_with_wildcards = ["system:serviceaccount:*:*"]                                  // サービスアカウントからのリクエストを許可
}

// Step 3: Kubernetes上のServiceAccountにIAMロールを関連付け
// aws-load-balancer-controllerが利用するServiceAccountを作成し、IAMロールを紐付け
resource "kubernetes_service_account" "tamako_aws_loadbalancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller" // サービスアカウント名
    namespace = "kube-system"                  // サービスアカウントを配置するNamespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_admin.iam_role_arn // 作成したIAMロールを関連付け
    }
  }
}


// secretsmanagerのIAMポリシーを作成 //////////////////////////////////////////

// Step 1: AWS Secrets Manager用のIAMポリシーを作成
//           "sts:AssumeRoleWithWebIdentity"を追加した
resource "aws_iam_policy" "tamako_secretsmanager_policy" {
  name   = "EKSSSecretsManagerPolicy"
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
          aws_secretsmanager_secret.tamako_db_info.arn
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

  depends_on = [
    aws_secretsmanager_secret.tamako_db_info
  ]
}

// Step 2: Secrets Manager用のIAMロールを作成
// OIDCプロバイダーを使用してIAMロールを作成
// oidc_subjects_with_wildcardsの中のnamespaceは、k8sのnamespaceと一致させる
module "iam_assumable_role_secretsmanager" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.0"

  create_role                  = true                                                            // IAMロールを新規作成する
  role_name                    = "EKSSecretsManagerRole"                                         // 作成するIAMロール名
  provider_url                 = replace(module.eks.cluster_oidc_issuer_url, "https://", "")     // EKSのOIDCプロバイダーURL
  role_policy_arns             = [aws_iam_policy.tamako_secretsmanager_policy.arn]              // 上で作成したIAMポリシーを付与
  oidc_subjects_with_wildcards = ["system:serviceaccount:tamakoapp:secrets-access"]                // 特定のServiceAccountからのリクエストを許可
}

// Step 3: Namespaceの作成
resource "kubernetes_namespace" "tamako_ns_tamakoapp" {
  metadata {
    name = "tamakoapp" # 作成したいNamespaceの名前
  }
}


// Step 4: Kubernetes上のServiceAccountにIAMロールを関連付け
// KubernetesのServiceAccountを作成し、IAMロールを紐付け
resource "kubernetes_service_account" "tamako_secretsmanager_serviceaccount" {
  metadata {
    name      = "secrets-access"                              // サービスアカウント名
    namespace = "tamakoapp"                                     // Namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_secretsmanager.iam_role_arn // IAMロールを関連付け
    }
  }
  depends_on = [
    kubernetes_namespace.tamako_ns_tamakoapp
  ]
}

