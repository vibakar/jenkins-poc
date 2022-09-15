data "aws_route53_zone" "poc" {
  name = var.ROOT_DOMAIN
}

resource "aws_route53_record" "poc" {
  zone_id = data.aws_route53_zone.poc.zone_id
  name    = var.APPLICATION_DOMAIN
  type    = "A"
  ttl     = "300"
  records = [aws_instance.master.public_ip]
}