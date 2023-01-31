data "terraform_remote_state" "networkin" {
  backend = "s3"  
  config = {
    bucket = "news3bucketfornazik" // Bucket from where to GET Terraform State
    key    = "allthefilesaregere/dev/terraform.tfstate"             // Object name in the bucket to GET Terraform state
    region = "eu-west-1"                                 // Region where bycket created
  }
}


resource "aws_launch_template" "template" {
  name          = "launch-template"
  image_id      = "ami-0cb28ea0477916126"
  instance_type = "t3.micro"
  user_data     = base64encode("#!/bin/bash \nsudo su \napt install apache2 -y \nsystemctl enable apache2 -y \nsystemctl start apache2 -y \necho \"Hello, World!\" > /var/www/html/index.html")
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.value.id]

  }
}

resource "aws_security_group" "value" {
  name   = "WebServer Security Group"
  vpc_id = data.terraform_remote_state.networkin.outputs.vpc_id

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "egress" {
    for_each = [0]
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }

  tags = {
    Name  = "SecurityGroup"
    Owner = "Nazik"
  }
}

resource "aws_autoscaling_group" "asg" {
  name              = "foobar3-terraform-test"
  max_size          = 4
  min_size          = 2
  desired_capacity  = 3
  force_delete      = true
  target_group_arns = [aws_lb_target_group.test1.id]
  launch_template {
    id = aws_launch_template.template.id
  }
  vpc_zone_identifier = data.terraform_remote_state.networkin.outputs.public_subnet_ids
  depends_on = [
    aws_launch_template.template
  ]
}

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.value.id]
  subnets            = data.terraform_remote_state.networkin.outputs.public_subnet_ids
  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test1.arn
  }

}
resource "aws_lb_target_group" "test1" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.networkin.outputs.vpc_id
}
