resource "aws_lb" "public_elb" {
  name               = var.public_elb_name
  internal           = var.internal
  load_balancer_type = var.elb_type 
  security_groups    = var.public_elb_sg
  subnets            = var.public_elb_subnet
}

resource "aws_lb_target_group" "public-tg" {
  name     = var.elb_tg_name
  port     = var.elb_public_port
  protocol = var.elb_public_protocol
  vpc_id   = var.elb_public_vpc_id
   health_check {
    enabled             = var.enabled
    healthy_threshold   = var.healthy_threshold
    interval            = var.interval 
    matcher             = var.matcher 
    port                = var.port 
    protocol            = var.protocol
    timeout             = var.timeout 
    unhealthy_threshold = var.unhealthy_threshold
  }

}

resource "aws_lb_listener" "public_listener" {
  load_balancer_arn = aws_lb.public_elb.arn
  port              = var.elb_tg_listener_port
  protocol          = var.elb_tg_listener
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public-tg.arn
  }
}


resource "aws_lb" "private_elb" {
  name               = var.private_elb_name
  internal           = var.interal_elb
  load_balancer_type = var.elb_type_internal 
  security_groups    = var.private_elb_sg
  subnets            = var.private_elb_subnet
}

resource "aws_lb_target_group" "private_tg" {
  name     = var.private_tg_name 
  port     = var.private_tg_port
  protocol = var.private_tg_protocol
  vpc_id   = var.private_tg_vpc_id
  
}

resource "aws_lb_listener" "internal_end" {
  load_balancer_arn = aws_lb.private_elb.arn
  port              = var.private_tg_listener_port
  protocol          = var.private_tg_listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private_tg.arn
  }
}


