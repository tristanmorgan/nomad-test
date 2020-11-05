data "external" "local_info" {
  program = ["/bin/bash", "-c", <<EOF
#!/bin/bash

set -e
IP_ADDRESS=$(ipconfig getifaddr en0)

echo "{\"ipaddress\":\"$IP_ADDRESS\","
echo " \"consultoken\":\"$CONSUL_HTTP_TOKEN\","
echo " \"nomadtoken\":\"$NOMAD_TOKEN\","
echo " \"vaulttoken\":\"$(vault print token)\"}"
EOF
  ]
}
