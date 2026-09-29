resource "aws_security_group" "alb" {
  name   = "${var.name}-alb"
  vpc_id = aws_vpc.main.id
}

resource "aws_lb" "web" {
  name               = "${var.name}-web"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "web" {
  name     = "${var.name}-web"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# A local module instantiated once per tier with for_each.
module "tier" {
  source   = "./modules/app_tier"
  for_each = var.tiers

  name           = "${var.name}-${each.key}"
  instance_type  = each.value.instance_type
  instance_count = each.value.instance_count
  data_volumes   = each.value.data_volumes
  subnet_ids     = aws_subnet.private[*].id
}
