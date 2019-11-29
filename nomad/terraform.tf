resource "nomad_job" "fabio" {
  jobspec = file("${path.module}/fabio.nomad")
}


resource "nomad_job" "count" {
  jobspec = file("${path.module}/counting.nomad")

  depends_on = [nomad_job.fabio]
}
