terraform {
  backend "consul" {
    path = "test/terraform_state"
  }
}

resource "nomad_job" "fabio" {
  jobspec = file("${path.module}/fabio.nomad")

  depends_on = [consul_acl_token_policy_attachment.attachment, consul_keys.fabio_config]
}


resource "nomad_job" "count" {
  jobspec = file("${path.module}/counting.nomad")

  depends_on = [nomad_job.fabio]
}

resource "nomad_job" "doh" {
  jobspec = file("${path.module}/doh-server.nomad")

  depends_on = [nomad_job.fabio]
}

resource "nomad_job" "grafana" {
  jobspec = file("${path.module}/grafana.nomad")

  depends_on = [nomad_job.fabio]
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
