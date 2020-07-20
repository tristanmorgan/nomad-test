#!/bin/sh

IP_ADDRESS=$(ipconfig getifaddr en0)
export VAULT_API_ADDR=http://$IP_ADDRESS:8200
export VAULT_CLUSTER_ADDR=https://$IP_ADDRESS:8201

vault server -config=vault.hcl 2> vault.err > vault.out &

echo export VAULT_ADDR=http://127.0.0.1:8200
echo export VAULT_TOKEN=s.YOURVAULTTOKENHEREORELSE
