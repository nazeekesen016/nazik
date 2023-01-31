output "vpc_id" {
  value = aws_vpc.my-vpc.id
}
output "public_subnet_ids" {
  value = aws_subnet.subnet1.*.id
}