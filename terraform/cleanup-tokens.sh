#!/bin/sh

for accessor in $(vault list auth/token/accessors); do
  if [ "${#accessor}" -lt 20 ]
  then
    continue;
  fi
  TOKEN_INFO=$(vault write auth/token/lookup-accessor accessor=$accessor | fgrep display_name)
echo $TOKEN_INFO
  if [ "$(echo $TOKEN_INFO | cut -w -f 2)" = "token-terraform" ]
  then
    vault write auth/token/revoke-accessor accessor=$accessor
  fi
done
