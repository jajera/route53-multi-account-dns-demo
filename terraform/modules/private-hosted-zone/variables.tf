variable "zone_name" {
  type        = string
  description = "FQDN for the zone (e.g., platform.demo.local)"
}

variable "vpc_id" {
  type        = string
  description = "Central VPC to associate with the private hosted zone"
}

variable "records" {
  type = map(object({
    type  = string
    value = string
  }))
  description = "Map of record name to { type, value } for DNS records in the zone"
}
