# {{ ansible_managed }}
job "fabio" {
  datacenters = ["{{ nomad_dc }}"]
  type = "system"

  group "fabio" {
    count = 1

    task "fabio" {
      driver = "raw_exec"

      artifact {
        source = "https://github.com/fabiolb/fabio/releases/download/v1.5.8/fabio-1.5.8-go1.10-linux_arm"
      }

      config {
        command = "fabio-1.5.8-go1.10-linux_arm"
      }

      resources {
        cpu    = 100 # 500 MHz
        memory = 128 # 256MB
        network {
          mbits = 10
          port "http" {
            static = 9999
          }
          port "admin" {
            static = 9998
          }
        }
      }

    }
  }
}