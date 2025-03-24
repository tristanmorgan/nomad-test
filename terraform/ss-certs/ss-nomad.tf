variable "nomad_region" {
  description = "value of the nomad region (eg. global)"
  default     = "global"
  type        = string
}

resource "tls_private_key" "common_ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
  # private_key_pem
  # public_key_pem
}

resource "tls_self_signed_cert" "common_ca" {
  private_key_pem = tls_private_key.common_ca.private_key_pem

  subject {
    common_name    = "Common CA"
    country        = "US"
    locality       = "San Francisco"
    street_address = ["101 Second Street"]
    organization   = "HashiCorp Inc."
    postal_code    = "94105"
    province       = "CA"
  }

  validity_period_hours = 91 * 24

  allowed_uses = [
    "cert_signing",
    "digital_signature",
    "crl_signing",
  ]

  is_ca_certificate  = true
  set_subject_key_id = true

  # cert_pem
}

resource "tls_private_key" "nomad_server" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
  # private_key_pem
  # public_key_pem
}

resource "tls_cert_request" "nomad_server" {
  private_key_pem = tls_private_key.nomad_server.private_key_pem

  subject {
    common_name = "server.${var.nomad_region}.nomad"
  }

  dns_names = [
    "server.${var.nomad_region}.nomad",
    "nomad.service.${var.consul_datacenter}.consul",
    "nomad.service.consul",
    "localhost",
  ]

  ip_addresses = [
    "127.0.0.1"
  ]

  # cert_request_pem
}

resource "tls_locally_signed_cert" "nomad_server" {
  cert_request_pem   = tls_cert_request.nomad_server.cert_request_pem
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

resource "local_sensitive_file" "common_ca_pem" {
  content  = tls_self_signed_cert.common_ca.cert_pem
  filename = "${path.module}/ca_cert.pem"

  file_permission = "0644"
}

resource "local_sensitive_file" "nomad_cert_pem" {
  content  = tls_locally_signed_cert.nomad_server.cert_pem
  filename = "${path.module}/${var.nomad_region}-server-nomad.pem"

  file_permission = "0644"
}

resource "local_sensitive_file" "nomad_key_pem" {
  content  = tls_private_key.nomad_server.private_key_pem
  filename = "${path.module}/${var.nomad_region}-server-nomad-key.pem"

  file_permission = "0600"
}

resource "tls_private_key" "nomad_client" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
  # private_key_pem
  # public_key_pem
}

resource "tls_cert_request" "nomad_client" {
  private_key_pem = tls_private_key.nomad_client.private_key_pem

  subject {
    common_name = "client.${var.nomad_region}.nomad"
  }

  dns_names = [
    "client.${var.nomad_region}.nomad",
    "localhost",
  ]

  ip_addresses = [
    "127.0.0.1"
  ]

  # cert_request_pem
}

resource "tls_locally_signed_cert" "nomad_client" {
  cert_request_pem   = tls_cert_request.nomad_client.cert_request_pem
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

resource "local_sensitive_file" "nomad_client_cert_pem" {
  content  = tls_locally_signed_cert.nomad_client.cert_pem
  filename = "${path.module}/${var.nomad_region}-client-nomad.pem"

  file_permission = "0644"
}

resource "local_sensitive_file" "nomad_client_key_pem" {
  content  = tls_private_key.nomad_client.private_key_pem
  filename = "${path.module}/${var.nomad_region}-client-nomad-key.pem"

  file_permission = "0600"
}
