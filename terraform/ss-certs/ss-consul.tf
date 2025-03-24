variable "consul_datacenter" {
  description = "value of the consul datacenter (eg. dc1)"
  default     = "dc1"
  type        = string
}

resource "tls_private_key" "consul_server" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
  # private_key_pem
  # public_key_pem
}

resource "tls_cert_request" "consul_server" {
  private_key_pem = tls_private_key.consul_server.private_key_pem

  subject {
    common_name = "server.${var.consul_datacenter}.consul"
  }

  dns_names = [
    "server.${var.consul_datacenter}.consul",
    "consul.service.${var.consul_datacenter}.consul",
    "consul.service.consul",
    "localhost",
  ]

  ip_addresses = [
    "127.0.0.1"
  ]

  # cert_request_pem
}

resource "tls_locally_signed_cert" "consul_server" {
  cert_request_pem   = tls_cert_request.consul_server.cert_request_pem
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

resource "local_sensitive_file" "consul_cert_pem" {
  content  = tls_locally_signed_cert.consul_server.cert_pem
  filename = "${path.module}/consul-${var.consul_datacenter}-server.pem"

  file_permission = "0644"
}

resource "local_sensitive_file" "consul_key_pem" {
  content  = tls_private_key.consul_server.private_key_pem
  filename = "${path.module}/consul-${var.consul_datacenter}-server-key.pem"

  file_permission = "0600"
}

resource "tls_private_key" "consul_client" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "consul_client" {
  private_key_pem = tls_private_key.consul_client.private_key_pem

  subject {
    common_name = "client.${var.consul_datacenter}.consul"
  }

  dns_names = [
    "client.${var.consul_datacenter}.consul",
    "localhost",
  ]

  ip_addresses = [
    "127.0.0.1"
  ]
}

resource "tls_locally_signed_cert" "consul_client" {
  cert_request_pem   = tls_cert_request.consul_client.cert_request_pem
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
}

resource "local_sensitive_file" "consul_client_cert_pem" {
  content  = tls_locally_signed_cert.consul_client.cert_pem
  filename = "${path.module}/consul-${var.consul_datacenter}-client.pem"

  file_permission = "0644"
}

resource "local_sensitive_file" "consul_client_key_pem" {
  content  = tls_private_key.consul_client.private_key_pem
  filename = "${path.module}/consul-${var.consul_datacenter}-client-key.pem"

  file_permission = "0600"
}

