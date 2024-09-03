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
  scheduler_algorithm             = "spread"
  memory_oversubscription_enabled = true
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
    vars = {}
  }

  depends_on = [
    vault_pki_secret_backend_role.consul,
    vault_nomad_secret_backend.nomad,
  ]
}

output "nomad_jobs" {
  description = "List of Nomad Jobs loaded."
  value       = keys(nomad_job.everything)
}

resource "consul_keys" "fabio_config" {
  key {
    path  = "fabio/config"
    value = file("${path.module}/fabio_config.tpl")
  }

  key {
    path  = "fabio/noroute.html"
    value = file("${path.module}/noroute.html")
  }
}

resource "nomad_variable" "secret" {
  path = "nomad/jobs/minio/server"
  items = {
    root_user     = data.environment_sensitive_variable.access_key.value
    root_password = data.environment_sensitive_variable.secret_key.value
  }
}
