module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~>20.0"

  cluster_name                    = var.cluster_name    
  cluster_version                = var.cluster_version 
  cluster_endpoint_private_access = true                
  cluster_endpoint_public_access  = true                

  vpc_id = resource.aws_vpc.tamako_vpc.id 
  subnet_ids = [                          
    resource.aws_subnet.tamako_prisub1.id,
    resource.aws_subnet.tamako_prisub2.id
  ]
  enable_irsa = true 

  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"] 
  }

  eks_managed_node_groups = {
    "${var.eks_managed_node_group_name}" = {
      desired_size   = 2             
      instance_types = ["t3.medium"] 
      subnet_ids = [                 
        resource.aws_subnet.tamako_prisub1.id,
        resource.aws_subnet.tamako_prisub2.id
      ]
      disk_size     = 20          
      capacity_type = "ON_DEMAND" 
    }
  }

  cluster_addons = {
    coredns = {
      most_recent = true 
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
      most_recent    = true 
      before_compute = true 
      configuration_values = jsonencode({
        env = {
          AWS_VPC_K8S_CNI_EXTERNALSNAT = "true" 
          ENABLE_PREFIX_DELEGATION     = "true" 
          WARM_PREFIX_TARGET           = "1"    
        }
      })
    }
  }

  enable_cluster_creator_admin_permissions = true

  node_security_group_additional_rules = {
    admission_webhook = {
      description                   = "Admission Webhook"
      protocol                      = "tcp"
      from_port                     = 0
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_mode_communications = {
      description = "Ingress Node to Node"
      protocol    = "tcp"
      from_port   = 0
      to_port     = 65535
      type        = "ingress"
      self        = true
    }
    egress_node_communications = {
      description = "Egress Node to Node"
      protocol    = "tcp"
      from_port   = 0
      to_port     = 65535
      type        = "egress"
      self        = true
    }
    egress_node_to_local = {
      description = "Egress Node to Local"
      type        = "egress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [resource.aws_vpc.tamako_vpc.cidr_block]
    }
    # HTTP トラフィックを許可（必要に応じて追加）
  ingress_http = {
    description = "Allow HTTP traffic to EKS nodes"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    type        = "ingress"
    cidr_blocks = ["0.0.0.0/0"] # または特定のソース CIDR
  }
  # HTTPS トラフィックを許可
  ingress_https = {
    description = "Allow HTTPS traffic to EKS nodes"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    type        = "ingress"
    cidr_blocks = ["0.0.0.0/0"] # または特定のソース CIDR
  }
  }
}
