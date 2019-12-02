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
         name = "counting"
         tags = ["urlprefix-counting.service.consul:9999/"]
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
         image = "hashicorp/counting-service:0.0.2"
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
         name = "dashboard"
         tags = ["urlprefix-dashboard.service.consul/"]
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
         image = "hashicorp/dashboard-service:0.0.4"
         port_map {
           http = "${NOMAD_HOST_PORT_http}"
         }
       }
       env {
         COUNTING_SERVICE_URL = "http://counting.service.consul:9999/"
         PORT = "${NOMAD_PORT_http}"
       }
     }
   }
 }
