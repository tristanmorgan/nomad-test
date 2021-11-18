service {
  name = "vault"
  token = "ab1469ec-078c-42cf-bb7b-6ef2a52360ea"
  id   = "vault"
  tags = ["urlprefix-vault.service.consul/","active"]
  port = 8200

  checks = [
    {
      id            = "upstream"
      alias_service = "vault-service:10.10.10.36:8200"
    },
    {
      id       = "service"
      http     = "http://127.0.0.1:8200/v1/sys/health"
      method   = "GET"
      interval = "10s"
      timeout  = "2s"
    }
  ]
}

