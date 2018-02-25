locals {
  deployment_name = "${basename("${path.root}")}"
  rancher_name = "rancher-${local.deployment_name}"
}
