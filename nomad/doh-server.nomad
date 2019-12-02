job "doh" {
  datacenters = ["system-internal"]
  type = "system"

  group "server" {
    count = 1

    task "http" {
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

      config {
        image = "doh-server:1575249005"
        port_map {
          http = "${NOMAD_HOST_PORT_http}"
        }
      }
    }
  }
}
