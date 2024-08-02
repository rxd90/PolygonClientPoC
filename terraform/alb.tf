# AWS ALB
resource "aws_lb" "trustwallet_alb" {
  name               = "trustwallet-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.trustwallet_sg.id]
  subnets            = concat(data.aws_subnets.public_primary_dev_subnets.ids, data.aws_subnets.public_secondary_dev_subnets.ids)

  enable_deletion_protection = false

  tags = {
    Name = "trustwallet-alb"
  }
}

resource "aws_lb_target_group" "trustwallet_tg" {
  name     = "trustwallet-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc_dev.id
  target_type = "ip"

  health_check {
    interval            = 30
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "trustwallet-tg"
  }
}

resource "aws_lb_listener" "trustwallet_listener" {
  load_balancer_arn = aws_lb.trustwallet_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.trustwallet_tg.arn
  }

  tags = {
    Name = "trustwallet-listener"
  }
}