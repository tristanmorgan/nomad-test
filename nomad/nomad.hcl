data_dir = "/Users/tristan/Vibrato/apps/nomad-test/nomad/data"

datacenter = "system-internal"

consul {
  token   = "ab1469ec-078c-42cf-bb7b-6ef2a52360ea"
  auto_advertise = true
  tags = ["urlprefix-nomad.service.consul/"]
}


client {
  enabled = true
  options = {
    "driver.whitelist" = "docker,raw_exec"
  }
}

server {
  enabled          = true
  bootstrap_expect = 1
}

vault {
  enabled = false
  tls_skip_verify = true
  token = "s.g3ezS8iAnvoBnQ8RVdGWzMoc"
}
