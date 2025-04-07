job "snapshot" {
  meta {
    image_tag = "1.9-ent"
  }

  datacenters = ["system-internal"]
  type        = "service"

  group "nomad" {
    task "snapshot" {
      driver = "docker"

      identity {
        env = true
      }

      vault {
        role = "snapshot"
        env  = false

        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      config {
        image = "hashicorp/nomad:${NOMAD_META_image_tag}"
        args = [
          "operator",
          "snapshot",
          "agent",
          "${NOMAD_TASK_DIR}/snaphot.hcl",
        ]
      }

      template {
        data = <<-EOH
        {{ with nomadVar "nomad/jobs/snapshot/nomad/snapshot" }}
        AWS_ACCESS_KEY_ID = "{{ .access_key }}"
        AWS_SECRET_ACCESS_KEY = "{{ .secret_key }}"
        {{ end }}
        EOH

        destination = "${NOMAD_SECRETS_DIR}/snapshot.env"
        env         = true
        change_mode = "restart"
      }

      template {
        data = <<-EOF
        nomad {
          address = "http://{{ env "attr.unique.network.ip-address" }}:4646"
          region  = "global"
          token   = "{{with secret "nomad/creds/management"}}{{.Data.secret_id}}{{end}}"
        }


        snapshot {
          interval         = "1h"
          retain           = 30
          stale            = false
          service          = "nomad-snapshot"
          deregister_after = "72h"
          lock_key         = "nomad-snapshot/lock"
          max_failures     = 3
          prefix           = "nomad"
        }

        log {
          level           = "INFO"
        }

        consul {
          enabled         = true
          http_addr       = "{{ env "attr.unique.network.ip-address" }}:8500"
          datacenter      = "system-internal"
        }

        aws_storage {
          s3_region                 = "ap-southeast-2"
          s3_endpoint               = "http://10.10.10.123:9000"
          s3_disable_tls            = false
          s3_force_path_style       = true
          s3_bucket                 = "distribution"
          s3_key_prefix             = "nomad-snapshot"
          s3_server_side_encryption = false
          s3_enable_kms             = false
        }
        EOF

        change_mode   = "signal"
        change_signal = "SIGHUP"

        destination = "${NOMAD_TASK_DIR}/snaphot.hcl"
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
