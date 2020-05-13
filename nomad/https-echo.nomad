job "https" {
  datacenters = ["system-internal"]
  type        = "system"

  group "echo" {
    count = 1

    task "web" {
      driver = "docker"

      resources {
        network {
          port "http" {
          }
        }
      }
      service {
        port = "http"
        name = "https-echo"
        tags = ["urlprefix-:9999/"]
        check {
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }

      config {
        image   = "vibrato/https-echo:v0.0.3"
        args = [
          "-listen",":${NOMAD_PORT_http}",
        ]
        port_map {
          http  = "${NOMAD_PORT_http}"
        }
      }
    }
  }
}
