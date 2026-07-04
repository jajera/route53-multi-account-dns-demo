module "stack" {
  source = "../../modules/workload-stack"

  name_prefix               = "r53demo-dev-apse6"
  cidr_block                = "10.11.0.0/16"
  aws_region                = var.aws_region
  zone_id                   = var.zone_id
  enable_zone_association   = var.enable_zone_association
  enable_test_ec2           = var.enable_test_ec2
  instance_type             = var.instance_type
  enable_ssm_vpc_endpoints  = var.enable_ssm_vpc_endpoints
  ssm_vpc_endpoint_services = var.ssm_vpc_endpoint_services
  enable_nat_gateway        = var.enable_nat_gateway
}
