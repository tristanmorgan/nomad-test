#!/bin/sh

IP_ADDRESS=$(ipconfig getifaddr en0)
rm -rf data/*
mkdir data/plugins

nomad agent -config=nomad.hcl -data-dir=${PWD}/data -consul-address=$IP_ADDRESS:8500 -vault-address=http://$IP_ADDRESS:8200 -bootstrap-expect=1 2> nomad.err > nomad.out &

sleep 10

nomad acl bootstrap | tee bootstrap.txt
echo export NOMAD_ADDR=http://127.0.0.1:4646
echo export NOMAD_TOKEN=THEBIG-LONG-UUID-FROM-BOOTSTRAP
echo 'nomad acl policy apply -description "Anonymous policy (full-access)" anonymous anon.hcl'
