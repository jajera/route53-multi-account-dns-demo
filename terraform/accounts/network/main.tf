module "vpc_primary" {
  source = "../../modules/vpc"

  name_prefix = "r53demo-network-apse2-primary"
  cidr_block  = "10.0.0.0/16"
  aws_region  = var.aws_region
}

module "vpc_secondary" {
  source = "../../modules/vpc"

  name_prefix = "r53demo-network-apse2-secondary"
  cidr_block  = "10.3.0.0/16"
  aws_region  = var.aws_region
}

module "private_hosted_zone" {
  count  = var.enable_phz ? 1 : 0
  source = "../../modules/private-hosted-zone"

  zone_name = "platform.${var.demo_domain}"
  vpc_id    = module.vpc_primary.vpc_id
  records = {
    api = {
      type  = "A"
      value = "10.0.1.10"
    }
    db = {
      type  = "A"
      value = "10.0.1.20"
    }
  }
}

resource "aws_route53_zone_association" "secondary" {
  count = var.enable_phz ? 1 : 0

  zone_id    = module.private_hosted_zone[0].zone_id
  vpc_id     = module.vpc_secondary.vpc_id
  vpc_region = var.aws_region
}

module "cross_account_auth" {
  count  = var.enable_phz && var.enable_cross_account_auth ? 1 : 0
  source = "../../modules/cross-account-auth"

  zone_id = module.private_hosted_zone[0].zone_id
  authorized_vpcs = {
    dev_apse2 = {
      vpc_id     = var.dev_apse2_vpc_id
      vpc_region = "ap-southeast-2"
    }
    dev_apse6 = {
      vpc_id     = var.dev_apse6_vpc_id
      vpc_region = "ap-southeast-6"
    }
    sandbox_apse2 = {
      vpc_id     = var.sandbox_apse2_vpc_id
      vpc_region = "ap-southeast-2"
    }
    sandbox_apse6 = {
      vpc_id     = var.sandbox_apse6_vpc_id
      vpc_region = "ap-southeast-6"
    }
  }
}

module "test_ec2_primary" {
  count  = var.enable_test_ec2 ? 1 : 0
  source = "../../modules/test-ec2"

  name_prefix   = "r53demo-network-apse2-primary"
  instance_type = var.instance_type
  subnet_id     = module.vpc_primary.private_subnet_ids[0]
  vpc_id        = module.vpc_primary.vpc_id
}

module "test_ec2_secondary" {
  count  = var.enable_test_ec2 ? 1 : 0
  source = "../../modules/test-ec2"

  name_prefix   = "r53demo-network-apse2-secondary"
  instance_type = var.instance_type
  subnet_id     = module.vpc_secondary.private_subnet_ids[0]
  vpc_id        = module.vpc_secondary.vpc_id
}
