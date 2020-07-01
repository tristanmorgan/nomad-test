#  vault_pki_secret_backend
#  vault_pki_secret_backend_cert
#  vault_pki_secret_backend_config_ca
#  vault_pki_secret_backend_config_urls
#  vault_pki_secret_backend_crl_config
#  vault_pki_secret_backend_intermediate_cert_request
#  vault_pki_secret_backend_intermediate_set_signed
#  vault_pki_secret_backend_role
#  vault_pki_secret_backend_root_cert
#  vault_pki_secret_backend_root_sign_intermediate
#  vault_pki_secret_backend_sign


#  vault secrets tune -max-lease-ttl=87600h rootca
#  vault write rootca/config/urls issuing_certificates="https://vault.service.consul:8200/v1/rootca/ca" crl_distribution_points="https://vault.service.consul:8200/v1/rootca/crl"
#  vault write rootca/roles/consul allowed_domains="consul" allow_subdomains="true" allow_localhost="true" ttl="8760h" max_ttl="87600h" key_bits=521 key_type=ec
#
#  vault write -format=json rootca/root/generate/internal common_name="$USER self-signed Root CA" ttl=8760h format=pem_bundle key_bits=521 key_type=ec > consul.json

resource "vault_mount" "rootca" {
  type        = "pki"
  path        = "rootca"
  description = "Host a Root CA"

  default_lease_ttl_seconds = 3153600
  max_lease_ttl_seconds     = 31536000
}

resource "vault_pki_secret_backend_config_urls" "rootca" {
  backend                 = vault_mount.rootca.path
  issuing_certificates    = ["https://vault.service.consul/v1/rootca/ca"]
  crl_distribution_points = ["https://vault.service.consul/v1/rootca/crl"]
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
  issuing_certificates    = ["https://vault.service.consul/v1/intca/ca"]
  crl_distribution_points = ["https://vault.service.consul/v1/intca/crl"]
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intca" {
  backend = vault_mount.intca.path

  type        = "internal"
  common_name = "app.test.test"
  key_type    = "ec"
  key_bits    = 224

  depends_on = [
    vault_pki_secret_backend_config_urls.intca,
    vault_pki_secret_backend_root_cert.rootca,
  ]
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intca" {
  backend = vault_mount.rootca.path

  csr                  = vault_pki_secret_backend_intermediate_cert_request.intca.csr
  common_name          = "Intermediate CA"
  exclude_cn_from_sans = true
  ou                   = "My OU"
  organization         = "My organization"
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
  ttl              = "72h"
  max_ttl          = "72h"
  key_bits         = 256
  key_type         = "ec"
}
