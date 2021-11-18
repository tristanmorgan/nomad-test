namespace "*" {
  policy       = "read"
  capabilities = ["read-job", "scale-job"]
}

node {
  policy = "read"
}
