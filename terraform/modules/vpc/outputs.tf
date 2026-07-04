output "vpc_id" {
  description = "VPC identifier"
  value       = aws_vpc.this.id
}

output "private_subnet_ids" {
  description = "IDs of the two private subnets"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_enabled" {
  description = "Whether a NAT gateway was created for private subnet internet egress"
  value       = var.enable_nat_gateway
}

output "ssm_vpc_endpoints_enabled" {
  description = "Whether any SSM interface VPC endpoints were created"
  value       = length(local.selected_ssm_endpoints) > 0
}

output "ssm_vpc_endpoint_services" {
  description = "SSM-related endpoint service suffixes created (Session Manager needs ssm, ssmmessages, and ec2messages when available in the region)"
  value       = sort(keys(local.selected_ssm_endpoints))
}
