resource "vault_consul_secret_backend" "consul" {
  path        = "consul"
  description = "Access Consul tokens"

  address                   = "${data.external.local_info.result.ipaddress}:8500"
  scheme                    = "http"
  token                     = data.external.local_info.result.consultoken
  default_lease_ttl_seconds = "36000"
  max_lease_ttl_seconds     = "2764800"
}

resource "consul_certificate_authority" "connect" {
  connect_provider = "vault"

  config = {
    IntermediateCertTTL = "72h0m0s"
    Address             = "http://${data.external.local_info.result.ipaddress}:8200"
    Token               = data.external.local_info.result.vaulttoken
    RootPkiPath         = vault_mount.rootca.path
    LeafCertTTL         = "1h0m0s"
    IntermediatePkiPath = "consulca"
  }

  depends_on = [
    vault_pki_secret_backend_config_urls.intca,
    vault_pki_secret_backend_root_cert.rootca,
  ]
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

resource "consul_acl_policy" "everything" {
  for_each    = fileset(path.module, "cpol/*.hcl")
  name        = regex("cpol/([[:alnum:]]+).hcl", each.value)[0]
  datacenters = ["system-internal"]
  rules       = file(each.value)
}

resource "vault_consul_secret_backend_role" "everything" {
  for_each = fileset(path.module, "cpol/*.hcl")
  name     = regex("cpol/([[:alnum:]]+).hcl", each.value)[0]
  backend  = vault_consul_secret_backend.consul.path

  policies = [
    regex("cpol/([[:alnum:]]+).hcl", each.value)[0],
  ]
}

resource "consul_intention" "uuid" {
  source_name      = "uuid-fe"
  destination_name = "uuid-api"
  action           = "allow"
  description      = "Native Connect service."
}
