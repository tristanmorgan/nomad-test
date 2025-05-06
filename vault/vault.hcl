seal "awskms" {
  region     = "ap-southeast-2"
  kms_key_id = "alias/vault"
  endpoint   = "http://kms.service.home.consul"
}

storage "raft" {
  path    = "raft/"
  node_id = "vault_1"
  raft_wal = true
}

service_registration "consul" {
  address = "127.0.0.1:8501"
  scheme  = "https"
  service = "vault-service"
  tls_ca_file = "./tls/ca_cert.pem"
}

listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "{{GetPrivateIP}}:8201"
  # tls_disable     = true
  tls_disable_client_certs  = true
  tls_cert_file = "./tls/vault-system-internal-server.pem"
  tls_key_file  = "./tls/vault-system-internal-server-key.pem"

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
