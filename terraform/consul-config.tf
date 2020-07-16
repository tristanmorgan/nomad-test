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
  rules = file("${path.module}/anonymous_acl.hcl")
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
