storage_destination "raft" {
  path = "raft/"
  node_id = "vault_1"
}

storage_source "consul" {
  address = "127.0.0.1:8500"
  path = "vault/"
  scheme = "http"
  token = "ab1469ec-078c-42cf-bb7b-6ef2a52360ea"
  service_tags = "urlprefix-vault.service.consul/"
}

cluster_addr = "https://10.10.10.133:8201"
