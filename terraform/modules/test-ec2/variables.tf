variable "name_prefix" {
  type        = string
  description = "Naming prefix for all resources"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t4g.nano"
}

variable "subnet_id" {
  type        = string
  description = "Private subnet to place the instance"
}

variable "vpc_id" {
  type        = string
  description = "VPC for security group"
}
