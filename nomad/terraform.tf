resource "nomad_job" "fabio" {
  jobspec = file("${path.module}/fabio.nomad")

  depends_on = [consul_keys.fabio_config]
}


resource "nomad_job" "count" {
  jobspec = file("${path.module}/counting.nomad")

  depends_on = [nomad_job.fabio]
}

resource "nomad_job" "doh" {
  jobspec = file("${path.module}/doh-server.nomad")

  depends_on = [nomad_job.fabio]
}

resource "nomad_job" "grafana" {
  jobspec = file("${path.module}/grafana.nomad")

  depends_on = [nomad_job.fabio]
}

resource "consul_keys" "fabio_config" {
  key {
    path  = "fabio/config"
    value = file("${path.module}/fabio-config.txt")
  }
}
