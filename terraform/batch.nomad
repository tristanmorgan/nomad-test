job "batch" {
  datacenters = ["system-internal"]

  type = "batch"

  periodic {
    // Launch every 30 seconds
    cron = "*/30 * * * * * *"

    // Do not allow overlapping runs.
    prohibit_overlap = true
  }

  group "batch" {
    count = 1

    restart {
      interval = "20s"
      attempts = 2
      delay    = "5s"
      mode     = "delay"
    }

    task "date" {
      driver = "docker"

      config {
        image   = "alpine:3.12.0"
        command = "date"
      }
    }
  }
}
