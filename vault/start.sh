#!/bin/sh

echo > vault.log

IP_ADDRESS=$(ipconfig getifaddr en0)
export VAULT_API_ADDR=http://$IP_ADDRESS:8200
export VAULT_CLUSTER_ADDR=https://$IP_ADDRESS:8201

vault server -config=vault.hcl 2> vault.err > vault.out &

VAULT_TOKEN=s.YOURVAULTTOKENHEREORELSE
VAULT_UNSEAL=BIGlongBASE64string
if [ -r vault-init.txt ]
then
  VAULT_TOKEN=$(awk '/Token/ {print $NF}' vault-init.txt)
  VAULT_UNSEAL=$(awk '/Unseal/ {print $NF}' vault-init.txt)
fi

echo export VAULT_ADDR=http://127.0.0.1:8200
echo export VAULT_TOKEN=$VAULT_TOKEN
echo vault operator unseal $VAULT_UNSEAL
echo cd ../nomad
