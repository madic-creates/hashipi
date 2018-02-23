# {{ ansible_managed }}
job "nginx" {
  datacenters = ["{{ nomad_dc }}"]
  type = "service"

  group "nginx" {
    count = 4

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx"
        port_map {
          http = 80
        }
      }

      resources {
        cpu    = 100 # 100 MHz
        memory = 128 # 128 MB
        network {
          mbits = 10
          port "http" {}
        }
      }

      service {
        name = "nginx"
        tags = ["frontend","urlprefix-/nginx strip=/nginx"]
        port = "http"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}