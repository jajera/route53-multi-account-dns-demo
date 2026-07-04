variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR block"
}

variable "aws_region" {
  type        = string
  description = "AWS region for VPC deployment"
}

variable "zone_id" {
  type        = string
  description = "Network PHZ zone ID (from Phase 2 output). Required when enable_zone_association is true."
  default     = ""

  validation {
    condition     = !var.enable_zone_association || var.zone_id != ""
    error_message = "zone_id is required when enable_zone_association is true."
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

variable "instance_type" {
  type        = string
  description = "EC2 instance type for test instances"
  default     = "t4g.nano"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Create a single-AZ NAT gateway for private subnet internet egress (optional; default false)"
  default     = false
}

variable "enable_ssm_vpc_endpoints" {
  type        = bool
  description = "Create SSM interface VPC endpoints in this VPC (default true; no NAT required when all services exist in the region)"
  default     = true
}

variable "ssm_vpc_endpoint_services" {
  type        = set(string)
  description = "SSM endpoint suffixes to create. Session Manager needs ssm, ssmmessages, and ec2messages where AWS offers them."
  default     = ["ssm", "ssmmessages", "ec2messages"]
}
