job "countdash" {
  datacenters = ["system-internal"]
  group "api" {
    count = 1
    network {
      mode = "host"
      port "http" {
        static = 8333
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

    task "count" {
      driver = "docker"

      config {
        image = "hashicorpnomad/counter-api:v2"
        ports = ["http"]
      }
      env {
        PORT = "${NOMAD_PORT_http}"
      }
    }
  }

  group "web" {
    network {
      mode = "host"
      port "http" {}
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

    task "dashboard" {
      driver = "docker"

      config {
        image = "hashicorpnomad/counter-dashboard:v2"
        ports = ["http"]
      }
      env {
        COUNTING_SERVICE_URL = "http://counting.service.consul:8333/"
        PORT                 = "${NOMAD_PORT_http}"
      }
    }
    scaling {
      enabled = true
      min     = 1
      max     = 10

      policy {
        evaluation_interval = "5s"
        cooldown            = "1m"

        check "active_connections" {
          source = "nomad-apm"
          query  = "percentage-allocated_cpu"

          strategy "target-value" {
            target = 50
          }
        }
      }
    }
  }
}
