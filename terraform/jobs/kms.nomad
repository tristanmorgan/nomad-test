job "kms" {
  datacenters = ["system-internal"]
  group "local" {
    count = 1

    network {
      mode = "host"
      port "http" {
      }
    }

    service {
      name = "kms"
      tags = ["urlprefix-kms.service.consul/"]
      port = "http"
      check {
        type     = "http"
        path     = "/"
        method   = "POST"
        body     = "{}"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
        header {
          X-Amz-Target = ["TrentService.ListKeys"]
          Content-Type = ["application/x-amz-json-1.1"]
        }
      }
    }

    task "kms" {
      driver = "docker"

      template {
        data = <<-EOH
        Keys:
          Symmetric:
            Aes:
              - Metadata:
                  KeyId: 2632ba26-1619-4c34-af7e-d4416f110161
                BackingKeys:
                  - 40165271e326e7190f355b0dfa8d0128d26aaf203a2d13e570bb41c624b70aea
        Aliases:
          - AliasName: alias/vault
            TargetKeyId: 2632ba26-1619-4c34-af7e-d4416f110161
        EOH

        destination = "${NOMAD_TASK_DIR}/seed.yml"
      }

      config {
        image = "nsmithuk/local-kms:3.11.7"
        ports = ["http"]
      }
      env {
        PORT           = "${NOMAD_PORT_http}"
        KMS_ACCOUNT_ID = "123456789012"
        KMS_REGION     = "ap-southeast-2"
        KMS_SEED_PATH  = "${NOMAD_TASK_DIR}/seed.yml"
      }
      resources {
        cpu        = 64
        memory     = 32
        memory_max = 64
      }
    }
  }
}
