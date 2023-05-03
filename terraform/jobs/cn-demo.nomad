job "cn-demo" {
  datacenters = ["system-internal"]

  group "generator" {
    network {
      mode = "host"
      port "api" {
      }
    }

    service {
      port = "api"
      name = "uuid-api"
      check {
        port     = "api"
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
      task = "generate"

      connect {
        native = true
      }
    }

    vault {
      policies = ["uuid"]
      env      = false

      change_mode   = "signal"
      change_signal = "SIGHUP"
    }

    task "generate" {
      driver = "docker"

      config {
        image = "hashicorpnomad/uuid-api:v5"
        ports = ["api"]
      }
      template {
        data = <<-EOH
        CONSUL_HTTP_TOKEN="{{with secret "consul/creds/uuid"}}{{.Data.token}}{{end}}"
        CONSUL_HTTP_ADDR="{{ env "attr.unique.network.ip-address"}}:8500"
        EOH

        destination = "${NOMAD_SECRETS_DIR}/uuid.env"
        env         = true
        change_mode = "restart"
      }
      env {
        BIND = "0.0.0.0"
        PORT = "${NOMAD_PORT_api}"
      }
    }
  }

  group "frontend" {
    network {
      mode = "host"
      port "http" {
      }
    }

    service {
      port = "http"
      name = "uuid-fe"
      tags = ["urlprefix-uuid-fe.service.consul/"]
      check {
        port     = "http"
        type     = "http"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
      }
      task = "frontend"

      connect {
        native = true
      }
    }

    vault {
      policies = ["uuid"]
      env      = false

      change_mode   = "signal"
      change_signal = "SIGHUP"
    }

    task "frontend" {
      driver = "docker"

      config {
        image = "hashicorpnomad/uuid-fe:v5"
        ports = ["http"]
      }
      template {
        data = <<-EOH
        CONSUL_HTTP_TOKEN="{{with secret "consul/creds/uuid"}}{{.Data.token}}{{end}}"
        CONSUL_HTTP_ADDR="{{ env "attr.unique.network.ip-address"}}:8500"
        EOH

        destination = "${NOMAD_SECRETS_DIR}/uuid.env"
        env         = true
        change_mode = "restart"
      }
      env {
        UPSTREAM = "uuid-api"
        BIND     = "0.0.0.0"
        PORT     = "${NOMAD_PORT_http}"
      }
    }
    scaling {
      enabled = true
      min     = 1
      max     = 10

      policy {
        check "per_second" {
          source = "prometheus"
          query  = "sum(deriv(fabio__route_count{host=\"uuid-fe.service.consul\"}[1m])) * 60"

          strategy "target-value" {
            target = 60
          }
        }
      }
    }
  }
}
