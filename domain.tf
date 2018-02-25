# add an alias 'A' record
resource "digitalocean_record" "alias" {
  name   = "${local.deployment_name}"
  type   = "A"
  domain = "${var.domain}"
  value  = "${digitalocean_droplet.captain.0.ipv4_address}"
  ttl    = 600
}

# add a wildcard CNAME record to support subdomain reverse proxying
resource "digitalocean_record" "wildcard" {
  name   = "*.${local.deployment_name}"
  type   = "CNAME"
  domain = "${var.domain}"
  value  = "${local.deployment_name}.${var.domain}."
  ttl    = 600
}
