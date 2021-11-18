operator = "read"

agent_prefix "" {
  policy = "read"
}

key_prefix "consul-terraform-sync/" {
  policy = "write"
}

node_prefix "" {
  policy = "write"
}

service_prefix "" {
  policy = "write"
}

session_prefix "" {
  policy = "write"
}
