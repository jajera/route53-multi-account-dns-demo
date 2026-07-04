resource "aws_route53_vpc_association_authorization" "this" {
  for_each = var.authorized_vpcs

  zone_id    = var.zone_id
  vpc_id     = each.value.vpc_id
  vpc_region = each.value.vpc_region
}
