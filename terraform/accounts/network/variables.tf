variable "aws_region" {
  type        = string
  description = "AWS region for deployment"
  default     = "ap-southeast-2"
}

variable "project_name" {
  type        = string
  description = "Project name applied as a default tag on all resources"
  default     = "r53demo"
}

variable "account_name" {
  type        = string
  description = "Account label applied as a default tag on all resources"
  default     = "network"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for test instances"
  default     = "t4g.nano"
}

variable "demo_domain" {
  type        = string
  description = "Base domain for the demo"
  default     = "demo.local"
}

variable "enable_phz" {
  type        = bool
  description = "Set false for Phase 1 (VPCs only)"
  default     = true
}

variable "enable_cross_account_auth" {
  type        = bool
  description = "Set false for Phase 1 (authorizations require workload VPC IDs from Phase 1)"
  default     = true
}

variable "enable_test_ec2" {
  type        = bool
  description = "Set false for Phase 1 (VPC only)"
  default     = true
}

variable "dev_apse2_vpc_id" {
  type        = string
  description = "Dev ap-southeast-2 VPC ID (from Phase 1 output)"
  default     = ""
}

variable "dev_apse6_vpc_id" {
  type        = string
  description = "Dev ap-southeast-6 VPC ID (from Phase 1 output)"
  default     = ""
}

variable "sandbox_apse2_vpc_id" {
  type        = string
  description = "Sandbox ap-southeast-2 VPC ID (from Phase 1 output)"
  default     = ""
}

variable "sandbox_apse6_vpc_id" {
  type        = string
  description = "Sandbox ap-southeast-6 VPC ID (from Phase 1 output)"
  default     = ""
}
