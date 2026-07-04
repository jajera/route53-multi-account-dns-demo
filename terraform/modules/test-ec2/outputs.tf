output "instance_id" {
  description = "EC2 instance ID (for SSM connect)"
  value       = aws_instance.this.id
}
