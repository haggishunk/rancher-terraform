data "template_file" "newuser" {
  template = "${file("${path.root}/terraform-template-files/newuser-template.sh")}"

  vars {
    user = "${var.user}"
  }
}

data "template_file" "docker-install" {
  template = "${file("${path.root}/terraform-template-files/docker-install-17.03.sh")}"

  vars {
    user = "${var.user}"
  }
}

data "template_file" "docker-daemon" {
  template = "${file("${path.root}/terraform-template-files/docker-daemon.json")}"

  vars {
    storage_driver = "${var.storage_driver}"
  }
}

data "template_file" "ssl-certs" {
  template = "${file("${path.root}/terraform-template-files/ssl-certs.sh")}"

  vars {
    cert_name = "${local.deployment_name}.${var.domain}"
  }
}

data "template_file" "rancher-server" {
  template = "${file("${path.root}/terraform-template-files/rancher-server.sh")}"

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
  template = "${file("${path.root}/terraform-template-files/nginx.sh")}"

  vars {
    rancher-name = "${local.rancher_name}"
  }
}

data "template_file" "nginx-rancher-ui-conf" {
  template = "${file("${path.root}/terraform-template-files/nginx-rancher-ui.conf")}"

  vars {
    container_name = "${local.rancher_name}"
    domain_name    = "${var.domain}"
  }
}

data "template_file" "nginx-conf" {
  template = "${file("${path.root}/terraform-template-files/nginx-conf.sh")}"
}

data "template_file" "inputrc" {
  template = "${file("${path.root}/terraform-template-files/inputrc")}"
}

data "template_file" "bashrc" {
  template = "${file("${path.root}/terraform-template-files/bashrc")}"

  vars {
    col1 = 39
    col2 = 202
  }
}
