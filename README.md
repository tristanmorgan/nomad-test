# Nomad test

Uses Nomad, Consul and Vault on localhost to run some containers and demo features.

## Requirements

* Docker for mac
* Consul
* Nomad
* Terraform
* Vault

## Usage

To use the consul DNS for lookups create a file called /etc/resolver/consul with the contents:

    nameserver 127.0.0.1
    port 8600

setup your environment

    export CONSUL_HTTP_ADDR=127.0.0.1:8500
    export NOMAD_ADDR=http://127.0.0.1:4646
    export VAULT_ADDR=http://127.0.0.1:8200

run Docker for mac.

run ./build.sh in /doh-server

run ./start.sh in /consul

(then export CONSUL_HTTP_TOKEN)

run ./start.sh in /vault

(then init, unseal and export VAULT_TOKEN)

run ./start.sh in /nomad

(then export NOMAD_TOKEN)

Finally:

terraform init and apply in /terraform

that should get most running.

in the terraform folder is a ca_cert.pem that if you import to your keychain you can access the TLS endpoints with out invalid cert warnings.

## Notes

Consul and Nomad will run a single node and persist data in a local folder, Vault uses Consul for its storage. Fabio Load-balancer will use hostnames to route traffic so the consul DNS is recommended. port 80 should get a redirect to https on 443. most services use your lan IP address localhost for a container is inside the container so won't work.

## Shutdown

running the following will stop all the containers and allow a clean shutdown of nomad.

terraform destroy -target nomad_job.everything
