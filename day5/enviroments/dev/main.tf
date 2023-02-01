module "vpc_dev" {
  source             = "../../modules/networking"
  vpc-cidr-block     = "10.1.0.0/18"
  subnets-cidr-block = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

module "autoscalling" {
  source = "../../modules/autoscalling"

  subnets       = module.vpc_dev.public_subnet_ids
  vpc_id           = module.vpc_dev.vpc_id

  image-id      = "ami-0cb28ea0477916126"
  instance-type = "t2.micro"
  lb-type       = "application"
}

#===============================
