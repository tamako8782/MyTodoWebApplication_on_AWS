resource "aws_s3_bucket" "tamako_terraform_state" {
    bucket = "tamako8782-mytodowebapplication-tfstate"
    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_s3_bucket_versioning" "tamako_terraform_state" {
    bucket = aws_s3_bucket.tamako_terraform_state.id
    versioning_configuration {
        status = "Enabled"
    }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "tamako_terraform_state" {
    bucket = aws_s3_bucket.tamako_terraform_state.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_public_access_block" "tamako_terraform_state" {
    bucket = aws_s3_bucket.tamako_terraform_state.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}


resource "aws_dynamodb_table" "tamako_terraform_lock" {
    name = "tamako8782-mytodowebapplication-lock"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
    lifecycle {
        prevent_destroy = true
    }

}
