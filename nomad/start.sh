#!/bin/sh

umask 022
rm -rf data/*
mkdir data/plugins

unset DOCKER_HOST

export CONSUL_HTTP_TOKEN=$(consul acl token create -templated-policy builtin/nomad-server -description "Nomad Agent Token $(date '+%s')" | awk '/SecretID/ {print $NF}')

unset VAULT_TOKEN

: > nomad.out

ent-nomad agent -config=nomad.hcl -data-dir=${PWD}/data -encrypt=$(nomad operator gossip keyring generate) -consul-address=$CONSUL_HTTP_ADDR -vault-address=$VAULT_ADDR -bootstrap-expect=1 > nomad.out 2>&1 &

while ! fgrep -q 'client: node registration complete' nomad.out
do
  sleep 1
done

IP_ADDRESS=$(ipconfig getifaddr en0)
export NOMAD_ADDR=http://${IP_ADDRESS}:4646
nomad acl bootstrap > bootstrap.txt
echo export NOMAD_ADDR=http://${IP_ADDRESS}:4646
echo export NOMAD_TOKEN=$(awk '/Secret ID/ {print $NF}' bootstrap.txt)
echo export TF_VAR_no_deploy=true
echo cd ../terraform
