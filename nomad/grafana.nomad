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
        image   = "grafana/grafana:6.5.2"
        command = "/usr/bin/grafana"
        port_map {
          http = "${NOMAD_HOST_PORT_http}"
        }
      }
      env {
        GF_SERVER_ROOT_URL         = "http://grafana.service.consul"
        GF_SERVER_HTTP_PORT        = "${NOMAD_PORT_http}"
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
          path     = "/-/healthy"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }

      template {
        data = <<EOH
---
scrape_configs:
  - job_name: prometheus
    honor_labels: true
    static_configs:
      - targets:
          - {{ env `NOMAD_IP_http` }}:{{ env `NOMAD_HOST_PORT_http` }}
  - job_name: consul
    metrics_path: "/v1/agent/metrics"
    params:
      format:
        - "prometheus"
      token:
        - "ab1469ec-078c-42cf-bb7b-6ef2a52360ea"
    static_configs:
      - targets:
          - {{ env `NOMAD_IP_http` }}:8500
  - job_name: nomad
    metrics_path: "/v1/metrics"
    params:
      format:
        - "prometheus"
    static_configs:
      - targets:
          - {{ env `NOMAD_IP_http` }}:4646
  EOH

        destination = "${NOMAD_TASK_DIR}/consul_sd_config.yml"
      }

      config {
        image = "prom/prometheus:v2.15.2"
        args = [
          # "--config.file=/etc/prometheus/prometheus.yml",
          "--storage.tsdb.path=/prometheus",
          "--web.console.libraries=/usr/share/prometheus/console_libraries",
          "--web.console.templates=/usr/share/prometheus/consoles",
          "--web.listen-address=0.0.0.0:${NOMAD_PORT_http}",
          "--config.file=${NOMAD_TASK_DIR}/consul_sd_config.yml"
        ]
        port_map {
          http = "${NOMAD_HOST_PORT_http}"
        }
      }
    }
  }
}
