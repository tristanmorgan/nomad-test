#!/bin/sh

consul agent -server -config-file=consul.hcl -bootstrap-expect=1 2>&1 > consul.log &

sleep 2

