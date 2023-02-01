data "aws_availability_zones" "available" {}

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc-cidr-block
  tags =  {
  name = "vpc-${var.name}" }
}

resource "aws_subnet" "subnet1" {
  count = length(var.subnets-cidr-block)
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = var.subnets-cidr-block[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    name = "${var.subnet-name}[count.index]"
  }

 
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
  count = length(var.subnets-cidr-block)
  subnet_id      = aws_subnet.subnet1[count.index].id
  route_table_id = aws_route_table.rt.id
}
