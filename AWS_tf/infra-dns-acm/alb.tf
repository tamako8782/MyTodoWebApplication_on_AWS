resource "aws_lb" "tamako_alb" {
  name               = "tamako-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tamako_alb_sg.id]
  subnets            = data.terraform_remote_state.infra_rds_eks.outputs.public_subnets

}

resource "aws_security_group" "tamako_alb_sg" {
  name        = "tamako-alb-sg"
  description = "Security group for ALB"
  vpc_id      = data.terraform_remote_state.infra_rds_eks.outputs.vpc_id

  # インバウンドルール
  ingress {
    description = "Allow HTTP traffic on port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 全てのIPアドレスから許可 (適宜変更)
  }

  ingress {
    description = "Allow HTTPS traffic on port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tamako-alb-sg"
  }
}


resource "aws_lb_target_group" "tamako_alb_tg" {
  name        = "tamako-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.infra_rds_eks.outputs.vpc_id
  target_type = "ip"
}




resource "aws_lb_listener" "tamako_listener" {
  load_balancer_arn = aws_lb.tamako_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn   = aws_acm_certificate.tamako_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tamako_alb_tg.arn
  }
}

