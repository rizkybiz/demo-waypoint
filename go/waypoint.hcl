project = "demo-waypoint"

app "demo-waypoint" {

  # The build lifecycle step defines how to go from source
  # to artifact, and optionally where to store that artifact
  build {
    
    use "docker" {}
    registry {
    use "aws-ecr" {
        region     = "us-east-2"
        repository = "demo-waypoint"
        tag        = "latest"
      }
    }
  }

  # The deploy lifecycle step defines how to stage the
  # requisite artifacts on a target deployment platform
  deploy {

    use "kubernetes" {
      probe_path = "/"
      service_port = 3000
    }
  }

  # The release lifecycle step 
  release {

    use "kubernetes" {
      load_balancer = true
      port          = 80
    }
  }
}
