namespace "*" {
  policy       = "read"
  capabilities = ["read-job", "scale-job"]

  variables {
    path "nomad/jobs/autoscaler/nomad*" {
      capabilities = ["read", "write"]
    }
  }
}

node {
  policy = "read"
}
