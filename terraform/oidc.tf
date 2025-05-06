resource "vault_identity_entity" "current_user" {
  name = data.external.local_info.result.currentuser
}

resource "vault_identity_entity_alias" "github_user" {
  name = "tristanmorgan"

  mount_accessor = vault_github_auth_backend.github.accessor
  canonical_id   = vault_identity_entity.current_user.id
}

resource "vault_identity_entity_alias" "user_pass" {
  name = data.external.local_info.result.currentuser

  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.current_user.id
}

resource "vault_identity_group" "engineering" {
  name = "engineering"
  type = "internal"

  member_entity_ids = [vault_identity_entity.current_user.id]
}

resource "vault_identity_oidc_assignment" "default" {
  name = "default"
  entity_ids = [
    vault_identity_entity.current_user.id,
  ]
  group_ids = [
    vault_identity_group.engineering.id
  ]
}

resource "vault_identity_oidc_key" "key" {
  name               = "key"
  algorithm          = "RS256"
  allowed_client_ids = ["*"]
  verification_ttl   = 7200
  rotation_period    = 3600
}

resource "vault_identity_oidc_client" "nomad" {
  name = "nomad"
  key  = vault_identity_oidc_key.key.id
  redirect_uris = [
    "http://localhost:4649/oidc/callback",
    "https://${data.consul_service.nomad.service[0].address}:${data.consul_service.nomad.service[0].port}/ui/settings/tokens",
    "https://nomad.service.consul/ui/settings/tokens",
  ]
  assignments = [
    vault_identity_oidc_assignment.default.name
  ]
  id_token_ttl     = 1800
  access_token_ttl = 3600
}

resource "vault_identity_oidc_scope" "user" {
  name        = "user"
  template    = "{\"username\": {{identity.entity.name}}}"
  description = "The user scope provides claims using Vault identity entity metadata"
}

resource "vault_identity_oidc_scope" "groups" {
  name        = "groups"
  template    = "{\"groups\":{{identity.entity.groups.names}}}"
  description = "The groups scope provides the groups claim using Vault group membership"
}

resource "vault_identity_oidc_provider" "default" {
  name          = "default"
  https_enabled = false
  issuer_host   = "${data.consul_service.vault.service[0].address}:${data.consul_service.vault.service[0].port}"
  allowed_client_ids = [
    vault_identity_oidc_client.nomad.client_id,
  ]
  scopes_supported = [
    vault_identity_oidc_scope.groups.name,
  ]
}

resource "nomad_acl_role" "needed" {
  for_each    = nomad_acl_policy.needed
  name        = each.value["name"]
  description = "An ACL Role for ${each.value["name"]}"

  policy {
    name = each.value["name"]
  }
}

resource "nomad_acl_auth_method" "vault" {
  name              = "vault"
  type              = "OIDC"
  token_locality    = "global"
  max_token_ttl     = "1h0m0s"
  token_name_format = "$${auth_method_type}-$${auth_method_name}"
  default           = true

  config {
    oidc_discovery_url    = vault_identity_oidc_provider.default.issuer
    oidc_client_id        = vault_identity_oidc_client.nomad.client_id
    oidc_client_secret    = vault_identity_oidc_client.nomad.client_secret
    oidc_scopes           = [vault_identity_oidc_scope.groups.name]
    bound_audiences       = [vault_identity_oidc_client.nomad.client_id]
    allowed_redirect_uris = vault_identity_oidc_client.nomad.redirect_uris
    claim_mappings = {
      "preferred_username" = "username",
    }
    list_claim_mappings = {
      "groups" : "roles"
    }
  }
}

resource "nomad_acl_binding_rule" "needed" {
  for_each    = nomad_acl_policy.needed
  description = "${each.value["name"]} binding rule"
  auth_method = nomad_acl_auth_method.vault.name
  selector    = "${each.value["name"]} in list.roles"
  bind_type   = "role"
  bind_name   = each.value["name"]
}
