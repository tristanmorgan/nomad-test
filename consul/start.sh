#!/bin/sh

consul agent -server -config-file=consul.hcl -bootstrap-expect=1 2> consul.err > consul.out &

sleep 2

echo export CONSUL_HTTP_ADDR=127.0.0.1:8500
echo export CONSUL_HTTP_TOKEN=$(awk '/master/ {print substr($3,2,36)}' consul.hcl)
echo cd ../vault
