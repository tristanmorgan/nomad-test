resource "consul_node" "router" {
  name    = "router"
  address = data.external.local_info.result.router
  meta = {
    external-node  = true
    external-probe = true
  }
}

resource "consul_service" "router" {

  name = "router"
  node = consul_node.router.name
  port = 80

  meta = {}
  tags = ["urlprefix-${consul_node.router.name}.node.consul/"]

  check {
    check_id                          = "service:router1"
    name                              = "Router Admin Console health check"
    status                            = "passing"
    http                              = "http://${consul_node.router.address}/"
    tls_skip_verify                   = false
    method                            = "HEAD"
    interval                          = "30s"
    timeout                           = "1s"
    deregister_critical_service_after = "1m0s"
  }
}

resource "consul_config_entry" "router_defaults" {
  name = "router"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol         = "http"
    Expose           = {}
    MeshGateway      = {}
    TransparentProxy = {}
  })
}

resource "consul_config_entry" "router_router" {
  name = "router"
  kind = "service-router"

  config_json = jsonencode({
    Routes = [
      {
        Match = {
          HTTP = {
            PathPrefix = "/admin"
          }
        }

        Destination = {
          Service = "router"
        }
      },
    ]
  })
  depends_on = [consul_service.router]
}


resource "consul_config_entry" "global_proxy" {
  name = "global"
  kind = "proxy-defaults"

  config_json = jsonencode({
    Config = {
      protocol = "http"
    }
    Expose           = {}
    TransparentProxy = {}
    MeshGateway = {
      Mode = "local"
    }
  })
}
