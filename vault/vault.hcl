backend "consul" {
  address = "127.0.0.1:8500"
  path = "vault/"
  scheme = "http"
  token = "ab1469ec-078c-42cf-bb7b-6ef2a52360ea"
  service_tags = "urlprefix-vault.service.consul/"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = true
}

telemetry {
  statsd_address = "10.10.10.133:9125"
}

ui = true
raw_storage_endpoint = true
