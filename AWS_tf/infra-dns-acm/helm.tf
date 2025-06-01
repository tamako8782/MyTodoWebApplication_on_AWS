## 一旦helmのデプロイはしないで見る
#resource "helm_release" "albc" {
#  name       = "aws-load-balancer-controller"
#  repository = "https://aws.github.io/eks-charts"
#  chart      = "aws-load-balancer-controller"
#  version    = "3.16.2" # 2024/12/28時点で最新
#  namespace  = "kube-system"
#
#  values = [yamlencode(
#    {
#      clusterName = data.terraform_remote_state.infra_rds_eks.outputs.tamako_eks_cluster_name
#      serviceAccount = {
#        create = false
#        name   = "aws-load-balancer-controller"
#        annotations = {
#          "eks.amazonaws.com/role-arn" = data.terraform_remote_state.infra_rds_eks.outputs.iam_assumable_role_admin_arn
#        }
#      }
#    }
#  )]
#}