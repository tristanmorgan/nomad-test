resource "vault_mount" "nomad" {
  path        = "nomad"
  type        = "nomad"
  description = "Nomad Token backend"
}

resource "vault_generic_secret" "nomad_config" {
  path = "${vault_mount.nomad.path}/config/access"

  data_json = <<EOT
{
  "address": "http://${data.external.local_info.result.ipaddress}:4646",
  "token": "${data.external.local_info.result.nomadtoken}"
}
EOT

  disable_read = true
}

resource "nomad_acl_policy" "anonymous" {
  name        = "anonymous"
  description = "Anonymous policy (read-access)"
  rules_hcl   = file("${path.module}/anon-nomad.hcl")
}

resource "vault_policy" "needed" {
  for_each = fileset(path.module, "vpol/*.hcl")
  name     = regex("vpol/([-[:alnum:]]+).hcl", each.value)[0]

  policy = file(each.value)
}

resource "nomad_job" "everything" {
  for_each = fileset(path.module, "jobs/*.nomad")
  jobspec  = file(each.value)

  hcl2 {
    enabled = true
  }

  depends_on = [
    consul_acl_token_policy_attachment.attachment,
    consul_keys.fabio_config,
    vault_pki_secret_backend_role.consul,
    vault_policy.needed
  ]
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
  role_name              = "nomad-server"
  allowed_policies       = [vault_policy.nomad_server.name]
  orphan                 = true
  token_period           = "7200"
  renewable              = true
  token_explicit_max_ttl = "0"
}

resource "vault_policy" "nomad_server" {
  name   = "nomad-server"
  policy = data.http.nomad_server_policy.body
}

resource "vault_token_auth_backend_role" "nomad_cluster" {
  role_name              = "nomad-cluster"
  disallowed_policies    = [vault_policy.nomad_server.name]
  orphan                 = true
  token_period           = "3600"
  renewable              = true
  token_explicit_max_ttl = "0"
}
