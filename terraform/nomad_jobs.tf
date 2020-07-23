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

resource "vault_policy" "fabio" {
  name = "fabio"

  policy = file("${path.module}/fabio.hcl")
}

resource "vault_policy" "prom" {
  name = "prom"

  policy = file("${path.module}/prom.hcl")
}

resource "nomad_job" "everything" {
  for_each = fileset(path.module, "*.nomad")
  jobspec  = file(each.value)

  depends_on = [
    consul_acl_token_policy_attachment.attachment,
    consul_keys.fabio_config,
    vault_pki_secret_backend_role.consul,
    vault_policy.fabio
  ]
}

resource "consul_keys" "fabio_config" {
  key {
    path = "fabio/config"
    value = templatefile("${path.module}/fabio-config.txt",
      {
        ipaddress = data.external.local_info.result.ipaddress
      }
    )
  }
}
