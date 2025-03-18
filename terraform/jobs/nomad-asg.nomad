job "autoscaler" {
  meta {
    image_tag = "0.4.6-ent"
  }

  datacenters = ["system-internal"]
  type        = "service"

  group "nomad" {
    restart {
      attempts = 2
      interval = "2m"
      delay    = "15s"
      mode     = "fail"
    }

    network {
      mode = "host"
      port "http" {}
    }

    service {
      port = "http"
      name = "nomad-asg"
      tags = ["urlprefix-nomad-asg.service.consul/"]
      check {
        port     = "http"
        type     = "http"
        path     = "/v1/health"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "autoscaler" {
      consul {}
      driver = "docker"

      identity {
        env = true
      }

      vault {
        role = "autoscaler"
        env  = false

        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
      config {
        image   = "hashicorp/nomad-autoscaler-enterprise:${NOMAD_META_image_tag}"
        command = "nomad-autoscaler"
        args = [
          "agent",
          "-config",
          "${NOMAD_TASK_DIR}/config.hcl",
        ]
        ports = ["http"]
      }

      template {
        data = <<-EOF
        http {
          bind_address = "0.0.0.0"
          bind_port    = {{ env "NOMAD_PORT_http" }}
        }

        nomad {
          namespace = "*"
          address = "http://{{ env "attr.unique.network.ip-address" }}:4646"
          token   = "{{with secret "nomad/creds/autoscaler"}}{{.Data.secret_id}}{{end}}"
        }

        high_availability {
          enabled   = true
          lock_path = "nomad/jobs/{{ env "NOMAD_JOB_NAME"}}/{{ env "NOMAD_GROUP_NAME"}}"
        }

        dynamic_application_sizing {
          evaluate_after            = "30m"
        }

        apm "nomad-apm" {
          driver = "nomad-apm"
        }

        apm "prometheus" {
          driver = "prometheus"
          config = {
            address = "http://{{ range service "prom" }}{{ .Address }}:{{ .Port }}{{ end }}"
          }
        }

        policy {
          default_cooldown            = "1m"
          default_evaluation_interval = "15s"
        }

        policy_eval {
          ack_timeout    = "10m"
          delivery_limit = 4

          workers = {
            cluster    = 2
            horizontal = 2
          }
        }

        telemetry {
          prometheus_metrics = true
        }
        EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "${NOMAD_TASK_DIR}/config.hcl"
      }

      resources {
        cpu        = 128
        memory     = 64
        memory_max = 128
      }
      scaling "mem" {
        policy {
          check "max" {
            strategy "app-sizing-max" {}
          }
        }
      }
      scaling "cpu" {
        policy {
          check "95pct" {
            strategy "app-sizing-percentile" {
              percentile = "95"
            }
          }
        }
      }
    }
  }
}
