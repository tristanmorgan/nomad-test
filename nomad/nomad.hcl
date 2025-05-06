name                 = "introversion"
datacenter           = "system-internal"
region               = "global"
disable_update_check = true

leave_on_interrupt = true
leave_on_terminate = true

bind_addr = "{{GetPrivateIP}}"

addresses {
  http = "{{GetPrivateIP}} 127.0.0.1"
}

acl {
  enabled = true
}

keyring "awskms" {
  active = true

  # fields specific to awskms
  region     = "ap-southeast-2"
  kms_key_id = "alias/vault"
  endpoint   = "http://kms.service.home.consul"
}

consul {
  tags = ["urlprefix-nomad.service.consul/ proto=tcp"]

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
    "fingerprint.denylist" = "env_aws,env_gce,env_azure,landlock,plugins_cni"
  }
}

server {
  enabled              = true
  bootstrap_expect     = 1
  authoritative_region = "global"
}

tls {
  http = true
  rpc  = true

  ca_file   = "./tls/ca_cert.pem"
  cert_file = "./tls/global-server-nomad.pem"
  key_file  = "./tls/global-server-nomad-key.pem"
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
