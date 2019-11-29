# advertise_addr_wan = 10.10.10.10
acl {
  enabled = true
  default_policy = "deny"
  down_policy = "extend-cache"
  tokens {
    agent = "ab1469ec-078c-42cf-bb7b-6ef2a52360ea"
    master = "ab1469ec-078c-42cf-bb7b-6ef2a52360ea"
  }
}

primary_datacenter = "system-internal"
client_addr = "{{GetPrivateIP}} 127.0.0.1 ::1"
bind_addr = "{{GetPrivateIP}}"
data_dir = "./data"
datacenter = "system-internal"
disable_host_node_id = true
disable_update_check = true
encrypt = "3a6nE3qvOSwaPVcg73nxLQ=="
leave_on_terminate = true
log_level = "INFO"
ports = {
  grpc  = 8502
  dns   = 8600
  https = -1
}
protocol = 3
raft_protocol = 3
recursors = [
  "8.8.8.8",
  "8.8.4.4",
]
rejoin_after_leave = false
server_name = "consul.service.consul"
ui = true
