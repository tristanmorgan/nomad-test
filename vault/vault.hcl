storage "raft" {
  path = "raft/"
  node_id = "vault_1"
}

service_registration "consul" {
  address = "127.0.0.1:8500"
  scheme = "http"
  token = "ab1469ec-078c-42cf-bb7b-6ef2a52360ea"
  service_tags = "urlprefix-vault.service.consul/"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = true

  telemetry {
    unauthenticated_metrics_access = true
  }
}

telemetry {
  prometheus_retention_time = "30s",
  disable_hostname = true
  statsd_address = "10.10.10.133:9125"
}

ui = true
raw_storage_endpoint = true
