resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "application"
  internal           = false
  idle_timeout       = 60

  subnets = [
    var.subnet0_id,
    var.subnet1_id
  ]

  access_logs {
    bucket  = var.log_bucket_id
    enabled = true
  }

  security_groups = [
    var.https_sg_id,
    var.http_redirect_sg_id,
  ]
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.acm_certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service Unavailable"
      status_code  = "503"
    }
  }
}

resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "this" {
  name                 = var.target_group_name
  vpc_id               = var.vpc_id
  port                 = var.target_group_port
  protocol             = "HTTP"
  deregistration_delay = 300

  health_check {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
    matcher             = 200
    port                = "traffic-port" # 上で指定したportが使用される。
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.this]
}

resource "aws_lb_listener_rule" "forbidden" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 99

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }

  condition {
    path_pattern {
      values = ["/admin/*", "/login/*", "/profile/*", "/help/*"]
    }
  }
}

resource "aws_lb_listener_rule" "all" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.instance_id
  port             = var.target_group_port
}
