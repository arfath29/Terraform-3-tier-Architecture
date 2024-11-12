resource "aws_lb" "web_LB" {
  name                       = "web-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.project_SG.id]
  subnets                    = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
  enable_deletion_protection = false
  tags = {
    Name = "web-lb"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.project_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    port                = "traffic-port"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
  }

  tags = {
    Name = "web-tg"
  }
}

resource "aws_lb_target_group_attachment" "web_attachment" {
  for_each         = { for i, instance in aws_instance.webapp_instance : i => instance }
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = each.value.id
  port             = 3000
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.web_LB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
