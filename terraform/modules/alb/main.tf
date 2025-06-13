resource "aws_lb" "app" {
  name               = "kiusys-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnets
}