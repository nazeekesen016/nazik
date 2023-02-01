output "vpc_ids" {
    value =module.vpc_dev.vpc_id
}

output "subnets_ids" {
    value =module.vpc_dev.public_subnet_ids
}