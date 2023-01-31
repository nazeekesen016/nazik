data "terraform_remote_state" "network" {
      backend = "local"
      config = {
      path = "../VPCandSubnets/terraform.tfstate"
      }
}

resource "aws_instance" "terraforminstance" {
    for_each = toset(data.terraform_remote_state.network.outputs.public_subnet_ids)
    subnet_id = each.key
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type != [] ? "t3.micro" : "t3.micro"

  tags = {
    Name = var.instance_name == 5 ? "HelloWorld" : "NotHelloWorld"
  }
}

resource "aws_lb_target_group" "terraform" {
  name     =  var.instance_name != 0 ? "tf-example-lb" : "noname"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id
}

resource "aws_lb_target_group_attachment" "terraform" {
    for_each = {for i, v in aws_instance.terraforminstance : i => v.id}
  target_group_arn = aws_lb_target_group.terraform.id
  target_id        = each.value
  port             = 80
}

output "id" {
  value = {for i, v in aws_instance.terraforminstance : i => v.id}
}
