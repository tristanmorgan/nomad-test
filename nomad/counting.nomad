job "countdash" {
   datacenters = ["system-internal"]
   group "api" {
     task "count" {
       driver = "docker"

       resources {
         network {
            port "http" {}
         }
       }

       service {
         tags = ["urlprefix-/count strip=/count"]
         port = "http"
         check {
            type     = "http"
            path     = "/health"
            port     = "http"
            interval = "10s"
            timeout  = "2s"
          }
       }

       config {
         image = "counting:1574911365"
         port_map {
           http = "${NOMAD_HOST_PORT_http}"
         }
       }
       env {
         PORT = "${NOMAD_PORT_http}"
       }
     }
   }
   group "web" {
     task "dashboard" {
       driver = "docker"

       resources {
         network {
            port "http" {}
         }
       }

       service {
         tags = ["urlprefix-/"]
         port = "http"
         check {
            type     = "http"
            path     = "/health"
            port     = "http"
            interval = "10s"
            timeout  = "2s"
          }
       }

       config {
         image = "dashboard:1574911389"
         port_map {
           http = "${NOMAD_HOST_PORT_http}"
         }
       }
       env {
         COUNTING_SERVICE_URL = "http://${NOMAD_IP_http}:9999/count"
         PORT = "${NOMAD_PORT_http}"
       }
     }
   }
 }
