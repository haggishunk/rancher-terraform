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
      private_key = "${file(var.ssh_pri_file)}"
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
    private_key = "${file(var.ssh_pri_file)}"
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
  # send nginx reverse proxy script
  provisioner "file" {
    source = "${path.root}/nginx/conf.d/rancher-ui-ssl.conf.py"
    destination = "/home/${var.user}/rancher-ui-ssl.conf.py"
  }
}

resource "null_resource" "salty" {
  count = "${var.master["qty"]}"

  # all further connections use admin acct
  connection {
    type        = "ssh"
    host        = "${element(digitalocean_droplet.captain.*.ipv4_address, count.index)}"
    user        = "${var.user}"
    private_key = "${file(var.ssh_pri_file)}"
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
  # start rancher server
  provisioner "remote-exec" {
    inline = [
      "${data.template_file.nginx.rendered}",
    ]
  }
}

output "captain_ip" {
  value = "${digitalocean_droplet.captain.*.ipv4_address}"
}
