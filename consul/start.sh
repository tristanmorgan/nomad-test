#!/bin/sh

unset CONSUL_HTTP_ADDR

rm -rf data/*
consul agent -server -config-dir=config/ -bootstrap-expect=1 -encrypt="$(consul keygen)" > consul.out 2>&1 &

sleep 1

while ! fgrep -q 'agent.server: cluster leadership acquired' consul.out
do
  sleep 1
done

IP_ADDRESS=$(ipconfig getifaddr en0)
consul acl bootstrap > bootstrap.txt
export CONSUL_HTTP_TOKEN=$(awk '/SecretID/ {print $NF}' bootstrap.txt)
consul acl set-agent-token config_file_service_registration $CONSUL_HTTP_TOKEN

echo export CONSUL_HTTP_ADDR=${IP_ADDRESS}:8501
echo export CONSUL_TLS_SERVER_NAME=consul.service.consul
echo export CONSUL_CACERT=${PWD}/tls/ca_cert.pem
echo export CONSUL_HTTP_SSL=true
echo export CONSUL_HTTP_TOKEN=$CONSUL_HTTP_TOKEN
echo cd ../vault
