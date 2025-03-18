name                 = "hashicarp"
datacenter           = "system-internal"
region               = "global"
disable_update_check = true

leave_on_interrupt = true
leave_on_terminate = true

bind_addr = "{{GetPrivateIP}}"

acl {
  enabled = true
}

consul {
  tags = ["urlprefix-nomad.service.consul/"]

  service_identity {
    aud = ["consul.io"]
    ttl = "1h"
  }
  task_identity {
    aud = ["consul.io"]
    ttl = "1h"
  }
}

client {
  enabled    = true
  node_class = "client"
  host_volume "build-output" {
    path      = "/private/tmp/"
    read_only = false
  }
  meta {
    node_type = "server"
  }
  # cpu_total_compute = 10404
  options = {
    "fingerprint.denylist" = "env_aws,env_gce,env_azure"
  }
}

server {
  enabled              = true
  bootstrap_expect     = 1
  authoritative_region = "global"
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}

vault {
  enabled         = true
  tls_skip_verify = true

  default_identity {
    aud = ["vault.io"]
    ttl = "1h"
  }
}

telemetry {
  disable_hostname           = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
  prometheus_metrics         = true
}

ui {
  enabled = true

  consul {
    ui_url = "https://consul.service.consul/ui"
  }

  vault {
    ui_url = "https://vault.service.consul/ui"
  }
}
