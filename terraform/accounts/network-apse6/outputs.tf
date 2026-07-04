output "vpc_id" {
  description = "Network ap-southeast-6 VPC ID"
  value       = module.vpc.vpc_id
}

output "nat_gateway_enabled" {
  description = "Whether a NAT gateway was created for private subnet internet egress"
  value       = module.vpc.nat_gateway_enabled
}

output "ssm_vpc_endpoints_enabled" {
  description = "Whether any SSM interface VPC endpoints were created"
  value       = module.vpc.ssm_vpc_endpoints_enabled
}

output "ssm_vpc_endpoint_services" {
  description = "SSM endpoint service suffixes created in this VPC"
  value       = module.vpc.ssm_vpc_endpoint_services
}

output "test_ec2_instance_id" {
  description = "Test EC2 instance ID (for SSM connect)"
  value       = try(module.test_ec2[0].instance_id, "")
}
