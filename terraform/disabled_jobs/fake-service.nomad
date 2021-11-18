
job "fake" {
  datacenters = ["system-internal"]

  group "service_one" {
    network {
      mode = "host"
      port "http" {
      }
    }

    service {
      name = "fake"
      port = "http"
      tags = ["urlprefix-fake.service.consul/"]
      check {
        type     = "http"
        path     = "/health"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "layer_one" {
      driver = "docker"

      resources {
        cpu    = 256
        memory = 64
      }

      template {
        data = <<-EOH
        NAME="{{ env `NOMAD_TASK_NAME` }}"
        UPSTREAM_WORKERS="4"
        LISTEN_ADDR="0.0.0.0:{{ env `NOMAD_PORT_http` }}"
        SERVER_TYPE="http"
        ERROR_RATE="0.01"
        UPSTREAM_URIS="{{ range service "fake-two" }}http://{{ .Address }}:{{ .Port }}/,{{ end }}"
        MESSAGE="{{ env `NOMAD_GROUP_NAME` }}.{{ env `NOMAD_TASK_NAME` }}"
        TIMING_50_PERCENTILE="0.5"
        TIMING_90_PERCENTILE="1"
        TIMING_99_PERCENTILE="5"
        TIMING_VARIANCE="10"
        HTTP_CLIENT_REQUEST_TIMEOUT="5"
        EOH

        destination = "${NOMAD_SECRETS_DIR}/layer_one.env"
        env         = true
        change_mode = "restart"
      }
      config {
        image = "nicholasjackson/fake-service:v0.22.7"
        ports = ["http"]
      }
    }
  }


  group "service_two" {
    network {
      mode = "host"
      port "http" {
      }
    }

    service {
      name = "fake-two"
      port = "http"
      check {
        type     = "http"
        path     = "/health"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    scaling {
      enabled = true
      min     = 1
      max     = 10


      policy {
        check "fixed-value-check" {
          strategy "fixed-value" {
            value = 3
          }
        }
      }
    }


    task "fake_two" {
      driver = "docker"

      resources {
        cpu    = 256
        memory = 64
      }

      template {
        data = <<-EOH
        NAME="{{ env `NOMAD_TASK_NAME` }}"
        LISTEN_ADDR="0.0.0.0:{{ env `NOMAD_PORT_http` }}"
        SERVER_TYPE="http"
        ERROR_RATE="0.01"
        UPSTREAM_URIS="{{ range service "fake-three" }}http://{{ .Address }}:{{ .Port }}/,{{ end }}"
        MESSAGE="{{ env `NOMAD_GROUP_NAME` }}.{{ env `NOMAD_TASK_NAME` }}"
        TIMING_50_PERCENTILE="0.5"
        TIMING_90_PERCENTILE="1"
        TIMING_99_PERCENTILE="5"
        TIMING_VARIANCE="10"
        HTTP_CLIENT_REQUEST_TIMEOUT="5"
        EOH

        destination = "${NOMAD_SECRETS_DIR}/layer_two.env"
        env         = true
        change_mode = "restart"
      }
      config {
        image = "nicholasjackson/fake-service:v0.22.7"
        ports = ["http"]
      }
    }
  }

  group "service_tre" {
    network {
      mode = "host"
      port "http" {
      }
    }

    service {
      name = "fake-three"
      port = "http"
      check {
        type     = "http"
        path     = "/health"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "fake_tre" {
      driver = "docker"

      resources {
        cpu    = 256
        memory = 64
      }

      template {
        data = <<-EOH
        NAME="{{ env `NOMAD_TASK_NAME` }}"
        LISTEN_ADDR="0.0.0.0:{{ env `NOMAD_PORT_http` }}"
        SERVER_TYPE="http"
        ERROR_RATE="0.01"
        MESSAGE="{{ env `NOMAD_GROUP_NAME` }}.{{ env `NOMAD_TASK_NAME` }}"
        TIMING_50_PERCENTILE="0.5"
        TIMING_90_PERCENTILE="1"
        TIMING_99_PERCENTILE="5"
        TIMING_VARIANCE="10"
        HTTP_CLIENT_REQUEST_TIMEOUT="5"
        EOH

        destination = "${NOMAD_SECRETS_DIR}/layer_two.env"
        env         = true
        change_mode = "restart"
      }
      config {
        image = "nicholasjackson/fake-service:v0.22.7"
        ports = ["http"]
      }
    }
  }
}
