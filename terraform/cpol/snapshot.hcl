service_prefix "" {
  policy = "read"
}

service "nomad-snapshot" {
  policy = "write"
}

key_prefix "nomad-snapshot" {
  policy = "write"
}

session_prefix "" {
  policy = "write"
}
