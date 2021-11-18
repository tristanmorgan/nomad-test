resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"

  keepers = {
    user = data.external.local_info.result.currentuser
  }
}

resource "vault_auth_backend" "userpass" {
  path        = "userpass"
  type        = "userpass"
  description = "Authenticate using Username-Password"

  tune {
    default_lease_ttl = "1h"
    max_lease_ttl     = "8h"
    token_type        = "default-service"
  }
}

resource "vault_generic_secret" "userpass_user" {
  path         = "auth/userpass/users/${data.external.local_info.result.currentuser}"
  depends_on   = [vault_auth_backend.userpass]
  disable_read = true

  data_json = jsonencode({
    bound_cidrs = []
    password    = random_password.password.result
    policies    = [vault_policy.admin.name]
    ttl         = 3600
  })
}

output "userpass" {
  description = "username and password"
  value       = random_password.password.result
  sensitive   = true
}
