job "fabio" {
  datacenters = ["system-internal"]

  group "load" {
    count = 1

    network {
      mode = "host"
      port "https" {
        static = 443
      }
      port "admin" {
      }
    }

    service {
      port = "admin"
      name = "fabio"
      tags = ["urlprefix-fabio.service.consul/"]
      check {
        port     = "admin"
        type     = "http"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "balancer" {
      driver = "docker"

      config {
        image = "fabiolb/fabio:1.5.14"
        args  = ["-cfg", "${NOMAD_TASK_DIR}/fabio.properties"]
        ports = ["admin", "https"]
      }

      vault {
        policies = ["fabio"]

        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
      template {
        data = <<EOH
        registry.consul.token = {{with secret "consul/creds/fabio"}}{{.Data.token}}{{end}}
          EOH

        destination = "${NOMAD_TASK_DIR}/fabio.properties"
      }
      env {
        FABIO_insecure                      = true
        FABIO_registry_consul_addr          = "${NOMAD_IP_admin}:8500"
        FABIO_registry_consul_register_addr = "${NOMAD_IP_admin}:${NOMAD_HOST_PORT_admin}"
        FABIO_proxy_addr                    = ":${NOMAD_PORT_https};cs=service-consul"
        FABIO_ui_addr                       = ":${NOMAD_PORT_admin}"
        FABIO_log_access_target             = "stdout"
        FABIO_proxy_strategy                = "rr"
        FABIO_proxy_cs                      = "cs=service-consul;type=vault-pki;cert=intca/issue/consul"
        FABIO_metrics_target                = "statsd"
        FABIO_metrics_statsd_addr           = "${NOMAD_IP_admin}:9125"
        VAULT_ADDR                          = "http://${NOMAD_IP_admin}:8200"
      }
    }
  }
}
