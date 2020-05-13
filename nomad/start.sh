#!/bin/sh

rm -rf data/*
mkdir data/plugins
nomad agent -config=nomad.hcl -data-dir=${PWD}/data -consul-address=$CONSUL_HTTP_ADDR -bootstrap-expect=1 2>&1 > nomad.log &

