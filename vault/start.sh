#!/bin/sh

: > vault.log
mkdir -p raft

IP_ADDRESS=$(ipconfig getifaddr en0)

export CONSUL_HTTP_TOKEN=$(consul acl token create -templated-policy builtin/service -var name:vault-service -description "Vault Agent Token $(date '+%s')" | awk '/SecretID/ {print $NF}')

vault server -config=vault.hcl > vault.out 2>&1 &

VAULT_TOKEN=s.YOURVAULTTOKENHEREORELSE
VAULT_UNSEAL=BIGlongBASE64string
if [ -r vault-init.txt ]
then
  VAULT_TOKEN=$(awk '/Token/ {print $NF}' vault-init.txt)
  VAULT_UNSEAL=$(awk '/Unseal/ {print $NF}' vault-init.txt)
fi

while ! fgrep -q 'core: post-unseal setup complete' vault.out
do
  sleep 1
done

echo export VAULT_ADDR=https://$IP_ADDRESS:8200
echo export VAULT_TOKEN=$VAULT_TOKEN
echo export VAULT_CACERT=${PWD}/tls/ca_cert.pem
echo export VAULT_TLS_SERVER_NAME=vault.service.consul
echo vault operator unseal $VAULT_UNSEAL
echo cd ../nomad
