job "monitoring" {
  datacenters = ["system-internal"]
  group "telemetry" {
    count = 1

    network {
      mode = "host"
      port "http" {
      }
      port "statsd" {
        static = 9125
      }
      port "prom" {
      }
    }
    service {
      port = "http"
      name = "statsd"
      tags = ["urlprefix-statsd.service.consul/"]
      check {
        port     = "http"
        type     = "http"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
      }
    }
    service {
      port = "prom"
      name = "prometheus"
      tags = ["urlprefix-prometheus.service.consul/"]
      check {
        port     = "prom"
        type     = "http"
        path     = "/-/healthy"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "statsd" {
      driver = "docker"

      template {
        data        = <<EOH
mappings:
- match: ^([^.]*)\.([^.]*)--http.status.([^.]*).([^.]*)
  match_type: "regex"
  name: "fabio_http_status"
  labels:
    code: "$3"
    instance: "$1"
    type: "$4"
- match: ^([^.]*)\.fabio--([^.]*)\.([^.]*)\./\.(.*)\.([^.]*)
  match_type: "regex"
  name: "fabio_app"
  labels:
    instance: "$1"
    service: "$2"
    hostname: "$3"
    ipaddress: "$4"
    type: "$5"
- match: ^vault\.([^.]*)\.([^.]*)\.(.*)
  match_type: "regex"
  name: "vault_stat_$1"
  labels:
    catagory: "$2"
    code: "$3"
- match: ^nomad\.([^.]*)\.([^.]*)\.(.*)
  match_type: "regex"
  name: "nomad_stat_$1"
  labels:
    catagory: "$2"
    code: "$3"
- match: ^consul\.([^.]*)\.([^.]*)\.(.*)
  match_type: "regex"
  name: "consul_stat_$1"
  labels:
    catagory: "$2"
    code: "$3"
EOH
        destination = "${NOMAD_TASK_DIR}/mapping.yml"
      }

      config {
        image = "prom/statsd-exporter:v0.18.0"
        args = [
          "--web.telemetry-path=/v1/metrics",
          "--web.listen-address=:${NOMAD_PORT_http}",
          "--statsd.mapping-config=${NOMAD_TASK_DIR}/mapping.yml",
          "--statsd.listen-tcp=:${NOMAD_PORT_statsd}",
          "--statsd.listen-udp=:${NOMAD_PORT_statsd}"
        ]
        ports = ["http", "statsd"]
      }
    }

    task "prometheus" {
      driver = "docker"

      vault {
        policies = ["prom"]

        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data = <<EOH
---
scrape_configs:
  - job_name: prometheus
    honor_labels: true
    static_configs:
      - targets:
          - {{ env `NOMAD_IP_prom` }}:{{ env `NOMAD_PORT_prom` }}
  - job_name: statsd
    metrics_path: "/v1/metrics"
    params:
      format:
        - "prometheus"
    static_configs:
      - targets:
          - {{ env `NOMAD_IP_prom` }}:{{ env `NOMAD_PORT_http` }}
  - job_name: consul
    metrics_path: "/v1/agent/metrics"
    params:
      format:
        - "prometheus"
      token:
        - "{{with secret "consul/creds/prom"}}{{.Data.token}}{{end}}"
    static_configs:
      - targets:
          - {{ env `NOMAD_IP_prom` }}:8500
  - job_name: nomad
    metrics_path: "/v1/metrics"
    params:
      format:
        - "prometheus"
    static_configs:
      - targets:
          - {{ env `NOMAD_IP_prom` }}:4646
  - job_name: vault
    metrics_path: "/v1/sys/metrics"
    params:
      format:
        - "prometheus"
    scheme: http
    static_configs:
      - targets:
        - {{ env `NOMAD_IP_prom` }}:8200
  EOH

        destination = "${NOMAD_TASK_DIR}/consul_sd_config.yml"
      }

      config {
        image = "prom/prometheus:v2.20.1"
        args = [
          "--storage.tsdb.path=/prometheus",
          "--web.console.libraries=/usr/share/prometheus/console_libraries",
          "--web.console.templates=/usr/share/prometheus/consoles",
          "--web.listen-address=0.0.0.0:${NOMAD_PORT_prom}",
          "--config.file=${NOMAD_TASK_DIR}/consul_sd_config.yml"
        ]
        ports = ["prom"]
      }
    }
  }
}
