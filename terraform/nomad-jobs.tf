terraform {
  backend "consul" {
    path = "test/terraform_state"
  }
}

resource "vault_policy" "fabio" {
  name = "fabio"

  policy = file("${path.module}/fabio.hcl")
}

resource "nomad_job" "fabio" {
  jobspec = file("${path.module}/fabio.nomad")

  depends_on = [
    consul_acl_token_policy_attachment.attachment,
    consul_keys.fabio_config,
    vault_pki_secret_backend_role.consul,
    vault_policy.fabio
  ]
}

resource "nomad_job" "https" {
  jobspec = file("${path.module}/https-echo.nomad")
}

resource "nomad_job" "count" {
  jobspec = file("${path.module}/counting.nomad")
}

resource "nomad_job" "doh" {
  jobspec = file("${path.module}/doh-server.nomad")
}

resource "nomad_job" "grafana" {
  jobspec = file("${path.module}/grafana.nomad")
}

resource "consul_keys" "fabio_config" {
  key {
    path  = "fabio/config"
    value = file("${path.module}/fabio-config.txt")
  }
}

resource "consul_acl_policy" "anonymous" {
  name  = "anonymous"
  rules = file("${path.module}/anonymous_acl.hcl")
}

resource "consul_acl_token_policy_attachment" "attachment" {
  token_id = "00000000-0000-0000-0000-000000000002"
  policy   = consul_acl_policy.anonymous.name
}
