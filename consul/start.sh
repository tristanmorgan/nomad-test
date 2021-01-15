#!/bin/sh

consul agent -server -config-file=consul.hcl -bootstrap-expect=1 > consul.out 2>&1 &

sleep 2

IP_ADDRESS=$(ipconfig getifaddr en0)
echo export CONSUL_HTTP_ADDR=${IP_ADDRESS}:8500
echo export CONSUL_HTTP_TOKEN=$(awk '/master/ {print substr($3,2,36)}' consul.hcl)
echo cd ../vault
