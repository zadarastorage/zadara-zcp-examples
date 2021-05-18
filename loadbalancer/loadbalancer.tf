resource "aws_alb_target_group" "instances" {
  name     = "demo-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc}"
}

resource "aws_alb_target_group_attachment" "attach_web_servers" {
  target_group_arn = aws_alb_target_group.instances.arn
  target_id        = element(aws_instance.server.*.id, count.index)
  port             = 80
  count = var.quantity
}

resource "aws_alb" "alb" {
  name               = "demo-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb.id]
  subnet_mapping {
    subnet_id     = "${var.subnet}"
  }
}

resource "aws_alb_listener" "alb" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
  type             = "forward"
  target_group_arn = aws_alb_target_group.instances.arn
  }
}
