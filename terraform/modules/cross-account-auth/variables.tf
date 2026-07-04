variable "zone_id" {
  type        = string
  description = "The PHZ to authorize against"
}

variable "authorized_vpcs" {
  type = map(object({
    vpc_id     = string
    vpc_region = string
  }))
  description = "Map of label to VPC ID and region to authorize (e.g., dev_apse2 = { vpc_id = \"vpc-xxx\", vpc_region = \"ap-southeast-2\" })"
}
