datacenter = "system-internal"

disable_update_check = true

acl {
  enabled = true
}

consul {
  auto_advertise = true
}

client {
  enabled = true
  options = {
    "driver.blacklist" = "java"
  }
  host_volume "build-output" {
    path = "/Users/tristan/tmp"
    read_only = false
  }
}

server {
  enabled          = true
  bootstrap_expect = 1
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}

vault {
  enabled         = true
  tls_skip_verify = true
}

telemetry {
  statsd_address = "10.10.10.133:9125"
  publish_allocation_metrics = true
  publish_node_metrics       = true
}
