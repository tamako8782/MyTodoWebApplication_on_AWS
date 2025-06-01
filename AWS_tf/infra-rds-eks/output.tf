output "tamako_db_instance_id" {
  value = aws_db_instance.tamako_rds.id
}

output "tamako_db_address" {
  value = aws_db_instance.tamako_rds.address
}

output "tamako_db_security_group_id" {
  value = aws_security_group.tamako_rds_sg.id
}

output "tamako_eks_cluster_name" {
  value = module.eks.cluster_name
}

output "vpc_id" {
  value = aws_vpc.tamako_vpc.id
}


output "public_subnets" {
  value = [aws_subnet.tamako_pubsub1.id, aws_subnet.tamako_pubsub2.id]
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "iam_assumable_role_admin_arn" {
  value = module.iam_assumable_role_admin.iam_role_arn
}

