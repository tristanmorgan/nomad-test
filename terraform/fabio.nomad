job "fabio" {
  datacenters = ["system-internal"]
  type        = "system"

  group "load" {
    count = 1

    task "balancer" {
      driver = "docker"

      resources {
        network {
          port "https" {
            static = 443
          }
          port "admin" {
          }
        }
      }
      service {
        port = "admin"
        name = "fabio"
        tags = ["urlprefix-fabio.service.consul/"]
        check {
          type     = "http"
          path     = "/health"
          port     = "admin"
          interval = "10s"
          timeout  = "2s"
        }
      }

      config {
        image = "fabiolb/fabio:1.5.13-go1.13.4"
        args  = ["-cfg", "${NOMAD_TASK_DIR}/fabio.properties"]
        port_map {
          https = "${NOMAD_HOST_PORT_https}"
          admin = "${NOMAD_HOST_PORT_admin}"
        }
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
        VAULT_ADDR                          = "http://10.10.10.133:8200"
      }
    }
  }
}
