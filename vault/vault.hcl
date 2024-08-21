seal "awskms" {
  region     = "ap-southeast-2"
  kms_key_id = "alias/vault"
  endpoint   = "http://10.10.10.123:8080"
}

storage "raft" {
  path    = "raft/"
  node_id = "vault_1"
  raft_wal = true
}

service_registration "consul" {
  scheme  = "http"
  service = "vault-service"
}

listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "{{GetPrivateIP}}:8201"
  tls_disable     = true

  telemetry {
    unauthenticated_metrics_access = true
  }
  profiling {
    unauthenticated_pprof_access = true
  }
}

telemetry {
  prometheus_retention_time = "30s"
  disable_hostname          = true
}

disable_mlock        = true
default_lease_ttl    = "1h"
max_lease_ttl        = "12h"
ui                   = true
raw_storage_endpoint = true
api_addr             = "http://{{GetPrivateIP}}:8200"
cluster_addr         = "https://{{GetPrivateIP}}:8201"
