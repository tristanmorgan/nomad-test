job "doh" {
  datacenters = ["system-internal"]
  group "server" {
    count = 1

    network {
      mode = "host"
      port "http" {
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
        data = <<-EOH
        listen = [
            ":{{ env `NOMAD_PORT_http` }}",
        ]
        path = "/dns-query"
        upstream = [
        {{ range service "consul" }}
            "udp:{{ .Address }}:8600",{{ end }}
        ]
        verbose = false
        log_guessed_client_ip = true
        EOH

        destination = "${NOMAD_TASK_DIR}/doh-server.conf"
      }

      config {
        args = [
          "-conf", "${NOMAD_TASK_DIR}/doh-server.conf",
          "-verbose",
        ]
        image = "tristanmorgan/doh-server:2.2.5"
        ports = ["http"]
      }
    }
  }
}
