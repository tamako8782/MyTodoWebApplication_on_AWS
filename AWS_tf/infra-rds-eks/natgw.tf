
resource "aws_nat_gateway" "tamako_natgw" {
  allocation_id = aws_eip.tamako_eip.id
  subnet_id     = aws_subnet.tamako_pubsub1.id

  tags = {
    Name = "nat-gw"
  }

  depends_on = [aws_internet_gateway.tamako_igw]
}


resource "aws_eip" "tamako_eip" {
  domain = "vpc"

  tags = {
    Name = "eip"
  }
}