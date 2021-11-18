job "minio" {
  datacenters = ["system-internal"]
  type        = "service"
  region      = "global"

  reschedule {
    delay          = "30s"
    delay_function = "exponential"
    max_delay      = "1h"
    unlimited      = true
  }

  group "server" {
    count = 1

    volume "minio_data" {
      type      = "host"
      read_only = false
      source    = "minio_data"
    }

    network {
      mode = "host"
      port "http" {
        static = 9000
      }
      port "admin" {}
    }
    service {
      name = "minio"
      port = "http"
      tags = ["urlprefix-minio.service.consul/"]
      check {
        port     = "http"
        type     = "http"
        path     = "/minio/health/live"
        interval = "10s"
        timeout  = "2s"
      }
    }
    service {
      name = "minio-admin"
      port = "admin"
      tags = ["urlprefix-minio-admin.service.consul/"]
      check {
        port     = "http"
        type     = "http"
        path     = "/minio/health/live"
        interval = "30s"
        timeout  = "2s"
      }
    }
    task "minio" {
      driver = "docker"

      volume_mount {
        volume      = "minio_data"
        destination = "/data"
        read_only   = false
      }

      resources {
        cpu    = 512
        memory = 768
      }
      config {
        image = "quay.io/minio/minio"
        args = [
          "server",
          "/data",
          "--console-address=:${NOMAD_PORT_admin}"
        ]
        ports = ["http", "admin"]
      }
      template {
        data = <<-EOH
        {{ with nomadVar "nomad/jobs/minio/server" }}
        MINIO_BROWSER_REDIRECT_URL = "https://minio-admin.service.consul"
        MINIO_ROOT_USER     = "{{ .root_user }}"
        MINIO_ROOT_PASSWORD = "{{ .root_password }}"
        MINIO_SITE_REGION   = "ap-southeast-2"
        {{ end }}
        EOH

        destination = "${NOMAD_SECRETS_DIR}/minio.env"
        env         = true
        change_mode = "restart"
      }
    }
  }
}
