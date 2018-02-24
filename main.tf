data "template_file" "newuser" {
  template = "${file("${path.root}/newuser-template.sh")}"

  vars {
    user = "${var.user}"
  }
}

data "template_file" "docker-install" {
  template = "${file(path.root/docker-install.sh)}"

  vars {
    user = "${var.user}"
  }
}

# provision master node
# create non-root admin acct
# install docker with overlay driver
resource "digitalocean_droplet" "captain" {
  count              = "${var.count}"
  image              = "${var.image}"
  name               = "${var.name}-${count.index}"
  region             = "${var.region}"
  size               = "${var.size}"
  backups            = "${var.backups}"
  ipv6               = "${var.ipv6}"
  monitoring         = "${var.monitoring}"
  resize_disk        = "${var.resize_disk}"
  private_networking = "${var.private_networking}"
  ssh_keys   = ["${var.ssh_ids}"]
  volume_ids = ["${var.volume_ids}"]
  tags       = ["${var.tag_ids}"]

  connection {
    type        = "ssh"
    host        = "${self.ipv4_address}"
    user        = "root"
    private_key = "${file(var.ssh_pri_file)}"
  }

  provisioner "remote-exec" {
    inline = [
      "data.template_file.newuser.rendered",
      "data.template_file.docker-install.rendered",
    ]
  }
}

# connect after droplet provisioned to deposit certs in non-root admin acct
resource "null_resource" "certs" {

  count = "${var.count}"

  connection {
    type        = "ssh"
    host        = "${element(digitalocean_droplet.captain.*.ipv4_address, count.index)}"
    user        = "${var.user}"
    private_key = "${file(var.ssh_pri_file)}"
  }

  provisioner "file" {
    source      = "${path.root}/certs"
    destination = "/home/${var.user}/certs"
  }
}
