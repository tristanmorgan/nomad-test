#GitHub authentication backend

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
  policies = ["admin"]
}

resource "vault_identity_group_alias" "vibrato_engineers" {
  name           = "vibrato-engineers"
  mount_accessor = vault_github_auth_backend.github.accessor
  canonical_id   = vault_identity_group.vibrato_engineers.id
}
