# advertise_addr_wan = 10.10.10.10
acl {
  enabled                  = true
  default_policy           = "deny"
  down_policy              = "extend-cache"
  enable_token_persistence = true
  enable_token_replication = true
}
addresses {
  dns      = "127.0.0.1 {{GetPrivateIP}}"
  http     = "127.0.0.1 {{GetPrivateIP}}"
  https    = "127.0.0.1 {{GetPrivateIP}}"
  grpc     = "127.0.0.1 {{GetPrivateIP}}"
  grpc_tls = "127.0.0.1 {{GetPrivateIP}}"
}
auto_reload_config         = true
primary_datacenter         = "system-internal"
bind_addr                  = "{{GetPrivateIP}}"
data_dir                   = "./data"
datacenter                 = "system-internal"
disable_host_node_id       = false
disable_update_check       = true
enable_local_script_checks = true
leave_on_terminate         = true
log_level                  = "INFO"
node_name                  = "introversion"
node_meta {
  external-source = "consul"
}
peering {
  enabled = true
}
ports = {
  http     = 8500
  https    = 8501
  grpc     = 8502
  grpc_tls = 8503
  dns      = 8600
}
protocol      = 3
raft_protocol = 3
raft_logstore {
  backend = "wal"
}
recursors = [
  "{{GetPrivateIP}}",
]
rejoin_after_leave = false
server             = true
server_name        = "consul.service.consul"
telemetry = {
  disable_hostname          = true
  prometheus_retention_time = "300s"
  metrics_prefix            = "consul"
}
ui_config {
  enabled          = true
  metrics_provider = "prometheus"
  metrics_proxy {
    base_url = "https://prom.service.consul/"
    add_headers = {
      name  = "Host"
      value = "prom.service.consul"
    }
  }
}
connect {
  enabled = true
}
