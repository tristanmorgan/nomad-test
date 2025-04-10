job "countdash" {
  datacenters = ["system-internal"]

  group "counting" {
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
      consul {}
      driver = "docker"
      config {
        image = "tristanmorgan/counting:2021-10-21"
        ports = ["http"]
      }
      template {
        data = <<-EOH
        {{ range service "consul-api" }}CONSUL_HTTP_ADDR="{{ .Address }}:{{ .Port }}"
        {{ end }}
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

  group "dashboard" {
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
      consul {}
      driver = "docker"
      config {
        image = "hashicorpnomad/counter-dashboard:v3"
        ports = ["http"]
      }
      template {
        data = <<-EOH
        {{ range service "counting" }}COUNTING_SERVICE_URL="http://{{ .Address }}:{{ .Port }}"
        {{ end }}
        EOH

        destination = "${NOMAD_SECRETS_DIR}/dashboard.env"
        env         = true
        change_mode = "restart"
      }
      env {
        PORT = "${NOMAD_PORT_http}"
      }
      resources {
        cpu        = 128
        memory     = 64
        memory_max = 128
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
