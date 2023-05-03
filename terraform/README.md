## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_consul"></a> [consul](#provider\_consul) | 2.17.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.1 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.3.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |
| <a name="provider_nomad"></a> [nomad](#provider\_nomad) | 1.4.20 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | 0.9.1 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 3.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [consul_acl_policy.everything](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/resources/acl_policy) | resource |
| [consul_acl_token.agent](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/resources/acl_token) | resource |
| [consul_acl_token.vault](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/resources/acl_token) | resource |
| [consul_acl_token_policy_attachment.anonymous](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/resources/acl_token_policy_attachment) | resource |
| [consul_certificate_authority.connect](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/resources/certificate_authority) | resource |
| [consul_config_entry.global_proxy](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/resources/config_entry) | resource |
| [consul_config_entry.router_defaults](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/resources/config_entry) | resource |
| [consul_config_entry.router_router](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/resources/config_entry) | resource |
| [consul_config_entry.uuid](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/resources/config_entry) | resource |
| [consul_keys.fabio_config](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/resources/keys) | resource |
| [consul_node.router](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/resources/node) | resource |
| [consul_prepared_query.service_near_self](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/resources/prepared_query) | resource |
| [consul_service.router](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/resources/service) | resource |
| [local_file.ca_cert](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [nomad_acl_policy.needed](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs/resources/acl_policy) | resource |
| [nomad_acl_token.vault](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs/resources/acl_token) | resource |
| [nomad_job.everything](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs/resources/job) | resource |
| [nomad_scheduler_config.config](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs/resources/scheduler_config) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [terraform_data.consul_agent](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [time_rotating.ca_cleanup](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [time_rotating.intca_rotation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [vault_audit.file](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/audit) | resource |
| [vault_auth_backend.userpass](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/auth_backend) | resource |
| [vault_consul_secret_backend.consul](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/consul_secret_backend) | resource |
| [vault_consul_secret_backend_role.everything](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/consul_secret_backend_role) | resource |
| [vault_consul_secret_backend_role.management](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/consul_secret_backend_role) | resource |
| [vault_generic_endpoint.password_policy](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/generic_endpoint) | resource |
| [vault_generic_secret.userpass_user](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/generic_secret) | resource |
| [vault_github_auth_backend.github](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/github_auth_backend) | resource |
| [vault_identity_group.vibrato_engineers](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_group) | resource |
| [vault_identity_group_alias.vibrato_engineers](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/identity_group_alias) | resource |
| [vault_mount.intca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/mount) | resource |
| [vault_mount.rootca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/mount) | resource |
| [vault_nomad_secret_backend.nomad](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/nomad_secret_backend) | resource |
| [vault_nomad_secret_role.management](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/nomad_secret_role) | resource |
| [vault_nomad_secret_role.needed](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/nomad_secret_role) | resource |
| [vault_pki_secret_backend_config_urls.intca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_config_urls) | resource |
| [vault_pki_secret_backend_config_urls.rootca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_config_urls) | resource |
| [vault_pki_secret_backend_intermediate_cert_request.intca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_intermediate_cert_request) | resource |
| [vault_pki_secret_backend_intermediate_set_signed.intca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_intermediate_set_signed) | resource |
| [vault_pki_secret_backend_role.consul](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_role) | resource |
| [vault_pki_secret_backend_root_cert.rootca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_root_cert) | resource |
| [vault_pki_secret_backend_root_sign_intermediate.intca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_root_sign_intermediate) | resource |
| [vault_policy.admin](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_policy.consul_ca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_policy.needed](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_policy.nomad_server](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_quota_rate_limit.global](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/quota_rate_limit) | resource |
| [vault_token_auth_backend_role.consul_ca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/token_auth_backend_role) | resource |
| [vault_token_auth_backend_role.nomad_cluster](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/token_auth_backend_role) | resource |
| [vault_token_auth_backend_role.nomad_server](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/token_auth_backend_role) | resource |
| [consul_acl_token_secret_id.agent](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/data-sources/acl_token_secret_id) | data source |
| [consul_acl_token_secret_id.vault](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/data-sources/acl_token_secret_id) | data source |
| [consul_agent_config.self](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/data-sources/agent_config) | data source |
| [consul_service.nomad](https://registry.terraform.io/providers/hashicorp/consul/latest/docs/data-sources/service) | data source |
| [external_external.local_info](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [http_http.nomad_server_policy](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [vault_policy_document.admin](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/policy_document) | data source |
| [vault_policy_document.consul_ca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_no_deploy"></a> [no\_deploy](#input\_no\_deploy) | set to true to disable deployments | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_consul_policies"></a> [consul\_policies](#output\_consul\_policies) | List of Consul Policies loaded. |
| <a name="output_nomad_jobs"></a> [nomad\_jobs](#output\_nomad\_jobs) | List of Nomad Jobs loaded. |
| <a name="output_nomad_policies"></a> [nomad\_policies](#output\_nomad\_policies) | List of Nomad Policies loaded. |
| <a name="output_userpass"></a> [userpass](#output\_userpass) | username and password |
| <a name="output_vault_policies"></a> [vault\_policies](#output\_vault\_policies) | List of Vault Policies loaded. |
