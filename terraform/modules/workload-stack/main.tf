module "vpc" {
  source = "../vpc"

  name_prefix                = var.name_prefix
  cidr_block                 = var.cidr_block
  aws_region                 = var.aws_region
  enable_ssm_vpc_endpoints   = var.enable_ssm_vpc_endpoints
  ssm_vpc_endpoint_services  = var.ssm_vpc_endpoint_services
  enable_nat_gateway         = var.enable_nat_gateway
}

resource "aws_route53_zone_association" "this" {
  count = var.enable_zone_association ? 1 : 0

  zone_id    = var.zone_id
  vpc_id     = module.vpc.vpc_id
  vpc_region = var.aws_region
}

module "test_ec2" {
  count  = var.enable_test_ec2 ? 1 : 0
  source = "../test-ec2"

  name_prefix   = var.name_prefix
  instance_type = var.instance_type
  subnet_id     = module.vpc.private_subnet_ids[0]
  vpc_id        = module.vpc.vpc_id
}
