# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

job "dash" {
  datacenters = ["system-internal"]

  group "dash" {
    network {
      mode = "bridge"

      port "http" {
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
      name = "dash"
      port = "http"

      connect {
        sidecar_service {
          proxy {
            config {
              envoy_prometheus_bind_addr = "0.0.0.0:9102"
            }
            upstreams {
              destination_name = "counting"
              local_bind_port  = 8080
            }
          }
        }
      }
    }

    task "dash" {
      driver = "docker"

      env {
        COUNTING_SERVICE_URL = "http://${NOMAD_UPSTREAM_ADDR_counting}"
        PORT                 = "${NOMAD_PORT_http}"
      }

      config {
        image = "hashicorpnomad/counter-dashboard:v3"
      }
    }
  }
}
