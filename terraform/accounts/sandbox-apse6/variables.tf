variable "aws_region" {
  type        = string
  description = "AWS region for deployment"
  default     = "ap-southeast-6"
}

variable "project_name" {
  type        = string
  description = "Project name applied as a default tag on all resources"
  default     = "r53demo"
}

variable "account_name" {
  type        = string
  description = "Account label applied as a default tag on all resources"
  default     = "sandbox"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for test instances"
  default     = "t4g.nano"
}

variable "zone_id" {
  type        = string
  description = "Network PHZ zone ID (from network Phase 2a output). Required when enable_zone_association is true — set in terraform.tfvars or -var on every re-apply."
  default     = ""

  validation {
    condition     = !var.enable_zone_association || var.zone_id != ""
    error_message = "zone_id is required when enable_zone_association is true. Re-applying without it destroys the existing Route 53 VPC association."
  }
}

variable "enable_zone_association" {
  type        = bool
  description = "Set false for Phase 1 (VPC only)"
  default     = true
}

variable "enable_test_ec2" {
  type        = bool
  description = "Set false for Phase 1 (VPC only)"
  default     = true
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Create a single-AZ NAT gateway so private subnets reach the internet (enables SSM before ec2messages endpoint exists in ap-southeast-6)"
  default     = false
}

variable "enable_ssm_vpc_endpoints" {
  type        = bool
  description = "Create SSM interface VPC endpoints (default true; required for Session Manager without NAT)"
  default     = true
}

variable "ssm_vpc_endpoint_services" {
  type        = set(string)
  description = "SSM endpoint suffixes to create. Default omits ec2messages until AWS launches it in ap-southeast-6."
  default     = ["ssm", "ssmmessages"]
}
