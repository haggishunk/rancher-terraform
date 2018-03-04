# provision worker node
# create non-root admin acct
# install docker with overlay driver
resource "digitalocean_droplet" "fisherman" {
  region             = "${var.region}"
  count              = "${var.worker["qty"]}"
  image              = "${var.worker["image"]}"
  name               = "${var.worker["name"]}-${count.index}"
  size               = "${var.worker["size"]}"
  backups            = "${var.backups}"
  ipv6               = "${var.ipv6}"
  monitoring         = "${var.monitoring}"
  resize_disk        = "${var.resize_disk}"
  private_networking = "${var.private_networking}"
  ssh_keys           = ["${var.ssh_ids}"]
  tags               = ["${digitalocean_tag.pennant.id}"]

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
  # install docker & restart with selected storage driver
  provisioner "remote-exec" {
    inline = [
      "${data.template_file.docker-install.rendered}",
    ]
  }
}

resource "null_resource" "sealegs" {
  count = "${var.worker["qty"]}"
  connection {
    type        = "ssh"
    host        = "${element(digitalocean_droplet.fisherman.*.ipv4_address, count.index)}"
    user        = "${var.user}"
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

output "fisherman_ip" {
  value = "${digitalocean_droplet.fisherman.*.ipv4_address}"
}
