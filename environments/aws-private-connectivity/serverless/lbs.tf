resource "aws_lb" "main" {
  name                       = lower(var.name_prefix)
  load_balancer_type         = "network"
  internal                   = true
  subnets                    = data.aws_subnets.dmz.ids
  enable_deletion_protection = false
  security_groups            = [aws_security_group.nlb.id]

  enforce_security_group_inbound_rules_on_private_link_traffic = "off"

  access_logs {
    bucket  = aws_s3_bucket.logs.id
    prefix  = "main"
    enabled = true
  }

  depends_on = [aws_s3_bucket_policy.logs]
}

resource "aws_lb" "router" {
  name                       = lower("${var.name_prefix}-router")
  load_balancer_type         = "application"
  internal                   = true
  subnets                    = data.aws_subnets.dmz.ids
  enable_deletion_protection = false
  security_groups            = [aws_security_group.alb.id]

  access_logs {
    bucket  = aws_s3_bucket.logs.id
    prefix  = "router"
    enabled = true
  }

  depends_on = [aws_s3_bucket_policy.logs]
}

resource "aws_lb_target_group" "tcp_80" {
  name        = upper("${var.name_prefix}-tcp-80")
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = local.aws_vpc_id
}

resource "aws_lb_target_group" "tcp_443" {
  name        = upper("${var.name_prefix}-tcp-443")
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = local.aws_vpc_id
}

resource "aws_lb_listener" "tcp_80" {
  load_balancer_arn = aws_lb.main.arn
  protocol          = "TCP"
  port              = 80

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tcp_80.arn
  }
}

resource "aws_lb_listener" "tcp_443" {
  load_balancer_arn = aws_lb.main.arn
  protocol          = "TCP"
  port              = 443

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tcp_443.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.router.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "400"
    }
  }
}

resource "aws_lb_listener_rule" "http_status" {
  listener_arn = aws_lb_listener.http.arn

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = 200
    }
  }

  condition {
    path_pattern {
      values = ["/status"]
    }
  }

  condition {
    host_header {
      values = ["api.example.com"]
    }
  }
}

resource "aws_lb_target_group_attachment" "tcp_80" {
  target_group_arn = aws_lb_target_group.tcp_80.arn
  target_id        = aws_lb.router.arn
  depends_on       = [aws_lb_listener.http]
}
