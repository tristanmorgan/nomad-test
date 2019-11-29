backend "consul" {
  address = "127.0.0.1:8500"
  path = "vault/"
  scheme = "http"
  token = "ab1469ec-078c-42cf-bb7b-6ef2a52360ea"
  service_tags = "urlprefix-:9997 proto=tcp"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = true
}

ui = true
raw_storage_endpoint = true
