job "external" {
  datacenters = ["system-internal"]
  type        = "system"

  group "service" {

    task "monitor" {
      driver = "docker"

      service {
        name = "monitor"
        tags = ["urlprefix-monitor.service.consul/"]
      }

      template {
        data = <<EOH
log_level = "INFO"
enable_syslog = false
consul_service = "consul-esm"
consul_kv_path = "consul-esm/"
external_node_meta {
    "external-node" = "true"
}

node_reconnect_timeout = "72h"
node_probe_interval = "10s"
datacenter = "system-internal"
ping_type = "udp"
      EOH

        destination = "${NOMAD_TASK_DIR}/consul_esm.hcl"
      }

      config {
        args = [
          "--config-file=${NOMAD_TASK_DIR}/consul_esm.hcl"
        ]
        image = "consul-esm:0.3.3"
      }
      env {
        CONSUL_HTTP_ADDR  = "10.10.10.133:8500"
        CONSUL_HTTP_TOKEN = "ab1469ec-078c-42cf-bb7b-6ef2a52360ea"
      }
    }
  }
}
