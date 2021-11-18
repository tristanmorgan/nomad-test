job "external" {
  datacenters = ["system-internal"]
  type        = "system"

  group "service" {
    network {
      mode = "host"
      port "admin" {
      }
    }

    task "monitor" {
      service {
        port = "admin"
        name = "esm-prom"
        tags = ["prom-metrics"]
      }

      driver = "docker"

      vault {
        policies = ["consul-esm"]
        env      = false

        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
      template {
        data = <<-EOH
        CONSUL_HTTP_TOKEN="{{with secret "consul/creds/consul-esm"}}{{.Data.token}}{{end}}"
        CONSUL_HTTP_ADDR="{{ env "attr.unique.network.ip-address"}}:8500"
        EOH

        destination = "${NOMAD_SECRETS_DIR}/consul-esm.env"
        env         = true
        change_mode = "restart"
      }
      template {
        data = <<-EOF
        log_level = "INFO"
        enable_syslog = false
        consul_service = "consul-esm"
        consul_service_tag = ""
        consul_kv_path = "consul-esm/"
        external_node_meta {
            "external-node" = "true"
        }

        node_reconnect_timeout = "72h"
        node_probe_interval = "10s"
        datacenter = "system-internal"
        ping_type = "udp"
        client_address = "0.0.0.0:{{ env `NOMAD_PORT_admin`}}"
        telemetry = {
          prometheus_retention_time = "300s"
        }
        EOF

        destination = "${NOMAD_TASK_DIR}/consul_esm.hcl"
      }

      config {
        args = [
          "--config-file=${NOMAD_TASK_DIR}/consul_esm.hcl"
        ]
        ports = ["admin"]
        image = "hashicorp/consul-esm:0.7.1"
      }
    }
  }
}
