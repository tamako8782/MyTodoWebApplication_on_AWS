output "tamako_db_instance_id" {
  value = aws_db_instance.tamako_rds.id
}

output "tamako_db_address" {
  value = aws_db_instance.tamako_rds.address
}

output "tamako_db_security_group_id" {
  value = aws_security_group.tamako_rds_sg.id
}
