variable "dbpass" {
  # type    = string
  default = "Supers3cr3t"
}

job "postgresql" {
  datacenters = ["system-internal"]
  group "post" {
    count = 1
    network {
      mode = "host"
      port "dbport" {
      }
    }

    service {
      name = "postgres"
      port = "dbport"
      check {
        type     = "tcp"
        port     = "dbport"
        interval = "10s"
        timeout  = "2s"
      }
    }

    volume "store" {
      type      = "host"
      read_only = false
      source    = "build-output"
    }

    task "postgres" {
      driver = "docker"

      volume_mount {
        volume      = "store"
        destination = "/var/lib/postgresql"
        read_only   = false
      }

      config {
        image = "postgres:11-alpine"
        ports = ["dbport"]
      }
      template {
        data = <<-EOH
        POSTGRES_USER="admin"
        POSTGRES_PASSWORD="${var.dbpass}"
        PGPORT      = "{{ env `NOMAD_PORT_dbport`}}"
        PGDATA      = "/var/lib/postgresql/data"
        POSTGRES_DB = "app"
        EOH

        destination = "${NOMAD_SECRETS_DIR}/database.env"
        env         = true
        change_mode = "noop"
      }
    }
  }
}
