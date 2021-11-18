# usage 
# nomad job dispatch -meta "repo=https://github.com/servian/https-echo.git" -meta "folder=/go/src/github.com/servian/https-echo" go

job "go" {
  type        = "batch"
  datacenters = ["system-internal"]

  meta {
    repo   = ""
    folder = ""
    target = "linux"
  }

  parameterized {
    meta_required = ["repo", "folder"]
    meta_optional = ["target"]
  }

  group "parameterized" {
    count = 1

    volume "build" {
      type      = "host"
      read_only = false
      source    = "build-output"
    }

    task "build" {
      driver = "docker"

      volume_mount {
        volume      = "build"
        destination = "/build"
        read_only   = false
      }

      config {
        image   = "golang:alpine"
        command = "sh"
        args    = ["${NOMAD_TASK_DIR}/build.sh"]
      }

      resources {
        cpu    = 1000
        memory = 256
      }

      template {
        data = <<-EOH
        #!/bin/sh

        set -e

        echo building repo ${NOMAD_META_REPO} for target ${NOMAD_META_TARGET}
        apk add --no-cache git openssh-client

        git clone ${NOMAD_META_REPO} ${NOMAD_META_FOLDER}

        export GOOS=${NOMAD_META_TARGET}
        export GO111MODULE=on
        export CGO_ENABLED=0

        cd ${NOMAD_META_FOLDER}
        go mod tidy
        go build -ldflags='-s -w' -a -v -o /build/$(basename ${NOMAD_META_FOLDER})_${NOMAD_META_TARGET}

        ls -l /build
        echo done
        EOH

        destination = "${NOMAD_TASK_DIR}/build.sh"
      }
    }
  }
}
