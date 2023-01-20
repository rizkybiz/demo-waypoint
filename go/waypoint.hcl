project = "demo-waypoint"

app "demo-waypoint" {

  # The build lifecycle step defines how to go from source
  # to artifact, and optionally where to store that artifact
  build {
    # Use the cloud native buildpack from Heroku
    use "pack" {}
    registry {
    use "aws-ecr" {
        region     = "us-east-2"
        repository = "waypoint-registry"
        tag        = "latest"
      }
    }
  }

  # The deploy lifecycle step defines how to stage the
  # requisite artifacts on a target deployment platform
  deploy {

    # We can separate out environments using "workspace"
    # to define different deployment platforms depending
    # on the environment
    workspace "dev" {
      use "docker" {}
    }

    workspace "prod" {
      use "kubernetes" {
        probe_path = "/"
        service_port = 3000
      }
    }
  }

  # The release lifecycle step 
  release {

    workspace "prod" {
      use "kubernetes" {
        load_balancer = true
        port          = 80
      }
    }
  }
}
