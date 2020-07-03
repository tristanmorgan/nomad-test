#!/bin/sh

IP_ADDRESS=$(ipconfig getifaddr en0)
export VAULT_API_ADDR=http://$IP_ADDRESS:8200
vault server -config=vault.hcl 2>&1 > vault.log &
