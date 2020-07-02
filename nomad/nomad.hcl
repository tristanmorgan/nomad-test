datacenter = "system-internal"

disable_update_check = true

consul {
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
}
