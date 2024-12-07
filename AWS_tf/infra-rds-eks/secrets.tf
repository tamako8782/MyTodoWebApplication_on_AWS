resource "aws_secretsmanager_secret" "tamako_db_info" {

    name = "tamako_db_info8"
}

resource "aws_secretsmanager_secret_version" "tamako_db_info_version" {
    secret_id = aws_secretsmanager_secret.tamako_db_info.id
    secret_string = jsonencode({
        db_username = var.db_username
        db_name = var.db_name
        db_password = var.db_password
    })


}