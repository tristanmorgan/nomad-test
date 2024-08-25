job "countdash" {
  datacenters = ["system-internal"]

  group "api" {
    count = 1
    network {
      mode = "host"
      port "http" {
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

    task "counting" {
      driver = "docker"
      identity {
        name = "counting"
        aud  = ["consul.io"]
        ttl  = "1h"

        file = false
      }
      config {
        image = "tristanmorgan/counting:2021-10-21"
        ports = ["http"]
      }
      template {
        data = <<-EOH
        {{ range service "consul-api" }}CONSUL_HTTP_ADDR="{{ .Address }}:{{ .Port }}"{{ end }}
        EOH

        destination = "${NOMAD_SECRETS_DIR}/counting.env"
        env         = true
        change_mode = "restart"
      }
      env {
        PORT = "${NOMAD_PORT_http}"
      }
      resources {
        cpu        = 64
        memory     = 32
        memory_max = 64
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
      identity {
        name = "dashboard"
        aud  = ["consul.io"]
        ttl  = "1h"

        file = false
      }
      config {
        image = "hashicorpnomad/counter-dashboard:v2"
        ports = ["http"]
      }
      template {
        data = <<-EOH
        {{ range service "counting" }}COUNTING_SERVICE_URL="http://{{ .Address }}:{{ .Port }}"{{ end }}
        EOH

        destination = "${NOMAD_SECRETS_DIR}/dashboard.env"
        env         = true
        change_mode = "restart"
      }
      env {
        PORT = "${NOMAD_PORT_http}"
      }
      resources {
        cpu        = 64
        memory     = 32
        memory_max = 64
      }
    }
    scaling {
      enabled = true
      min     = 1
      max     = 10

      policy {
        check "fixed-value-check" {
          strategy "fixed-value" {
            value = 2
          }
        }
      }
    }
  }
}
