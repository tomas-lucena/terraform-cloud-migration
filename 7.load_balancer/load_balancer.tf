resource "aws_lb" "alb" {
  name               = "tf-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_loadbalance_id]
  subnets            = var.public_subnets_id

  enable_deletion_protection = false

  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.id
  #     prefix  = "tf_alb"
  #     enabled = true
  #   }

  tags = {
    Name = "tf_alb"
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "tf-alb-tg"
  port        = 8000
  target_type = "ip"
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  tags = {
    Name = "tf_alb_tg"
  }
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.domain_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
