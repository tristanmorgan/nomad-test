resource "tls_private_key" "vault_server" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
  # private_key_pem
  # public_key_pem
}

resource "tls_cert_request" "vault_server" {
  private_key_pem = tls_private_key.vault_server.private_key_pem

  subject {
    common_name = "vault.service.${var.consul_datacenter}.consul"
  }

  dns_names = [
    "vault.service.${var.consul_datacenter}.consul",
    "vault.service.consul",
    "localhost",
  ]

  ip_addresses = [
    "127.0.0.1"
  ]

  # cert_request_pem
}

resource "tls_locally_signed_cert" "vault_server" {
  cert_request_pem   = tls_cert_request.vault_server.cert_request_pem
  ca_private_key_pem = tls_private_key.common_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.common_ca.cert_pem

  validity_period_hours = 31 * 24

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]

  set_subject_key_id = true

  # cert_pem
}

resource "local_sensitive_file" "vault_cert_pem" {
  content  = tls_locally_signed_cert.vault_server.cert_pem
  filename = "${path.module}/vault-${var.consul_datacenter}-server.pem"

  file_permission = "0644"
}

resource "local_sensitive_file" "vault_key_pem" {
  content  = tls_private_key.vault_server.private_key_pem
  filename = "${path.module}/vault-${var.consul_datacenter}-server-key.pem"

  file_permission = "0600"
}
