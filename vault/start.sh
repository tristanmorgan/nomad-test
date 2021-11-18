#!/bin/sh

: > vault.log
mkdir raft

IP_ADDRESS=$(ipconfig getifaddr en0)

if [ -n "$(consul acl policy list | fgrep vault-server)" ]
then
  export CONSUL_HTTP_TOKEN=$(consul acl token create -description "Vault Agent Token $(date '+%s')" -policy-name vault-server | awk '/SecretID/ {print $NF}')
fi

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

echo export VAULT_ADDR=http://$IP_ADDRESS:8200
echo export VAULT_TOKEN=$VAULT_TOKEN
echo vault operator unseal $VAULT_UNSEAL
echo cd ../nomad
