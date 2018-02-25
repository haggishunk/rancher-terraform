resource "digitalocean_tag" "pennant" {
  name = "${var.tag_name}"
}

resource "digitalocean_tag" "capn" {
  name = "capn"
}
