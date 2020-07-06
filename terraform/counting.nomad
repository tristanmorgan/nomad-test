job "countdash" {
  datacenters = ["system-internal"]
  group "api" {
    count = 1

    task "count" {
      driver = "docker"

      resources {
        network {
          port "http" {
            static = 8333
          }
        }
      }

      service {
        name = "counting"
        tags = ["urlprefix-counting.service.consul/"]
        port = "http"
        check {
          type     = "http"
          path     = "/health"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }

      config {
        image = "hashicorpnomad/counter-api:v2"
        port_map {
          http = "${NOMAD_HOST_PORT_http}"
        }
      }
      env {
        PORT = "${NOMAD_PORT_http}"
      }
    }
  }
  group "web" {
    count = 2
    task "dashboard" {
      driver = "docker"

      resources {
        network {
          port "http" {}
        }
      }

      service {
        name = "dashboard"
        tags = ["urlprefix-dashboard.service.consul/"]
        port = "http"
        check {
          type     = "http"
          path     = "/health"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }

      config {
        image = "hashicorpnomad/counter-dashboard:v2"
        port_map {
          http = "${NOMAD_HOST_PORT_http}"
        }
      }
      env {
        COUNTING_SERVICE_URL = "http://counting.service.consul:8333/"
        PORT                 = "${NOMAD_PORT_http}"
      }
    }
  }
}
