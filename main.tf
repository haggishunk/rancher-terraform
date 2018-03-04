# provision master node
# create non-root admin acct
# install docker with overlay driver
resource "digitalocean_droplet" "captain" {
  region             = "${var.region}"
  count              = "${var.master["qty"]}"
  image              = "${var.master["image"]}"
  name               = "${var.master["name"]}-${count.index}"
  size               = "${var.master["size"]}"
  backups            = "${var.backups}"
  ipv6               = "${var.ipv6}"
  monitoring         = "${var.monitoring}"
  resize_disk        = "${var.resize_disk}"
  private_networking = "${var.private_networking}"
  ssh_keys           = ["${var.ssh_ids}"]
  tags               = [
    "${digitalocean_tag.pennant.id}",
    "${digitalocean_tag.capn.id}",
  ]

  # volume_ids         = ["${var.volume_ids}"]

  # create admin acct
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = "${self.ipv4_address}"
      user        = "root"
    }
    inline = [
      "${data.template_file.newuser.rendered}",
    ]
  }
  # all further connections use admin acct
  connection {
    type        = "ssh"
    host        = "${self.ipv4_address}"
    user        = "${var.user}"
  }
  # docker storage driver
  provisioner "file" {
    content     = "${data.template_file.docker-daemon.rendered}"
    destination = "/home/${var.user}/daemon.json"
  }
  # SSL cert
  provisioner "file" {
    source      = "${path.root}/certs/${local.deployment_name}.${var.domain}.crt"
    destination = "/home/${var.user}/${local.deployment_name}.${var.domain}.crt"
  }
  # SSL key
  provisioner "file" {
    source      = "${path.root}/certs/${local.deployment_name}.${var.domain}.key"
    destination = "/home/${var.user}/${local.deployment_name}.${var.domain}.key"
  }
  # SSL cert & key placement
  provisioner "remote-exec" {
    inline = [
      "${data.template_file.ssl-certs.rendered}",
      ]
  }
  #  nginx reverse proxy configuration
  provisioner "file" {
    content = "${data.template_file.nginx-rancher-ui-conf.rendered}"
    destination = "/home/${var.user}/nginx-rancher-ui.conf"
  }
  # Nginx conf file placement
  provisioner "remote-exec" {
    inline = [
      "${data.template_file.nginx-conf.rendered}",
      ]
  }
}

resource "null_resource" "salty" {
  count = "${var.master["qty"]}"

  # all further connections use admin acct
  connection {
    type        = "ssh"
    host        = "${element(digitalocean_droplet.captain.*.ipv4_address, count.index)}"
    user        = "${var.user}"
  }
  # install docker & restart with selected storage driver
  provisioner "remote-exec" {
    inline = [
      "${data.template_file.docker-install.rendered}",
    ]
  }
  # start rancher server
  provisioner "remote-exec" {
    inline = [
      "${data.template_file.rancher-server.rendered}",
    ]
  }
  # start nginx server
  provisioner "remote-exec" {
    inline = [
      "${data.template_file.nginx.rendered}",
    ]
  }
  # make bash pretty
  provisioner "file" {
    content     = "${data.template_file.bashrc.rendered}"
    destination = "/home/${var.user}/.bashrc"
  }
  # make cursor movements natural
  provisioner "file" {
    content     = "${data.template_file.inputrc.rendered}"
    destination = "/home/${var.user}/.inputrc"
  }
}

output "captain_ip" {
  value = "${digitalocean_droplet.captain.*.ipv4_address}"
}

output "captain_ssh" {
  value = "${var.user}@${digitalocean_droplet.captain.*.ipv4_address}"
}
