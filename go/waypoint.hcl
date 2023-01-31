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
    
    workspace "dev" {
      use "kubernetes" {
      probe_path = "/"
      service_port = 3000
      namespace = "dev"
      }
    }

    workspace "pre-prod" {
      use "kubernetes" {
      probe_path = "/"
      service_port = 3000
      namespace = "pre-prod"
      }
    }

    workspace "prod" {
      use "kubernetes" {
      probe_path = "/"
      service_port = 3000
      namespace = "prod"
      }
    }
  }

  # The release lifecycle step 
  release {
    
    workspace "dev" {
        use "kubernetes" {
        load_balancer = true
        port          = 80
        namespace = "dev"
      }
    }
    workspace "pre-prod" {
        use "kubernetes" {
        load_balancer = true
        port          = 80
        namespace = "pre-prod"
      }
    }
    workspace "prod" {
        use "kubernetes" {
        load_balancer = true
        port          = 80
        namespace = "prod"
      }
    }
  }
}
