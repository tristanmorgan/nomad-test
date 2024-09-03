# The token in this resource is sensitive and
# ends up in the terraform state unfortunately
data "external" "local_info" {
  program = ["/bin/bash", "-c", <<EOF
#!/bin/bash

set -e
IP_ADDRESS=$(ipconfig getifaddr en0)

if [ -r .consul-ca.txt ]
then
  CA_TOKEN=$(cat .consul-ca.txt)
  set +e
  vault token lookup $CA_TOKEN 2>/dev/null > /dev/null
  if [ $? -ne 0 ]
  then
      CA_TOKEN=
  fi
  set -e
fi
if [ -z "$CA_TOKEN" ]
then
  CA_TOKEN=$(vault token create -field=token -display-name=consul-ca -role=consul-ca)
  echo -n $CA_TOKEN > .consul-ca.txt
fi
ROUTER_IP=$(networksetup -getinfo 'Wi-Fi' | awk '/^Router/ {print $NF}')

echo "{\"ipaddress\":\"$IP_ADDRESS\","
echo " \"router\":\"$ROUTER_IP\","
echo " \"currentuser\":\"$USER\","
echo " \"vaulttoken\":\"$CA_TOKEN\"}"
EOF
  ]

  depends_on = [
    vault_token_auth_backend_role.consul_ca
  ]
}

data "consul_service" "nomad" {
  name = "nomad"
  tag  = "http"
}

data "environment_sensitive_variable" "access_key" {
  name = "AWS_ACCESS_KEY_ID"

  lifecycle {
    postcondition {
      condition     = startswith(self.value, "AKIA")
      error_message = "access key id should be valid."
    }
  }
}

data "environment_sensitive_variable" "secret_key" {
  name = "AWS_SECRET_ACCESS_KEY"
  lifecycle {
    postcondition {
      condition     = length(self.value) == 40
      error_message = "secret access key should be valid."
    }
  }
}
