services {
  name = "consul-api"
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
