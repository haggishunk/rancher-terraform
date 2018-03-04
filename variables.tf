variable "region" {}
variable "domain" {}

variable "master" {
  type = "map"

  default = {
    name  = "captain"
    image = "centos-7-x64"
    size  = "4GB"
    qty   = "1"
  }
}

variable "worker" {
  type = "map"

  default = {
    name  = "fisherman"
    image = "centos-7-x64"
    size  = "8GB"
    qty   = "2"
  }
}

variable "ssh_ids" {
  type = "list"
}

variable "user" {}
variable "storage_driver" {}
variable "tag_name" {}
variable "ipv6" {}
variable "monitoring" {}
variable "backups" {}
variable "resize_disk" {}
variable "private_networking" {}

variable "db-host" {}
variable "db-port" {}
variable "db-name" {}
variable "db-user" {}
variable "db-pass" {}
