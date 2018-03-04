master {
  name  = "master"
  image = "centos-7-x64"
  size  = "4GB"
  qty   = 1
}

worker {
  name  = "worker"
  image = "centos-7-x64"
  size  = "8GB"
  qty   = 2
}

user = "user"

region = "sfo2"

# change this
domain = "domain.tld"

# change this
ssh_ids = ["ssh-id"]

# change this
tag_name = "tag"

storage_driver = "overlay"

ipv6 = false

monitoring = false

backups = false

resize_disk = false

private_networking = false

# change this
db-host = "db.ip.addr.ess"

# change this
db-port = "db_port"

# change this
db-name = "db_name"

# change this
db-user = "db_user"

# change this
db-pass = "db_password"
