service {
  name = "vault"
  tags = ["urlprefix-vault.service.consul/", "active"]
  port = 8200

  checks = [
    {
      id            = "upstream"
      alias_service = "vault-service:10.10.10.200:8200"
    },
    {
      id       = "service"
      http     = "http://127.0.0.1:8200/v1/sys/health"
      method   = "GET"
      interval = "10s"
      timeout  = "2s"
    }
  ]
  meta = {
    external-source = "consul"
  }
}

