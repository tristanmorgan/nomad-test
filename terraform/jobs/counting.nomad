job "countdash" {
  datacenters = ["system-internal"]

  update {
    canary = 1
  }
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

    task "count" {
      driver = "docker"

      config {
        image = "tristanmorgan/counting:2021-10-21"
        ports = ["http"]
      }
      vault {
        policies = ["counting"]
        env      = false

        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
      template {
        data = <<-EOH
        CONSUL_HTTP_TOKEN="{{with secret "consul/creds/counting"}}{{.Data.token}}{{end}}"
        CONSUL_HTTP_ADDR="{{ env "attr.unique.network.ip-address"}}:8500"
        EOH

        destination = "${NOMAD_SECRETS_DIR}/counting.env"
        env         = true
        change_mode = "restart"
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
      template {
        data = <<-EOH
        {{ range service "counting" }}
        COUNTING_SERVICE_URL="http://{{ .Address }}:{{ .Port }}"{{ end }}
        EOH

        destination = "${NOMAD_SECRETS_DIR}/counting.env"
        env         = true
        change_mode = "restart"
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
        check "fixed-value-check" {
          strategy "fixed-value" {
            value = 2
          }
        }
      }
    }
  }
}
