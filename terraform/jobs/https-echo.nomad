job "https" {
  datacenters = ["system-internal"]
  type        = "system"

  group "echo" {
    network {
      mode = "host"
      port "http" {
        static = 80
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

    task "redirect" {
      driver = "docker"

      config {
        image = "vibrato/https-echo:v0.0.6"
        args = [
          "-listen", ":${NOMAD_PORT_http}",
        ]
        ports = ["http"]
      }
    }
  }
}
