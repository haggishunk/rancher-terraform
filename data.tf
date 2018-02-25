data "template_file" "newuser" {
  template = "${file("${path.root}/templates/newuser-template.sh")}"

  vars {
    user = "${var.user}"
  }
}

data "template_file" "docker-install" {
  template = "${file("${path.root}/templates/docker-install.sh")}"

  vars {
    user = "${var.user}"
  }
}

data "template_file" "docker-daemon" {
  template = "${file("${path.root}/templates/docker-daemon.json")}"

  vars {
    storage_driver = "${var.storage_driver}"
  }
}

data "template_file" "ssl-certs" {
  template = "${file("${path.root}/templates/ssl-certs.sh")}"

  vars {
    user      = "${var.user}"
    cert_name = "${local.deployment_name}.${var.domain}"
  }
}

data "template_file" "rancher-server" {
  template = "${file("${path.root}/templates/rancher-server.sh")}"

  vars {
    rancher-name = "${local.rancher_name}"
    db-host      = "${var.db-host}"
    db-port      = "${var.db-port}"
    db-name      = "${var.db-name}"
    db-user      = "${var.db-user}"
    db-pass      = "${var.db-pass}"
  }
}

data "template_file" "nginx" {
  template = "${file("${path.root}/templates/nginx.sh")}"

  vars {
    rancher-name = "${local.rancher_name}"
    user         = "${var.user}"
  }
}
