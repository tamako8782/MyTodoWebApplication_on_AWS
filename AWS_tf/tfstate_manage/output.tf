output "tamako_terraform_state_bucket_arn" {
    value = aws_s3_bucket.tamako_terraform_state.arn
    description = "The ARN of the S3 bucket"
}
output "tamako_terraform_lock_table_name" {
    value = aws_dynamodb_table.tamako_terraform_lock.name
    description = "The name of the DynamoDB table"
}


