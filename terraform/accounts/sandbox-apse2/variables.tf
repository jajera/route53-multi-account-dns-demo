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
