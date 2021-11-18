#GitHub authentication backend
data "vault_policy_document" "admin" {
  rule {
    path         = "*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  rule {
    path         = "sys/leases/lookup/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  rule {
    path         = "sys/leases/lookup"
    capabilities = ["read", "list", "sudo"]
  }
}

resource "vault_policy" "admin" {
  name   = "admin"
  policy = data.vault_policy_document.admin.hcl
}

resource "vault_github_auth_backend" "github" {
  path           = "github"
  organization   = "vibrato"
  description    = "Authenticate using GitHub"
  token_policies = ["default"]

  tune {
    default_lease_ttl = "1h"
    max_lease_ttl     = "2h"
    token_type        = "default-service"
  }
}

resource "vault_identity_group" "vibrato_engineers" {
  name     = "vibrato-engineers"
  type     = "external"
  policies = [vault_policy.admin.name]
}

resource "vault_identity_group_alias" "vibrato_engineers" {
  name           = "vibrato-engineers"
  mount_accessor = vault_github_auth_backend.github.accessor
  canonical_id   = vault_identity_group.vibrato_engineers.id
}
