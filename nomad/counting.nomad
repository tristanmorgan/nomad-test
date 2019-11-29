job "countdash" {
   datacenters = ["system-internal"]
   group "api" {
     count = 1

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
         image = "counting:1575002457"
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
     count = 2
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
         image = "dashboard:1575002687"
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
