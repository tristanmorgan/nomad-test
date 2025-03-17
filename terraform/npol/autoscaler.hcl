namespace "*" {
  policy       = "read"
  capabilities = ["read-job", "scale-job", "submit-recommendation"]

  variables {
    path "nomad-autoscaler/*" {
      capabilities = ["read", "write"]
    }
  }
}

node {
  policy = "read"
}

operator {
  policy = "read"
}
