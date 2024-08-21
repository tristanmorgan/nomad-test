resource "consul_acl_auth_method" "nomad" {
  name         = "nomad-workloads"
  display_name = "nomad-workloads"
  type         = "jwt"
  description  = "JWT auth method for Nomad services and workloads"

  config_json = jsonencode({
    JWKSURL          = "http://${data.consul_service.nomad.service[0].address}:${data.consul_service.nomad.service[0].port}/.well-known/jwks.json",
    JWTSupportedAlgs = ["RS256"],
    BoundAudiences   = ["consul.io"],
    ClaimMappings = {
      nomad_namespace = "nomad_namespace",
      nomad_job_id    = "nomad_job_id",
      nomad_task      = "nomad_task",
      nomad_service   = "nomad_service"
    }
  })
}

resource "consul_acl_binding_rule" "nomad_service" {
  auth_method = consul_acl_auth_method.nomad.name
  description = "Binding rule for Nomad Services"
  selector    = "\"nomad_service\" in value"
  bind_type   = "service"
  bind_name   = "$${value.nomad_service}"
}

resource "consul_acl_binding_rule" "nomad_task" {
  auth_method = consul_acl_auth_method.nomad.name
  description = "Binding rule for Nomad tasks"
  selector    = "\"nomad_task\" in value"
  bind_type   = "role"
  bind_name   = "$${value.nomad_task}"
}

resource "consul_acl_binding_rule" "terminating" {
  auth_method = consul_acl_auth_method.nomad.name
  description = "Binding rule for terminating gateway"
  selector    = "value.nomad_service == terminating"
  bind_type   = "role"
  bind_name   = "terminating"
}

resource "vault_jwt_auth_backend" "nomad" {
  path        = "jwt-nomad"
  type        = "jwt"
  description = "Authenticate Nomad jobs using JWT"

  jwks_url           = "http://${data.consul_service.nomad.service[0].address}:${data.consul_service.nomad.service[0].port}/.well-known/jwks.json"
  jwt_supported_algs = ["RS256", "EdDSA"]
}

resource "vault_policy" "needed" {
  for_each = fileset("${path.module}/vpol", "*.hcl")
  name     = trimsuffix(each.value, ".hcl")

  policy = file("vpol/${each.value}")

  depends_on = [
    vault_nomad_secret_role.needed,
  ]
}

output "vault_policies" {
  description = "List of Vault Policies loaded."
  value       = values(vault_policy.needed)[*].name
}

resource "vault_jwt_auth_backend_role" "everything" {
  for_each  = fileset("${path.module}/vpol", "*.hcl")
  backend   = vault_jwt_auth_backend.nomad.path
  role_name = trimsuffix(each.value, ".hcl")
  role_type = "jwt"

  token_type     = "service"
  token_policies = [trimsuffix(each.value, ".hcl")]
  token_period   = 1800

  bound_audiences = ["vault.io"]
  bound_claims = {
    nomad_task = trimsuffix(each.value, ".hcl")
  }
  user_claim              = "/nomad_job_id"
  user_claim_json_pointer = true

  claim_mappings = {
    nomad_namespace = "nomad_namespace",
    nomad_job_id    = "nomad_job_id",
    nomad_group     = "nomad_group"
    nomad_task      = "nomad_task"
  }
}
