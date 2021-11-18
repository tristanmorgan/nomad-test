job "consul" {
  datacenters = ["system-internal"]
  type        = "system"

  group "terraform" {
    network {
      mode = "host"
      port "admin" {
      }
    }

    service {
      port = "admin"
      name = "consul-tf-sync"
      tags = ["urlprefix-consul-tf-sync.service.consul/"]
      check {
        port     = "admin"
        type     = "http"
        path     = "/v1/status"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "sync" {
      driver = "docker"

      vault {
        policies = ["consul-tf-sync"]
        env      = false

        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
      template {
        data = <<-EOH
        CONSUL_HTTP_TOKEN="{{with secret "consul/creds/consul-tf-sync"}}{{.Data.token}}{{end}}"
        EOH

        destination = "${NOMAD_SECRETS_DIR}/consul-tf-sync.env"
        env         = true
        change_mode = "restart"
      }
      template {
        data = <<-EOF
        log_level = "INFO"

        port = {{ env "NOMAD_PORT_admin"}}

        syslog {}

        buffer_period {
          enabled = true
          min     = "5s"
          max     = "20s"
        }

        consul {
          address = {{ env "attr.unique.network.ip-address"}}
        }

        driver "terraform" {
          version     = "1.2.9"
          # path      = "/"
          log         = false
          persist_log = false
          # working_dir = ""

          backend "consul" {
            gzip = true
          }
        }

        task {
          name        = "learn-cts-example"
          description = "Example task with a few services"
          source      = "findkim/print/cts"
          services    = ["dashboard", "webapp", "fabio"]
        }
        EOF

        destination = "${NOMAD_TASK_DIR}/consul-tf-sync.hcl"
      }

      config {
        args = [
          "--config-file=${NOMAD_TASK_DIR}/consul-tf-sync.hcl"
        ]
        ports = ["admin"]
        image = "hashicorp/consul-terraform-sync:0.4.2"
      }
    }
  }
}
