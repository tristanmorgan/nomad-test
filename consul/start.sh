#!/bin/sh

consul agent -server -config-file=consul.hcl -bootstrap-expect=1 2> consul.err > consul.out &

sleep 2

echo export CONSUL_HTTP_ADDR=127.0.0.1:8500
echo export CONSUL_HTTP_TOKEN=ab1469ec-078c-42cf-bb7b-6ef2a52360ea
