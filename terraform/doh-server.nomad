job "doh" {
  datacenters = ["system-internal"]
  group "server" {
    count = 1

    network {
      mode = "host"
      port "http" {
        static = 8053
      }
    }

    service {
      name = "dns"
      tags = ["urlprefix-dns.service.consul/"]
      port = "http"
      check {
        type     = "http"
        path     = "/dns-query?name=consul.service.consul"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "dns" {
      driver = "docker"

      template {
        data = <<EOH
listen = [
    ":{{ env `NOMAD_PORT_http` }}",
]
path = "/dns-query"
upstream = [
    "udp:{{ env `NOMAD_IP_http` }}:8600", 
]
verbose = false
log_guessed_client_ip = false
        EOH

        destination = "${NOMAD_TASK_DIR}/doh-server.conf"
      }

      config {
        args = [
          "-conf", "${NOMAD_TASK_DIR}/doh-server.conf",
        ]
        image = "doh-server:2.2.2"
        ports = ["http"]
      }
    }
  }
}
