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
      tags = ["urlprefix-uuid-api.service.consul/ proto=tcp"]
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

    task "generate" {
      driver = "docker"

      config {
        image = "hashicorpnomad/uuid-api:v3"
        ports = ["api"]
      }
      vault {
        policies = ["uuid"]

        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
      template {
        data = <<-EOF
{{with secret "consul/creds/uuid"}}{{.Data.token}}{{end}}
      EOF

        destination = "${NOMAD_TASK_DIR}/consul.token"
      }
      env {
        BIND                   = "0.0.0.0"
        PORT                   = "${NOMAD_PORT_api}"
        CONSUL_HTTP_ADDR       = "${NOMAD_IP_api}:8500"
        CONSUL_GRPC_ADDR       = "${NOMAD_IP_api}:8502"
        CONSUL_HTTP_TOKEN_FILE = "${NOMAD_TASK_DIR}/consul.token"
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

    task "frontend" {
      driver = "docker"

      config {
        image = "hashicorpnomad/uuid-fe:v3"
        ports = ["http"]
      }
      vault {
        policies = ["uuid"]

        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
      template {
        data = <<-EOF
{{with secret "consul/creds/uuid"}}{{.Data.token}}{{end}}
       EOF

        destination = "${NOMAD_TASK_DIR}/consul.token"
      }
      env {
        UPSTREAM               = "uuid-api"
        BIND                   = "0.0.0.0"
        PORT                   = "${NOMAD_PORT_http}"
        CONSUL_HTTP_ADDR       = "${NOMAD_IP_http}:8500"
        CONSUL_GRPC_ADDR       = "${NOMAD_IP_http}:8502"
        CONSUL_HTTP_TOKEN_FILE = "${NOMAD_TASK_DIR}/consul.token"
      }
    }
    scaling {
      enabled = true
      min     = 1
      max     = 10
    }
  }
}
