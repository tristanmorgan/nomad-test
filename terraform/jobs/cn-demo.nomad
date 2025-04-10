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
      connect {
        native = true
      }
    }

    task "uuid" {
      driver = "docker"
      consul {}

      config {
        image = "hashicorpnomad/uuid-api:v5"
        ports = ["api"]
      }
      template {
        data = <<-EOH
        {{ range service "consul-api" }}CONSUL_HTTP_ADDR="{{ .Address }}:{{ .Port }}"{{ end }}
        EOH

        destination = "${NOMAD_SECRETS_DIR}/uuid.env"
        env         = true
        change_mode = "restart"
      }
      env {
        BIND = "0.0.0.0"
        PORT = "${NOMAD_PORT_api}"
      }
      resources {
        cpu        = 64
        memory     = 32
        memory_max = 64
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
      connect {
        native = true
      }
    }

    task "uuid" {
      driver = "docker"
      consul {}

      config {
        image = "hashicorpnomad/uuid-fe:v5"
        ports = ["http"]
      }
      template {
        data = <<-EOH
        {{ range service "consul-api" }}CONSUL_HTTP_ADDR="{{ .Address }}:{{ .Port }}"{{ end }}
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
