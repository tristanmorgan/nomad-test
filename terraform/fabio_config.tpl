route add consul consul.service.consul/ http://${ipaddress}:8500/
route weight nomad nomad.service.consul weight 1.00 tags "http"
route weight vault vault.service.consul weight 1.00 tags "active"
