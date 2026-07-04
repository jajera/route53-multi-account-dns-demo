output "zone_id" {
  description = "Private hosted zone ID"
  value       = try(module.private_hosted_zone[0].zone_id, "")
}

output "vpc_id_primary" {
  description = "Network primary VPC ID (ap-southeast-2)"
  value       = module.vpc_primary.vpc_id
}

output "vpc_id_secondary" {
  description = "Network secondary VPC ID (ap-southeast-2)"
  value       = module.vpc_secondary.vpc_id
}

output "test_ec2_instance_id_primary" {
  description = "Primary test EC2 instance ID (for SSM connect)"
  value       = try(module.test_ec2_primary[0].instance_id, "")
}

output "test_ec2_instance_id_secondary" {
  description = "Secondary test EC2 instance ID (for SSM connect)"
  value       = try(module.test_ec2_secondary[0].instance_id, "")
}
