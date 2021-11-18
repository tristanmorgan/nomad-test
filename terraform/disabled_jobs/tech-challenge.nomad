job "servian" {
  datacenters = ["system-internal"]
  group "tech" {
    count = 1
    network {
      mode = "host"
      port "http" {
      }
    }

    vault {
      policies = ["challenge"]
      env      = false

      change_mode   = "signal"
      change_signal = "SIGHUP"
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
        image = "servian/techchallengeapp:0.11.0-scratch"
        args  = ["updatedb", "-s"]
      }
      template {
        data = <<-EOH
        {{with secret "postgres/creds/app"}}
        VTT_DBUSER="{{.Data.username}}"
        VTT_DBPASSWORD="{{.Data.password}}"
        {{end}}
        {{ range service "postgres" }}
        VTT_DBPORT="{{ .Port }}"
        VTT_DBHOST="{{ .Address }}"
        {{ end }}
        VTT_DBNAME = "app"
        EOH

        destination = "${NOMAD_SECRETS_DIR}/database.env"
        env         = true
        change_mode = "restart"
      }
    }

    task "challenge" {
      driver = "docker"

      config {
        image = "servian/techchallengeapp:0.11.0-scratch"
        args  = ["serve"]
        ports = ["http"]
      }
      template {
        data = <<-EOH
        {{with secret "postgres/creds/app"}}
        VTT_DBUSER="{{.Data.username}}"
        VTT_DBPASSWORD="{{.Data.password}}"
        {{end}}
        {{ range service "postgres" }}
        VTT_DBPORT="{{ .Port }}"
        VTT_DBHOST="{{ .Address }}"
        {{ end }}
        VTT_DBNAME     = "app"
        VTT_LISTENHOST = "0.0.0.0"
        VTT_LISTENPORT = "{{ env `NOMAD_PORT_http`}}"
        EOH

        destination = "${NOMAD_SECRETS_DIR}/database.env"
        env         = true
        change_mode = "restart"
      }
    }
    scaling {
      enabled = true
      min     = 1
      max     = 10


      policy {
        check "fixed-value-check" {
          strategy "fixed-value" {
            value = 1
          }
        }
      }
    }
  }
}
