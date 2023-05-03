#!/bin/sh

rm -rf data/*
consul agent -server -config-dir=config/ -bootstrap-expect=1 > consul.out 2>&1 &

while ! fgrep -q 'agent.server: cluster leadership acquired' consul.out
do
  sleep 1
done

IP_ADDRESS=$(ipconfig getifaddr en0)
echo export CONSUL_HTTP_ADDR=${IP_ADDRESS}:8500
echo export CONSUL_HTTP_TOKEN=$(awk '/initial_management/ {print substr($3,2,36)}' config/consul.hcl)
echo terraform apply -target consul_acl_policy.everything
echo cd ../vault
