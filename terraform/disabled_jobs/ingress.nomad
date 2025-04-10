job "ingress" {
  datacenters = ["system-internal"]

  group "ingress" {

    network {
      mode = "bridge"
      port "inbound" {
        to = 8080
      }
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
      name = "ingress"
      port = "inbound"
      tags = ["urlprefix-*.ingress.consul"]
      check {
        type     = "http"
        path     = "/"
        method   = "HEAD"
        port     = "inbound"
        interval = "60s"
        timeout  = "2s"
        header {
          Host = ["uuid-api.ingress.consul"]
        }
      }
      connect {
        gateway {
          proxy {
            config {
              envoy_prometheus_bind_addr = "0.0.0.0:9102"
            }
          }
          ingress {
            listener {
              port     = 8080
              protocol = "http"
              service {
                name = "*"
              }
            }
          }
        }
      }
    }
  }
}
