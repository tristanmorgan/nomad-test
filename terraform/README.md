<!-- BEGIN_TF_DOCS -->


## Providers

| Name | Version |
|------|---------|
| <a name="provider_consul"></a> [consul](#provider\_consul) | 2.21.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.3 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.1 |
| <a name="provider_nomad"></a> [nomad](#provider\_nomad) | 2.3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.2 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | 0.12.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 4.3.0 |

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
<!-- END_TF_DOCS -->