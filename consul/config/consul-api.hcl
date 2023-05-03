services {
  name  = "consul-api"
  token = "ab1469ec-078c-42cf-bb7b-6ef2a52360ea"
  tags = [
    "urlprefix-consul.service.consul/",
  ]
  port = 8500
  checks = [
    {
      http     = "http://127.0.0.1:8500/v1/health/checks/consul"
      interval = "60s"
      notes    = "This is mostly for Fabio to see Consul."
    }
  ]
  meta = {
    external-source = "consul"
  }
}
