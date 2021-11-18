job "webapp" {
  datacenters = ["system-internal"]

  group "demo" {
    network {
      mode = "host"
      port "http" {
      }
    }

    service {
      port = "http"
      name = "webapp"
      tags = ["urlprefix-webapp.service.consul/"]
      check {
        port     = "http"
        type     = "http"
        path     = "/index.html"
        method   = "HEAD"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "app" {
      driver = "docker"

      config {
        image = "tristanmorgan/webapp:2021-02-05"
        ports = ["http"]
      }

      env {
        PORT = "${NOMAD_PORT_http}"
      }
    }
    scaling {
      enabled = true
      min     = 1
      max     = 10

      policy {
        evaluation_interval = "20s"
        cooldown            = "60s"

        target "nomad-target" {
          Job   = "webapp"
          Group = "demo"
        }

        check "high-memory" {
          source = "nomad-apm"
          query  = "sum_memory"

          strategy "threshold" {
            lower_bound = 40000000
            delta       = -1

            within_bounds_trigger = 1
          }
        }

        check "low-memory" {
          source = "nomad-apm"
          query  = "sum_memory"

          strategy "threshold" {
            upper_bound = 20000000
            delta       = 1

            within_bounds_trigger = 1
          }
        }

      }
    }
  }
}
