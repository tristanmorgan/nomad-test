job "https" {
  datacenters = ["system-internal"]
  type        = "system"

  group "echo" {
    count = 1

    task "redirect" {
      driver = "docker"

      resources {
        network {
          port "http" {
            static = 80
          }
        }
      }
      service {
        name = "https-echo"
        port = "http"
        check {
          type     = "http"
          path     = "/health"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }

      config {
        image = "vibrato/https-echo:v0.0.5"
        args = [
          "-listen", ":${NOMAD_PORT_http}",
        ]
        port_map {
          http = "${NOMAD_HOST_PORT_http}"
        }
      }
    }
  }
}
