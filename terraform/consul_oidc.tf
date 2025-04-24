resource "vault_identity_oidc_client" "consul" {
  name = "consul"
  key  = vault_identity_oidc_key.key.id
  redirect_uris = [
    "http://localhost:8550/oidc/callback",
    "http://${data.consul_service.consul.service[0].address}:${data.consul_service.consul.service[0].port}/ui/oidc/callback",
    "https://consul.service.consul/ui/oidc/callback",
  ]
  assignments = [
    vault_identity_oidc_assignment.default.name
  ]
  id_token_ttl     = 1800
  access_token_ttl = 3600
}

resource "consul_acl_auth_method" "vault" {
  name          = "vault"
  type          = "oidc"
  max_token_ttl = "1h0m0s"

  config_json = jsonencode({
    AllowedRedirectURIs = vault_identity_oidc_client.consul.redirect_uris
    BoundAudiences      = [vault_identity_oidc_client.consul.client_id]
    ClaimMappings = {
      "preferred_username" = "username",
    }
    ListClaimMappings = {
      "groups" = "roles"
    }
    OIDCClientID     = vault_identity_oidc_client.consul.client_id
    OIDCClientSecret = vault_identity_oidc_client.consul.client_secret
    OIDCDiscoveryURL = vault_identity_oidc_provider.default.issuer
  })
}

resource "consul_acl_binding_rule" "vault" {
  auth_method = consul_acl_auth_method.vault.name
  description = "Binding rule for humans"
  selector    = "engineering in list.roles"
  bind_type   = "role"
  bind_name   = "Humans"
}
