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

resource "vault_pki_secret_backend_intermediate_cert_request" "intca" {
  backend = vault_mount.intca.path

  type         = "internal"
  common_name  = "Tristan Intermediate CA"
  key_type     = "ec"
  key_bits     = 256
  ou           = "Uplink Engineering"
  organization = "Introversion Pty Ltd"

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
  ou                   = vault_pki_secret_backend_intermediate_cert_request.intca.ou
  organization         = vault_pki_secret_backend_intermediate_cert_request.intca.organization
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intca" {
  backend = vault_mount.intca.path

  certificate = vault_pki_secret_backend_root_sign_intermediate.intca.certificate
}

resource "vault_pki_secret_backend_role" "consul" {
  backend          = vault_mount.intca.path
  name             = "consul"
  allowed_domains  = ["consul"]
  allow_subdomains = true
  allow_localhost  = true
  ttl              = "259200"
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
