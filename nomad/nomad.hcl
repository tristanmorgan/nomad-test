datacenter = "system-internal"

disable_update_check = true

consul {
  token   = "ab1469ec-078c-42cf-bb7b-6ef2a52360ea"
  auto_advertise = true
}


client {
  enabled = true
  options = {
    "driver.blacklist" = "java"
  }
}

server {
  enabled          = true
  bootstrap_expect = 1
}

vault {
  enabled = true
  tls_skip_verify = true
  token = "s.RCD6ZraZfw69az8B9Reiwf5P"
  address = "http://10.10.10.133:8200"
}
