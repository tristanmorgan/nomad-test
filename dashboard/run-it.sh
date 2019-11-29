   85  docker run --rm -it -v ${PWD}:/tmp/packer -w /tmp/packer --name test_pack amazonlinux:2
  141  docker image ls
  142  docker image rm tristanmorgan/awscli:1.16.276
  143  docker-clean
  211  docker image ls
  214  cd vault-ent-docker/
  222  docker build -t vault:1.2.4-pro -t vault:pro .
  229  docker image rm vault:1.2.3-pro 
  231  docker image ls
  232  docker image rm vault:1.3.0-beta1 
  233  docker tag vault:pro vault:latest 
  234  docker image rm vault:1.2.4
  235  docker image ls
  236  docker image rm consul:1.6.1-pro
  237  docker image rm consul:pro
  238  docker image rm consul:1.6.1
  239  docker image rm consul:latest 
  240  docker tag consul:1.6.1-prem consul:latest
  241  docker image ls
  242  docker image rm hashicorp/terraform:0.11.14 
  243  docker image rm vibrato/https-echo:current 
  245  docker image ls
  246  docker image rm ruby:alpine 
  247  docker image ls
  514  cp ../consul-ent-docker/* .
  526  docker run --rm -d -p 9003:9003 counting
  527  docker logs upbeat_bell `
docker logs upbeat_bell 
  528  docker logs upbeat_bell 
  529  docker kill  upbeat_bell 
  530  docker run --rm -it -v ${PWD}:/work alpine
  533  docker run --rm -d -p 9003:9003 counting
  534  docker logs flamboyant_hellman 
  549  docker-clean 
  550  docker run --rm -d -p 9002:9002 dashboard
  552  docker logs serene_pasteur 
  553  docker logs flamboyant_hellman 
  568  docker kill serene_pasteur 
  569  docker kill flamboyant_hellman 
  570  docker run --rm -d --network host counting
  571  docker ps -a
  575  docker kill romantic_hofstadter 
  576  docker run --rm -d --name counting -p 9003:9003 counting
  580  docker run --rm -d --name dashboard -p 9002:9002 -e COUNTING_SERVICE_URL dashboard
  582  history | fgrep docker | tee run-it.sh
export COUNTING_SERVICE_URL=http://192.168.227.172:9003
