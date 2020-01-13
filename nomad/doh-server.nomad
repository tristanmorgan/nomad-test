job "doh" {
  datacenters = ["system-internal"]
  type        = "system"

  group "server" {
    count = 1

    task "dns" {
      driver = "docker"

      resources {
        network {
          port "http" {
            static = 8053
          }
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
        image = "doh-server:1578884285"
        port_map {
          http = "${NOMAD_HOST_PORT_http}"
        }
      }
    }
  }
}
