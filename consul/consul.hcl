# advertise_addr_wan = 10.10.10.10
acl {
  enabled        = true
  default_policy = "deny"
  down_policy    = "extend-cache"
  tokens {
    agent  = "ab1469ec-078c-42cf-bb7b-6ef2a52360ea"
    master = "ab1469ec-078c-42cf-bb7b-6ef2a52360ea"
  }
}
addresses {
  dns  = "127.0.0.1 {{GetPrivateIP}}"
  http = "127.0.0.1 {{GetPrivateIP}}"
  grpc = "127.0.0.1 {{GetPrivateIP}}"
}
primary_datacenter   = "system-internal"
bind_addr            = "{{GetPrivateIP}}"
data_dir             = "./data"
datacenter           = "system-internal"
disable_host_node_id = false
disable_update_check = true
encrypt              = "GkSMCC4pHEKGEiQ/eMN0k7c3tfMa4u/5fiwOFeS3Qcc="
leave_on_terminate   = true
log_level            = "INFO"
node_name            = "introversion"
ports = {
  http  = 8500
  https = -1
  grpc  = 8502
  dns   = 8600
}
protocol      = 3
raft_protocol = 3
recursors = [
  "{{GetPrivateIP}}",
]
rejoin_after_leave = false
server_name        = "consul.service.consul"
telemetry = {
  disable_compat_1.9        = true
  prometheus_retention_time = "300s"
  statsd_address            = "{{GetPrivateIP}:9125"
}
ui_config {
  enabled = true
}
connect {
  enabled = true
}
enable_central_service_config = true

