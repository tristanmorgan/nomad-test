job "fabio" {
  datacenters = ["system-internal"]
  type        = "system"

  group "fabio" {
    network {
      mode = "host"
      port "https" {
        static = 443
      }
      port "admin" {
      }
      port "prom" {
      }
    }

    task "fabio" {
      consul {}
      vault {
        role = "fabio"
      }
      service {
        port = "admin"
        name = "fabio"
        tags = ["urlprefix-fabio.service.consul/"]
        check {
          port     = "admin"
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "2s"
        }
      }

      service {
        port = "prom"
        name = "fabio-prom"
        tags = ["prom-metrics"]
      }

      driver = "docker"

      config {
        image = "tristanmorgan/fabio:latest"
        ports = ["admin", "https", "prom"]
      }

      template {
        data = <<-EOH
        {{ range service "vault" }}VAULT_ADDR="https://{{ .Address }}:{{ .Port }}"
        VAULT_SKIP_VERIFY = "true"
        {{ end }}
        {{ range service "consul-api" }}FABIO_registry_consul_addr="https://{{ .Address }}:{{ .Port }}"
        FABIO_registry_consul_tls_insecureskipverify = "true"
        {{ end }}
        FABIO_metrics_target="prometheus"
        EOH

        destination = "${NOMAD_SECRETS_DIR}/fabio.env"
        env         = true
        change_mode = "restart"
      }
      env {
        FABIO_insecure                           = true
        FABIO_registry_consul_register_enabled   = "false"
        FABIO_proxy_addr                         = ":${NOMAD_PORT_https};proto=https+tcp+sni;cs=service-consul;tlsmin=tls12,:${NOMAD_PORT_prom};proto=prometheus"
        FABIO_ui_addr                            = ":${NOMAD_PORT_admin}"
        FABIO_log_access_target                  = "stdout"
        FABIO_log_access_format                  = "$remote_host - - [$time_common] \"$request_method $request_host$request_uri $request_proto\" $response_status $response_body_size"
        FABIO_proxy_strategy                     = "rr"
        FABIO_proxy_cs                           = "cs=service-consul;type=vault-pki;cert=intca/issue/consul"
        FABIO_metrics_prefix                     = "{{clean .Exec}}."
        FABIO_ui_routingtable_source_linkenabled = "true"
        FABIO_ui_routingtable_source_scheme      = "https"
      }
    }
  }
}
