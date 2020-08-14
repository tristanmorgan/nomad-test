resource "vault_consul_secret_backend" "consul" {
  path        = "consul"
  description = "Access Consul tokens"

  address                   = "${data.external.local_info.result.ipaddress}:8500"
  scheme                    = "http"
  token                     = data.external.local_info.result.consultoken
  default_lease_ttl_seconds = "36000"
  max_lease_ttl_seconds     = "2764800"
}

resource "consul_acl_policy" "anonymous" {
  name  = "anonymous"
  rules = <<-RULE
key_prefix "_rexec/" {
  policy = "deny"
}
key_prefix "vault/" {
  policy = "deny"
}
service_prefix "" {
  policy = "read"
}
node_prefix "" {
  policy = "read"
}
agent_prefix "" {
  policy = "read"
}
RULE
}

resource "consul_acl_token_policy_attachment" "attachment" {
  token_id = "00000000-0000-0000-0000-000000000002"
  policy   = consul_acl_policy.anonymous.name
}

resource "consul_acl_policy" "fabio" {
  name        = "fabio"
  datacenters = ["system-internal"]
  rules       = <<-RULE
key_prefix "_rexec/" {
  policy = "deny"
}
key_prefix "vault/" {
  policy = "deny"
}
key_prefix "fabio" {
  policy = "read"
}
service_prefix "" {
  policy = "write"
}
node_prefix "" {
  policy = "read"
}
agent_prefix "" {
  policy = "read"
}
    RULE
}

resource "vault_consul_secret_backend_role" "fabio" {
  name    = "fabio"
  backend = vault_consul_secret_backend.consul.path

  policies = [
    "fabio",
  ]
}

resource "consul_acl_policy" "prom" {
  name        = "prom"
  datacenters = ["system-internal"]
  rules       = <<-RULE
agent_prefix "" {
  policy = "read"
}
    RULE
}

resource "vault_consul_secret_backend_role" "prom" {
  name    = "prom"
  backend = vault_consul_secret_backend.consul.path

  policies = [
    "prom",
  ]
}

resource "consul_acl_policy" "uuid" {
  name        = "uuid"
  datacenters = ["system-internal"]
  rules       = <<-RULE
service_prefix "" {
  policy = "write"
}
node_prefix "" {
  policy = "read"
}
agent_prefix "" {
  policy = "read"
}
    RULE
}

resource "vault_consul_secret_backend_role" "uuid" {
  name    = "uuid"
  backend = vault_consul_secret_backend.consul.path

  policies = [
    "uuid",
  ]
}

resource "consul_intention" "uuid" {
  source_name      = "uuid-fe"
  destination_name = "uuid-api"
  action           = "allow"
  description      = "Native Connect service."
}
