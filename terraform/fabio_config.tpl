route add nomad nomad.service.consul/ http://${ipaddress}:4646/
route add consul consul.service.consul/ http://${ipaddress}:8500/
