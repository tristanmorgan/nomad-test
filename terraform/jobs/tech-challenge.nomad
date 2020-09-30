variable "dbpass" {
  # type    = "string"
  default = "secret"
}

job "servian" {
  datacenters = ["system-internal"]
  group "db" {
    count = 1
    network {
      mode = "host"
      port "dbport" {
        static = 3666
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
        image = "postgres:10-alpine"
        ports = ["dbport"]
      }
      env {
        PGPORT            = "${NOMAD_PORT_dbport}"
        POSTGRES_PASSWORD = var.dbpass
        POSTGRES_USER     = "admin"
        PGDATA            = "/var/lib/postgresql/data"
        POSTGRES_DB       = "app"
      }
    }
  }

  group "tech" {
    count = 1
    network {
      mode = "host"
      port "http" {
      }
    }

    service {
      name = "challenge"
      tags = ["urlprefix-challenge.service.consul/"]
      port = "http"
      check {
        type     = "http"
        path     = "/healthcheck/"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "seed" {
      driver = "docker"
      lifecycle {
        hook = "prestart"
      }

      config {
        image = "servian/techchallengeapp:0.8.0-scratch"
        args  = ["updatedb"]
        ports = ["http"]
      }

      env {
        VTT_DBUSER     = "admin"
        VTT_DBPASSWORD = var.dbpass
        VTT_DBNAME     = "app"
        VTT_DBPORT     = "3666"
        VTT_DBHOST     = "${NOMAD_IP_http}"
      }
    }

    task "challenge" {
      driver = "docker"

      config {
        image = "servian/techchallengeapp:0.8.0-scratch"
        args  = ["serve"]
        ports = ["http"]
      }

      env {
        VTT_DBUSER     = "admin"
        VTT_DBPASSWORD = var.dbpass
        VTT_DBNAME     = "app"
        VTT_DBPORT     = "3666"
        VTT_DBHOST     = "${NOMAD_IP_http}"
        VTT_LISTENHOST = "0.0.0.0"
        VTT_LISTENPORT = "${NOMAD_PORT_http}"
      }
    }
  }
}
