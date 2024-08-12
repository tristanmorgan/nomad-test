data "consul_agent_config" "self" {}

data "vault_policy_document" "consul_ca" {
  rule {
    path         = "auth/token/lookup-self"
    capabilities = ["read"]
  }

  rule {
    path         = "auth/token/renew-self"
    capabilities = ["update"]
  }

  rule {
    path         = "sys/leases/renew"
    capabilities = ["update"]
  }

  rule {
    path         = "consulca/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    description  = "Manage Consul CA"
  }

  rule {
    path         = "rootca/ca/pem"
    capabilities = ["read"]
    description  = "read public root pem"
  }

  rule {
    path         = "rootca/root/sign-intermediate"
    capabilities = ["update"]
    description  = "sign intermediate CA"
  }

  rule {
    path         = "rootca/root/sign-self-issued"
    capabilities = ["update", "sudo"]
    description  = "sign intermediate CA"
  }

  rule {
    path         = "sys/mounts"
    capabilities = ["read", "list"]
  }

  rule {
    path         = "sys/mounts/consulca*"
    capabilities = ["update", "read", "delete"]
  }
}

resource "vault_policy" "consul_ca" {
  name   = "consul-ca"
  policy = data.vault_policy_document.consul_ca.hcl
}

resource "vault_token_auth_backend_role" "consul_ca" {
  role_name               = "consul-ca"
  allowed_policies        = [vault_policy.consul_ca.name]
  orphan                  = true
  token_period            = "3600"
  renewable               = true
  token_explicit_max_ttl  = "0"
  token_no_default_policy = true
}

resource "consul_certificate_authority" "connect" {
  connect_provider = "vault"

  config_json = jsonencode({
    IntermediateCertTTL      = "72h0m0s"
    Address                  = "http://${data.external.local_info.result.ipaddress}:8200"
    Token                    = sensitive(data.external.local_info.result.vaulttoken)
    RootPkiPath              = vault_mount.rootca.path
    LeafCertTTL              = "1h0m0s"
    IntermediatePkiPath      = "consulca"
    ForceWithoutCrossSigning = true
    PrivateKeyBits           = vault_pki_secret_backend_root_cert.rootca.key_bits
    PrivateKeyType           = vault_pki_secret_backend_root_cert.rootca.key_type
  })

  depends_on = [
    vault_pki_secret_backend_config_urls.intca,
    vault_pki_secret_backend_root_cert.rootca,
  ]
}

resource "consul_acl_token" "agent" {
  description = "Consul Agent Token"
  local       = true

  policies = [consul_acl_policy.everything["agent.hcl"].name]
}

data "consul_acl_token_secret_id" "agent" {
  accessor_id = consul_acl_token.agent.id
}

resource "terraform_data" "consul_agent" {
  input = consul_acl_token.agent.accessor_id

  triggers_replace = [
    data.consul_acl_token_secret_id.agent.secret_id
  ]

  provisioner "local-exec" {
    command = "consul acl set-agent-token agent ${data.consul_acl_token_secret_id.agent.secret_id}"
  }
}

resource "consul_acl_token" "dns" {
  description = "Consul DNS Token"
  local       = true
  templated_policies {
    template_name = "builtin/dns"
  }
}

data "consul_acl_token_secret_id" "dns" {
  accessor_id = consul_acl_token.dns.id
}

resource "terraform_data" "consul_dns" {
  input = consul_acl_token.dns.accessor_id

  triggers_replace = [
    data.consul_acl_token_secret_id.dns.secret_id
  ]

  provisioner "local-exec" {
    command = "consul acl set-agent-token dns ${data.consul_acl_token_secret_id.dns.secret_id}"
  }
}

resource "consul_acl_token_policy_attachment" "anonymous" {
  token_id = "00000000-0000-0000-0000-000000000002"
  policy   = consul_acl_policy.everything["anonymous.hcl"].name
}

resource "consul_acl_policy" "everything" {
  for_each    = fileset("${path.module}/cpol", "*.hcl")
  name        = trimsuffix(each.value, ".hcl")
  datacenters = [data.consul_agent_config.self.datacenter]
  rules       = file("cpol/${each.value}")
}

resource "consul_acl_role" "everything" {
  for_each = fileset("${path.module}/cpol", "*.hcl")
  name     = trimsuffix(each.value, ".hcl")

  policies = [
    consul_acl_policy.everything[each.value].id
  ]
}

output "consul_policies" {
  description = "List of Consul Policies loaded."
  value       = values(consul_acl_policy.everything)[*].name
}

resource "consul_config_entry" "uuid" {
  name = "uuid-api"
  kind = "service-intentions"

  config_json = jsonencode({
    Sources = [{
      Action     = "allow"
      Name       = "uuid-fe"
      Precedence = 9
      Type       = "consul"
    }]
  })
}

resource "consul_prepared_query" "service_near_self" {
  connect      = false
  name         = ""
  near         = "_agent"
  only_passing = true
  service      = "$${match(1)}"

  dns {
    ttl = "1m"
  }

  failover {
    nearest_n = 2
  }

  template {
    regexp = "^(.*)$"
    type   = "name_prefix_match"
  }
}
