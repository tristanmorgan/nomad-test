#!/bin/sh

IP_ADDRESS=$(ipconfig getifaddr en0)
rm -rf data/*
mkdir data/plugins
nomad agent -config=nomad.hcl -data-dir=${PWD}/data -consul-address=$IP_ADDRESS:8500 -vault-address=http://$IP_ADDRESS:8200 -bootstrap-expect=1 2>&1 > nomad.log &

