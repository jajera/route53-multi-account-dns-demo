resource "aws_route53_zone" "this" {
  name = var.zone_name

  vpc {
    vpc_id = var.vpc_id
  }

  tags = {
    Name = var.zone_name
  }
}

resource "aws_route53_record" "this" {
  for_each = var.records

  zone_id = aws_route53_zone.this.zone_id
  name    = each.key
  type    = each.value.type
  ttl     = 300
  records = [each.value.value]
}
