resource "aws_db_instance" "tamako_rds" {
  # 基本情報
  identifier     = var.identifier
  instance_class = var.instance_class
  engine         = var.engine
  engine_version = var.engine_version
  port           = var.db_port
  # 最初のデータベース
  db_name = var.db_name
  # ストレージ設定
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  # セキュリティ設定
  vpc_security_group_ids = [aws_security_group.tamako_rds_sg.id]           # VPCセキュリティグループ
  db_subnet_group_name   = aws_db_subnet_group.tamako_db_subnet_group.name # DBサブネットグループ
  # 認証情報
  username = var.db_username
  password = var.db_password
  # マルチAZ構成
  multi_az = var.multi_az
  # バックアップ設定
  backup_window           = var.backup_window
  backup_retention_period = var.backup_retention_period
  # メンテナンス設定
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  # 削除・変更ポリシー
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  apply_immediately   = var.apply_immediately
}


resource "aws_db_subnet_group" "tamako_db_subnet_group" {
  name        = "tamako-db-subnet-group"
  description = "rds subnet group for tamako"
  subnet_ids  = [aws_subnet.tamako_dbsub1.id, aws_subnet.tamako_dbsub2.id]
}


# RDS接続用セキュリティグループの作成
# データベース接続用のセキュリティグループを作成します。
resource "aws_security_group" "tamako_rds_sg" {
  vpc_id = aws_vpc.tamako_vpc.id

  # RDS用インバウンド（データベースへのアクセスを許可）
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # アウトバウンドは全て許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.base_name}-rds-sg"
  }
}
