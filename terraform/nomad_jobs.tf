resource "nomad_acl_token" "vault" {
  name = "Vault-management-token"
  type = "management"
}

resource "vault_nomad_secret_backend" "nomad" {
  backend                   = "nomad"
  description               = "Nomad Token backend"
  default_lease_ttl_seconds = "3600"
  max_lease_ttl_seconds     = "7200"
  max_ttl                   = "3600"
  address                   = "http://${data.consul_service.nomad.service[0].address}:${data.consul_service.nomad.service[0].port}"
  token                     = nomad_acl_token.vault.secret_id
  ttl                       = "600"
}

resource "nomad_scheduler_config" "config" {
  scheduler_algorithm = "spread"
  preemption_config = {
    system_scheduler_enabled   = true
    batch_scheduler_enabled    = false
    service_scheduler_enabled  = true
    sysbatch_scheduler_enabled = false
  }
}

resource "nomad_acl_policy" "needed" {
  for_each = fileset("${path.module}/npol", "*.hcl")
  name     = trimsuffix(each.value, ".hcl")

  description = "${trimsuffix(each.value, ".hcl")} policy"
  rules_hcl   = file("npol/${each.value}")
}

output "nomad_policies" {
  description = "List of Nomad Policies loaded."
  value       = values(nomad_acl_policy.needed)[*].name
}

resource "vault_nomad_secret_role" "needed" {
  backend = vault_nomad_secret_backend.nomad.backend

  for_each = nomad_acl_policy.needed
  role     = each.value["name"]
  type     = "client"
  policies = [each.value["name"]]
}

resource "vault_nomad_secret_role" "management" {
  backend = vault_nomad_secret_backend.nomad.backend

  role = "management"
  type = "management"
}

resource "vault_policy" "needed" {
  for_each = fileset("${path.module}/vpol", "*.hcl")
  name     = trimsuffix(each.value, ".hcl")

  policy = file("vpol/${each.value}")

  depends_on = [
    vault_nomad_secret_role.needed,
    vault_consul_secret_backend_role.everything,
  ]
}

output "vault_policies" {
  description = "List of Vault Policies loaded."
  value       = values(vault_policy.needed)[*].name
}

variable "no_deploy" {
  description = "set to true to disable deployments"
  default     = false
  type        = bool
}

resource "nomad_job" "everything" {
  for_each = var.no_deploy ? toset([]) : fileset("${path.module}/jobs", "*.nomad")
  jobspec  = file("jobs/${each.value}")
  detach   = false

  hcl2 {
    enabled = true
    vars    = {}
  }

  depends_on = [
    vault_pki_secret_backend_role.consul,
    vault_consul_secret_backend.consul,
    vault_nomad_secret_backend.nomad,
    vault_token_auth_backend_role.nomad_cluster
  ]
}

output "nomad_jobs" {
  description = "List of Nomad Jobs loaded."
  value       = keys(nomad_job.everything)
}

resource "consul_keys" "fabio_config" {
  key {
    path = "fabio/config"
    value = templatefile("${path.module}/fabio_config.tpl",
      {
        ipaddress = data.external.local_info.result.ipaddress
      }
    )
  }
}

resource "consul_keys" "fabio_noroute" {
  key {
    path  = "fabio/noroute.html"
    value = file("${path.module}/noroute.html")
  }
}

resource "vault_token_auth_backend_role" "nomad_server" {
  role_name               = "nomad-server"
  allowed_policies        = [vault_policy.nomad_server.name]
  orphan                  = true
  token_period            = "7200"
  renewable               = true
  token_explicit_max_ttl  = "0"
  token_no_default_policy = true
}

resource "vault_policy" "nomad_server" {
  name   = "nomad-server"
  policy = data.http.nomad_server_policy.response_body
}

resource "vault_token_auth_backend_role" "nomad_cluster" {
  role_name               = "nomad-cluster"
  allowed_policies        = values(vault_policy.needed)[*].name
  orphan                  = true
  token_period            = "3600"
  renewable               = true
  token_explicit_max_ttl  = "0"
  token_no_default_policy = true
}
