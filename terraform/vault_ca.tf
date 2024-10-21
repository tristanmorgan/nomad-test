resource "vault_quota_rate_limit" "global" {
  name = "global"
  path = ""
  rate = 100
}

resource "vault_audit" "file" {
  type        = "file"
  description = "Audit logs to a file"

  options = {
    file_path = "vault.log"
    log_raw   = true
  }
}

resource "vault_mount" "rootca" {
  type        = "pki"
  path        = "rootca"
  description = "Host a Root CA"

  default_lease_ttl_seconds = 31536000
  max_lease_ttl_seconds     = 315360000
}

resource "vault_pki_secret_backend_config_urls" "rootca" {
  backend                 = vault_mount.rootca.path
  issuing_certificates    = ["http://vault.service.consul:8200/v1/rootca/ca"]
  crl_distribution_points = ["http://vault.service.consul:8200/v1/rootca/crl"]
}

resource "vault_pki_secret_backend_root_cert" "rootca" {
  depends_on = [vault_pki_secret_backend_config_urls.rootca]

  backend = vault_mount.rootca.path

  type                 = "internal"
  common_name          = "Tristan Root CA"
  ttl                  = "315360000"
  format               = "pem"
  private_key_format   = "der"
  key_type             = "ec"
  key_bits             = 521
  exclude_cn_from_sans = true
  ou                   = "Uplink Engineering"
  organization         = "Introversion Pty Ltd"

  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_mount" "intca" {
  type        = "pki"
  path        = "intca"
  description = "Host an Intermediate CA"

  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 31536000
}

resource "vault_pki_secret_backend_config_urls" "intca" {
  backend                 = vault_mount.intca.path
  issuing_certificates    = ["http://vault.service.consul:8200/v1/intca/ca"]
  crl_distribution_points = ["http://vault.service.consul:8200/v1/intca/crl"]
}

resource "time_rotating" "intca_rotation" {
  triggers = {
    mount_accessor = vault_mount.intca.accessor
  }
  rotation_days = 30
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intca" {
  backend = vault_mount.intca.path

  type         = "internal"
  common_name  = "Tristan Intermediate CA"
  key_type     = "ec"
  key_bits     = 256
  ou           = "Uplink Engineering"
  organization = "Introversion Pty Ltd"
  postal_code  = time_rotating.intca_rotation.unix

  depends_on = [
    vault_pki_secret_backend_config_urls.intca,
    vault_pki_secret_backend_root_cert.rootca,
  ]
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intca" {
  backend = vault_mount.rootca.path

  csr                  = vault_pki_secret_backend_intermediate_cert_request.intca.csr
  common_name          = vault_pki_secret_backend_intermediate_cert_request.intca.common_name
  exclude_cn_from_sans = true
  use_csr_values       = true
  ttl                  = "5184000"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intca" {
  backend     = vault_mount.intca.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.intca.certificate_bundle
}

resource "vault_pki_secret_backend_role" "consul" {
  backend          = vault_mount.intca.path
  name             = "consul"
  allowed_domains  = ["consul"]
  allow_subdomains = true
  allow_localhost  = true
  generate_lease   = false
  no_store         = true
  ttl              = "10800"
  max_ttl          = "259200"
  key_bits         = 256
  key_type         = "ec"
  key_usage = [
    "DigitalSignature",
    "KeyAgreement",
    "KeyEncipherment",
  ]
}

resource "local_file" "ca_cert" {
  content         = vault_pki_secret_backend_root_cert.rootca.issuing_ca
  filename        = "${path.module}/ca_cert.pem"
  file_permission = "644"
}

resource "vault_generic_endpoint" "password_policy" {
  path = "sys/policies/password/basic"

  data_json = jsonencode(
    {
      policy = <<-EOF
        length = 20
        rule "charset" {
          charset = "abcdefghijklmnopqrstuvwxyz"
          min-chars = 1
        }
        rule "charset" {
          charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
          min-chars = 1
        }
        rule "charset" {
          charset = "0123456789"
          min-chars = 1
        }
        rule "charset" {
          charset = "!@#$%^&*"
          min-chars = 1
        }
      EOF
    }
  )
}

resource "time_rotating" "ca_cleanup" {
  for_each       = toset(["intca", "rootca", "consulca"])
  rotation_hours = 2

  provisioner "local-exec" {
    command = "vault write ${each.key}/tidy safety_buffer=3600 tidy_cert_store=true tidy_revoked_certs=true"
  }
}
