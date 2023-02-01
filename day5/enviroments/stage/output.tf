output "vpc_ids" {
    value =module.vpc_stage.vpc_id
}

output "subnets_ids" {
    value =module.vpc_stage.public_subnet_ids
}