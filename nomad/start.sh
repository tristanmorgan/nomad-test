#!/bin/sh

IP_ADDRESS=$(ipconfig getifaddr en0)
rm -rf data/*
mkdir data/plugins

export VAULT_TOKEN=$(vault token create -field=token -display-name=nomad-server -policy nomad-server -period 2h -orphan)
nomad agent -config=nomad.hcl -data-dir=${PWD}/data -consul-address=$IP_ADDRESS:8500 -vault-address=http://$IP_ADDRESS:8200 -bootstrap-expect=1 > nomad.out 2>&1 &


while ! fgrep -q 'nomad.core: established cluster id: cluster_id' nomad.out
do
  sleep 1
done

nomad acl bootstrap > bootstrap.txt
echo export NOMAD_ADDR=http://127.0.0.1:4646
echo export NOMAD_TOKEN=$(awk '/Secret ID/ {print $NF}' bootstrap.txt)
echo cd ../terraform
