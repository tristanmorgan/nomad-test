job "monitoring" {
  datacenters = ["system-internal"]
  group "telemetry" {
    count = 1

    network {
      mode = "host"
      port "prom" {
      }
    }

    service {
      port = "prom"
      name = "prometheus"
      tags = ["urlprefix-prometheus.service.consul/", "prom-metrics"]
      check {
        port     = "prom"
        type     = "http"
        path     = "/-/healthy"
        interval = "10s"
        timeout  = "2s"
      }
    }

    volume "build" {
      type      = "host"
      read_only = false
      source    = "build-output"
    }

    task "prometheus" {
      driver = "docker"

      volume_mount {
        volume      = "build"
        destination = "/prometheus"
        read_only   = false
      }

      vault {
        policies = ["prom"]

        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data = <<-EOH
        ---
        global:
          scrape_interval: 30s
        scrape_configs:
          - job_name: 'consul-sd'
            metrics_path: "/metrics"
            params:
              format:
                - "prometheus"
            consul_sd_configs:
              - server: {{ range service "consul" }}{{ .Address }}:8500{{ end }}
                token: {{with secret "consul/creds/prom"}}{{.Data.token}}{{end}}
                tags:
                  - "prom-metrics"
            relabel_configs:
              - source_labels: [__meta_consul_service]
                target_label: job
            metric_relabel_configs:
              - source_labels:
                  - __name__
                regex: '.*_bucket'
                action: drop
          - job_name: consul
            metrics_path: "/v1/agent/metrics"
            {{with secret "consul/creds/prom"}}
            authorization:
              credentials: "{{.Data.token}}"{{end}}
            params:
              format:
                - "prometheus"
            static_configs:
              - targets:{{ range service "consul" }}
                  - {{ .Address }}:8500{{ end }}
          - job_name: nomad
            metrics_path: "/v1/metrics"
            params:
              format:
                - "prometheus"
            static_configs:
              - targets:{{ range service "nomad-client" }}
                  - {{ .Address }}:{{ .Port }}{{ end }}
          - job_name: vault
            metrics_path: "/v1/sys/metrics"
            params:
              format:
                - "prometheus"
            scheme: http
            static_configs:
              - targets:{{ range service "vault" }}
                - {{ .Address }}:{{ .Port }}{{ end }}
        EOH

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "${NOMAD_TASK_DIR}/consul_sd_config.yml"
      }

      config {
        image = "prom/prometheus:v2.53.1"
        args = [
          "--storage.tsdb.path=/prometheus/promdata",
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
