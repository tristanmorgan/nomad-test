#!/bin/sh

rm -rf data/*
nomad agent -config=nomad.hcl -data-dir=${PWD}/data -vault-address=$VAULT_ADDR -consul-address=$CONSUL_HTTP_ADDR -bootstrap-expect=1 2>&1 > nomad.log &

