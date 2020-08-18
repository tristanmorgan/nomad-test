key_prefix "_rexec/" {
  policy = "deny"
}
key_prefix "vault/" {
  policy = "deny"
}
key_prefix "fabio" {
  policy = "read"
}
service_prefix "" {
  policy = "write"
}
node_prefix "" {
  policy = "read"
}
agent_prefix "" {
  policy = "read"
}
