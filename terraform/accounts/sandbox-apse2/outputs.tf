output "vpc_id" {
  description = "Sandbox ap-southeast-2 VPC ID"
  value       = module.stack.vpc_id
}

output "test_ec2_instance_id" {
  description = "Test EC2 instance ID (for SSM connect)"
  value       = module.stack.test_ec2_instance_id
}
