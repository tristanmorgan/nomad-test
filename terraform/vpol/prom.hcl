# The following capabilities are typically provided by Vault's default policy.
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "consul/creds/prom" {
  capabilities = ["read"]
}
