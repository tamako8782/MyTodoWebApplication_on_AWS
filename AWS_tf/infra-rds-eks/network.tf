# VPCの作成
# 仮想プライベートクラウド（VPC）を作成してネットワーク基盤を構築します。
resource "aws_vpc" "tamako_vpc" {
  cidr_block           = "10.0.0.0/16" # ネットワークの範囲を指定
  enable_dns_support   = true          # DNSサポートを有効化
  enable_dns_hostnames = true          # ホスト名解決を有効化
  tags = {
    Name                                        = "${var.base_name}-vpc" # リソースの識別用タグ
  }
}

# インターネットゲートウェイの作成
# VPCをインターネットに接続するためのインターネットゲートウェイを作成します。
resource "aws_internet_gateway" "tamako_igw" {
  vpc_id = aws_vpc.tamako_vpc.id
  tags = {
    Name = "yama-igw"
  }
}


# パブリックサブネットの作成
# インターネットに直接アクセス可能なパブリックサブネットを作成します。
resource "aws_subnet" "tamako_pubsub1" {
  vpc_id                  = aws_vpc.tamako_vpc.id
  cidr_block              = "10.0.1.0/24"     # サブネットの範囲を指定
  availability_zone       = "ap-northeast-1a" # アベイラビリティゾーンを指定
  map_public_ip_on_launch = true              # インスタンスにパブリックIPを割り当て
  tags = {
    "kubernetes.io/role/elb"                    = "1"                         # ELB用サブネットタグ
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"                    # Kubernetesクラスタの共有タグ
  }
}

resource "aws_subnet" "tamako_pubsub2" {
  vpc_id                  = aws_vpc.tamako_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
  tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared" # Kubernetesクラスタの共有タグ
  }
}

# プライベートサブネットの作成
# 内部リソース用で外部からのアクセスを制限するサブネットを作成します。
resource "aws_subnet" "tamako_prisub1" {
  vpc_id                  = aws_vpc.tamako_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false # パブリックIPは割り当てない
  tags = {
    Name                                        = "${var.base_name}-prisub-1" # サブネット名
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"                    # Kubernetesクラスタの共有タグ

  }
}

resource "aws_subnet" "tamako_prisub2" {
  vpc_id                  = aws_vpc.tamako_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
  tags = {
    Name                                        = "${var.base_name}-prisub-2"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"

  }
}

# データベース用プライベートサブネット
# RDSなどのデータベースリソース専用にサブネットを作成します。
resource "aws_subnet" "tamako_dbsub1" {
  vpc_id                  = aws_vpc.tamako_vpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.base_name}-dbsub1" # サブネット名
  }
}

resource "aws_subnet" "tamako_dbsub2" {
  vpc_id                  = aws_vpc.tamako_vpc.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.base_name}-dbsub2"
  }
}

# ルートテーブルの作成
# パブリックサブネット用のルートテーブルを作成し、インターネットゲートウェイへのルートを設定します。
resource "aws_route_table" "tamako_route_table_pub" {
  vpc_id = aws_vpc.tamako_vpc.id
  tags = {
    Name = "${var.base_name}-route-table-pub"
  }
}

# プライベートサブネット用のルートテーブル
# プライベートサブネット用のルートテーブルを作成し、内部通信のルーティングを設定します。
resource "aws_route_table" "tamako_route_table_pri" {
  vpc_id = aws_vpc.tamako_vpc.id
  tags = {
    Name = "${var.base_name}-route-table-pri"
  }
}

# DB用ルートテーブルの作成
# データベース用のプライベートサブネットに適用するルートテーブルを作成します。
resource "aws_route_table" "tamako_route_table_db" {
  vpc_id = aws_vpc.tamako_vpc.id
  tags = {
    Name = "${var.base_name}-route-table-db"
  }
}

resource "aws_route" "tamako_pri_nat_route" {
  route_table_id         = aws_route_table.tamako_route_table_pri.id
  nat_gateway_id         = aws_nat_gateway.tamako_natgw.id
  destination_cidr_block = "0.0.0.0/0"

}


# インターネットゲートウェイ向けのルート
# ルートテーブルにインターネットゲートウェイ経由のルートを追加します。
resource "aws_route" "tamako_route" {
  route_table_id         = aws_route_table.tamako_route_table_pub.id
  gateway_id             = aws_internet_gateway.tamako_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# ルートテーブルとサブネットの関連付け
# パブリックサブネットに対してパブリックルートテーブルを関連付けます。
resource "aws_route_table_association" "tamako_route_asso_igw_pub1a" {
  route_table_id = aws_route_table.tamako_route_table_pub.id
  subnet_id      = aws_subnet.tamako_pubsub1.id
}

resource "aws_route_table_association" "tamako_route_asso_igw_pub1c" {
  route_table_id = aws_route_table.tamako_route_table_pub.id
  subnet_id      = aws_subnet.tamako_pubsub2.id
}

# プライベートサブネットに対してプライベートルートテーブルを関連付けます。
resource "aws_route_table_association" "tamako_route_asso_local_pri1a" {
  route_table_id = aws_route_table.tamako_route_table_pri.id
  subnet_id      = aws_subnet.tamako_prisub1.id
}

resource "aws_route_table_association" "tamako_route_asso_local_pri1c" {
  route_table_id = aws_route_table.tamako_route_table_pri.id
  subnet_id      = aws_subnet.tamako_prisub2.id
}

# DB用サブネットとルートテーブルの関連付け
# DB用プライベートサブネットに対して専用ルートテーブルを関連付けます。
resource "aws_route_table_association" "tamako_route_asso_db1a" {
  route_table_id = aws_route_table.tamako_route_table_db.id
  subnet_id      = aws_subnet.tamako_dbsub1.id
}

resource "aws_route_table_association" "tamako_route_asso_db1c" {
  route_table_id = aws_route_table.tamako_route_table_db.id
  subnet_id      = aws_subnet.tamako_dbsub2.id
}

