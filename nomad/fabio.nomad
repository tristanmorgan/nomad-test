job "fabio" {
  datacenters = ["system-internal"]
  type = "system"

  group "load" {
    count = 1

    task "balancer" {
      driver = "docker"

      resources {
        network {
          port "http" {
            static = 9999
          }
          port "admin" {
            static = 9998
          }
          port "tcp" {
            static = 9997
          }
        }
      }
      service {
        port = "admin"
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
        command = "/usr/bin/fabio"
        port_map {
          http = "${NOMAD_HOST_PORT_http}"
          admin = "${NOMAD_HOST_PORT_admin}"
        }
      }
      env {
        FABIO_insecure = false
        FABIO_registry_consul_addr = "${NOMAD_IP_http}:8500"
        FABIO_registry_consul_token = "ab1469ec-078c-42cf-bb7b-6ef2a52360ea"
        FABIO_registry_consul_register_enabled = false
        FABIO_proxy_addr = ":${NOMAD_PORT_tcp};proto=tcp,:${NOMAD_PORT_http};proto=http"
        FABIO_ui_addr = ":${NOMAD_PORT_admin}"
      }
    }
  }
}
