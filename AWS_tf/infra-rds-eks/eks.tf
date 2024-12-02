module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~>20.0"

  # クラスターの基本設定
  cluster_name                    = var.cluster_name    # クラスター名
  cluster_version                 = var.cluster_version # クラスターのKubernetesバージョン
  cluster_endpoint_private_access = true                # クラスターのプライベートアクセスを有効化
  cluster_endpoint_public_access  = true                # クラスターのパブリックアクセスを有効化

  # クラスターが関連付けられるVPCとサブネットの設定
  vpc_id = resource.aws_vpc.tamako_vpc.id # VPC ID
  subnet_ids = [                          # クラスターに関連付けるプライベートサブネット
    resource.aws_subnet.tamako_prisub1.id,
    resource.aws_subnet.tamako_prisub2.id
  ]
  enable_irsa = true # IAM Roles for Service Accounts (IRSA) を有効化

  # デフォルトのノードグループ設定
  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"] # ノードタイプを指定
  }

  # カスタムノードグループの設定
  eks_managed_node_groups = {
    "${var.eks_managed_node_group_name}" = {
      desired_size   = 2             # ノード数
      instance_types = ["t3.medium"] # ノードタイプ
      subnet_ids = [                 # ノードが使用するサブネット
        resource.aws_subnet.tamako_prisub1.id,
        resource.aws_subnet.tamako_prisub2.id
      ]
      disk_size     = 20          # ノードのディスクサイズ (GB)
      capacity_type = "ON_DEMAND" # オンデマンドインスタンスを使用
    }
  }

  # アドオンの設定
  cluster_addons = {
    coredns = {
      most_recent = true # 最新バージョンを使用
    }
    kube-proxy = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true # 最新バージョンのCNIプラグイン
      before_compute = true # コンピュートリソースの作成前に実行
      configuration_values = jsonencode({
        env = {
          AWS_VPC_K8S_CNI_EXTERNALSNAT = "true" # NAT Gateway経由での外部通信を有効化
          ENABLE_PREFIX_DELEGATION     = "true" # IPアドレスプールの効率的利用を有効化
          WARM_PREFIX_TARGET           = "1"    # IPプレフィックスのプールサイズ
        }
      })
    }
  }

  # クラスター管理者権限の付与
  enable_cluster_creator_admin_permissions = true

  # ノードセキュリティグループの追加ルール
  node_security_group_additional_rules = {
    # AdmissionWebhook用の通信を許可 (inbound)
    admission_webhook = {
      description                   = "Admission Webhook"
      protocol                      = "tcp"
      from_port                     = 0
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }
    # ノード間通信を許可 (inbound)
    ingress_mode_communications = {
      description = "Ingress Node to Node"
      protocol    = "tcp"
      from_port   = 0
      to_port     = 65535
      type        = "ingress"
      self        = true
    }
    # ノード間通信を許可 (outbound)
    egress_node_communications = {
      description = "Egress Node to Node"
      protocol    = "tcp"
      from_port   = 0
      to_port     = 65535
      type        = "egress"
      self        = true
    }
    # ノードからVPC内リソースへの通信を許可 (outbound)
    egress_node_to_local = {
      description = "Egress Node to Local"
      type        = "egress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [resource.aws_vpc.tamako_vpc.cidr_block]
    }
  }
}
