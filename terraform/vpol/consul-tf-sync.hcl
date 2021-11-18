# The following capabilities are typically provided by Vault's default policy.
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "sys/leases/renew" {
  capabilities = ["update"]
}

path "consul/creds/consul-tf-sync" {
  capabilities = ["read"]
}
