output "authorization_ids" {
  description = "Map of label to authorization resource ID"
  value       = { for k, v in aws_route53_vpc_association_authorization.this : k => v.id }
}
