variable "name_prefix" {
  type        = string
  description = "Naming prefix for all resources"
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR (e.g., 10.0.0.0/16)"
}

variable "aws_region" {
  type        = string
  description = "AWS region for AZ selection"
}

variable "enable_ssm_vpc_endpoints" {
  type        = bool
  default     = true
  description = "Create SSM-related interface VPC endpoints for Session Manager from private subnets (no NAT required when all required services exist in the region)."
}

variable "enable_nat_gateway" {
  type        = bool
  default     = false
  description = "Create a single-AZ NAT gateway with internet gateway and public subnet so private subnets can reach the internet (enables SSM without all three interface endpoints)."
}

variable "ssm_vpc_endpoint_services" {
  type        = set(string)
  default     = ["ssm", "ssmmessages", "ec2messages"]
  description = "SSM endpoint service suffixes to create when enable_ssm_vpc_endpoints is true. Session Manager in a private subnet requires all three in regions where AWS offers them."

  validation {
    condition = alltrue([
      for s in var.ssm_vpc_endpoint_services : contains(["ssm", "ssmmessages", "ec2messages"], s)
    ])
    error_message = "ssm_vpc_endpoint_services must be a subset of: ssm, ssmmessages, ec2messages."
  }
}

locals {
  ssm_endpoint_service_names = {
    ssm         = "ssm"
    ssmmessages = "ssmmessages"
    ec2messages = "ec2messages"
  }

  selected_ssm_endpoints = var.enable_ssm_vpc_endpoints ? {
    for key, suffix in local.ssm_endpoint_service_names : key => suffix
    if contains(var.ssm_vpc_endpoint_services, key)
  } : {}
}
