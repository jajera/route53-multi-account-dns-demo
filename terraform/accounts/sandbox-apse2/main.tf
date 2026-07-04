module "stack" {
  source = "../../modules/workload-stack"

  name_prefix             = "r53demo-sandbox-apse2"
  cidr_block              = "10.2.0.0/16"
  aws_region              = var.aws_region
  zone_id                 = var.zone_id
  enable_zone_association = var.enable_zone_association
  enable_test_ec2         = var.enable_test_ec2
  instance_type           = var.instance_type
}
