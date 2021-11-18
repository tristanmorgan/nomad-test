variable "admin_pass" {
  # type    = "string"
  default = "adminpassword"
}

job "open" {
  datacenters = ["system-internal"]
  type        = "system"

  group "ldap" {
    network {
      mode = "host"
      port "ldap" {
        static = 1389
      }
    }

    service {
      name = "openldap"
      port = "ldap"
      check {
        type     = "tcp"
        port     = "ldap"
        interval = "10s"
        timeout  = "1s"
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "bitnami/openldap:2"
        ports = ["ldap"]
      }
      resources {
        cpu    = 512
        memory = 1024
      }
      env {
        LDAP_ROOT           = "dc=introversion,dc=net"
        LDAP_ADMIN_USERNAME = "admin"
        LDAP_ADMIN_PASSWORD = var.admin_pass
        LDAP_USERS          = "user01"
        LDAP_PASSWORDS      = "password1"
        LDAP_PORT_NUMBER    = "${NOMAD_PORT_ldap}"
        LDAP_ENABLE_TLS     = "no"
      }
    }
  }
}
