#!/bin/sh

export VAULT_API_ADDR=http://10.240.19.198:8200
vault server -config=vault.hcl 2>&1 > vault.log &
