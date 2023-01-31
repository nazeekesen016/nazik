locals {
    name = "Terraform-VPC"
    subnet_names = ["subnet1", "subnet2", "subnet3"]
    cidr_block = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}


resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/18"
  tags =  {
  name = "vpc-${local.name}" }
}



resource "aws_subnet" "subnet1" {
  count = 3
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = local.cidr_block[count.index]
  tags = {
    name = local.subnet_names[count.index]
  }

  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true
  depends_on = [
    aws_vpc.my-vpc
  ]
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my-vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" { 
  count = 3
  subnet_id      = aws_subnet.subnet1[count.index].id
  route_table_id = aws_route_table.rt.id
}
