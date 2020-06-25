#!/bin/sh

export VAULT_API_ADDR=http://10.10.10.133:8200
vault server -config=vault.hcl 2>&1 > vault.log &
