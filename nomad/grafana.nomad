job "grafana" {
  datacenters = ["system-internal"]
  type        = "system"

  group "web" {
    count = 1

    task "grafana" {
      driver = "docker"

      resources {
        network {
          port "http" {
          }
        }
      }
      service {
        port = "http"
        name = "grafana"
        tags = ["urlprefix-grafana.service.consul/"]
        check {
          type     = "http"
          path     = "/health"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }

      config {
        image   = "grafana/grafana:6.5.1"
        command = "/usr/bin/grafana"
        port_map {
          http = "${NOMAD_HOST_PORT_http}"
        }
      }
      env {
        GF_SERVER_ROOT_URL         = "http://grafana.service.consul"
        GF_http_port               = "${NOMAD_PORT_http}"
        GF_SECURITY_ADMIN_PASSWORD = "secret"
      }
    }


    task "prometheus" {
      driver = "docker"

      resources {
        network {
          port "http" {
          }
        }
      }
      service {
        port = "http"
        name = "prometheus"
        tags = ["urlprefix-prometheus.service.consul/"]
        check {
          type     = "http"
          path     = "/health"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }

      config {
        image   = "prom/prometheus:v2.14.0"
        command = "/usr/bin/prometheus"
        port_map {
          http = "${NOMAD_HOST_PORT_http}"
        }
      }
      env {
        GF_SERVER_ROOT_URL         = "http://prometheus.service.consul"
        GF_http_port               = "${NOMAD_PORT_http}"
        GF_SECURITY_ADMIN_PASSWORD = "secret"
      }
    }
  }
}
