module "firewall-basic" {
  source = "../../modules/firewall/do/basic"

  deployment_name = "${local.deployment_name}-${terraform.env}"
  update_tag_ids  = ["${digitalocean_tag.pennant.id}"]
  ssh_tag_ids     = ["${digitalocean_tag.pennant.id}"]
  ssh_admin_ips   = ["0.0.0.0/0"]
}

module "firewall-rancher" {
  source = "../../modules/firewall/do/rancher"

  deployment_name = "${local.deployment_name}-${terraform.env}"
  ipsec_tag_ids   = ["${digitalocean_tag.pennant.id}"]
  ha_tag_ids      = ["${digitalocean_tag.capn.id}"]
  web_tag_ids     = ["${digitalocean_tag.pennant.id}"]
  ipsec_ips       = ["${concat(digitalocean_droplet.captain.*.ipv4_address, digitalocean_droplet.fisherman.*.ipv4_address)}"]
  ha_ips          = ["${digitalocean_droplet.captain.*.ipv4_address}"]
  web_ips         = ["0.0.0.0/0"]
}
