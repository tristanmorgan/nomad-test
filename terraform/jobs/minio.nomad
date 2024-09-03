job "minio" {
  datacenters = ["system-internal"]
  type        = "service"

  group "server" {
    count = 1

    volume "minio_data" {
      type      = "host"
      read_only = false
      source    = "build-output"
    }

    network {
      mode = "host"
      port "http" {
        static = 9000
      }
      port "admin" {}
    }
    task "minio" {
      service {
        name = "minio"
        port = "http"
        tags = [
          "urlprefix-*minio.service.consul/",
          "distribution",
          "logging",
          "metrics",
          "minecraft",
          "registry",
        ]
        check {
          port     = "http"
          type     = "http"
          path     = "/minio/health/ready"
          interval = "30s"
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
          interval = "60s"
          timeout  = "2s"
        }
      }
      driver = "docker"

      volume_mount {
        volume      = "minio_data"
        destination = "/data"
        read_only   = false
      }

      resources {
        cpu        = 512
        memory     = 1024
        memory_max = 2048
      }
      config {
        image = "quay.io/minio/minio:latest"
        args = [
          "server",
          "/data/minio",
          "--console-address=:${NOMAD_PORT_admin}"
        ]
        ports = ["http", "admin"]
        extra_hosts = [
          "minio.service.consul:${NOMAD_IP_admin}",
        ]
      }
      template {
        data = <<-EOH
        {{ with nomadVar "nomad/jobs/minio/server" }}
        MINIO_BROWSER_REDIRECT_URL = "https://minio-admin.service.consul"
        MINIO_DOMAIN        = "minio.service.consul"
        MINIO_PROMETHEUS_AUTH_TYPE = "public"
        MINIO_PROMETHEUS_JOB_ID = "minio-cluster"
        MINIO_PROMETHEUS_URL = "https://prom.service.consul"
        MINIO_ROOT_PASSWORD = "{{ .root_password }}"
        MINIO_ROOT_USER     = "{{ .root_user }}"
        MINIO_SERVER_URL    = "https://minio.service.consul"
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
