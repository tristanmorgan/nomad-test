datacenter = "system-internal"

disable_update_check = true

acl {
  enabled = true
}

consul {
  auto_advertise = true
  tags = ["urlprefix-nomad.service.consul/"]
}

client {
  enabled = true
  host_volume "build-output" {
    path      = "/private/tmp/"
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
  enabled          = true
  tls_skip_verify  = true
  create_from_role = "nomad-cluster"
}

telemetry {
  statsd_address             = "10.10.10.133:9125"
  publish_allocation_metrics = true
  publish_node_metrics       = true
}
