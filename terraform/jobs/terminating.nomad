job "terminating" {
  datacenters = ["system-internal"]

  group "terminating" {

    network {
      mode = "bridge"
      port "envoy_metrics" {
        to = 9102
      }
    }
    service {
      port = "envoy_metrics"
      name = "envoy-prom"
      tags = ["prom-metrics"]
    }
    service {
      name = "terminating"
      connect {
        gateway {
          proxy {
            config {
              envoy_prometheus_bind_addr = "0.0.0.0:9102"
            }
          }
          terminating {
            service {
              name = "counting"
            }
            service {
              name = "prom"
            }
            service {
              name = "nomad-client"
            }
            service {
              name = "router"
            }
          }
        }
      }
    }

    # fetch the ca certs from the host which are included in the chroot
    # https://developer.hashicorp.com/nomad/docs/drivers/exec#chroot
    #
    # noting that any changes to ca certs on the host will not be picked up dynamically using this method
    task "load-ca-certs" {
      driver = "exec"
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      config {
        command = "/bin/cp"
        args = [
          "--preserve=mode,ownership,timestamps",
          "/etc/ssl/certs/ca-certificates.crt",
          "${NOMAD_ALLOC_DIR}/ca-certificates.crt"
        ]
      }
    }
  }
}

