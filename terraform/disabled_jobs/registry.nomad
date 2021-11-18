job "registry" {
  meta {
    registry_image_tag = "2.8.1"
  }
  datacenters = ["system-internal"]

  group "docker" {
    network {
      mode = "host"
      port "http" {
      }
      port "debug" {
      }
    }

    service {
      port = "http"
      name = "registry"
      tags = ["urlprefix-registry.service.consul/"]
      check {
        port     = "debug"
        type     = "http"
        path     = "/debug/health"
        interval = "60s"
        timeout  = "2s"
      }
    }

    task "registry" {
      driver = "docker"

      config {
        image = "registry:${NOMAD_META_registry_image_tag}"
        args = [
          "${NOMAD_TASK_DIR}/config.yml"
        ]
        ports = ["http", "debug"]
      }
      template {
        data = <<-EOH
        version: 0.1
        log:
          fields:
            service: registry
        storage:
          cache:
            blobdescriptor: inmemory
          s3:
            accesskey: AKIA012345678901
            secretkey: AbCkTEsTAAAi8ni0EXAMPLEwer23j14FEQW3IUJV
            region: ap-southeast-2
            {{ range service "minio" }}regionendpoint: "http://{{ .Address }}:{{ .Port }}"{{ end }}
            forcepathstyle: true
            bucket: registry
            secure: false
            multipartcopymaxconcurrency: 10
            rootdirectory: /registry
          delete:
            enabled: true
          redirect:
            disable: true
        http:
          addr: "0.0.0.0:{{ env `NOMAD_PORT_http` }}"
          host: "https://registry.service.consul"
          relativeurls: true
          secret: "S0m3R4ndomG4rbage"
          headers:
            X-Content-Type-Options: [nosniff]
          debug:
            addr: 0.0.0.0:{{ env `NOMAD_PORT_debug` }}
            prometheus:
              enabled: true
              path: /metrics
        health:
          storagedriver:
            enabled: true
            interval: 10s
            threshold: 3
        EOH

        destination = "${NOMAD_TASK_DIR}/config.yml"
        change_mode = "restart"
      }
      resources {
        cpu    = 128
        memory = 128
      }
    }
  }
}
