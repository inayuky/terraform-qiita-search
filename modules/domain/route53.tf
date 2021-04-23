variable "name" {
  description = "ドメイン名"
}
variable "lb_dns_name" {
  description = "LBのDNS名"
}
variable "lb_zone_id" {
  description = "LBのゾーンid"
}

data "aws_route53_zone" "this" {
  name = var.name
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.name
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier = "prod"

}

