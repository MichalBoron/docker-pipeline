terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.15.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "jenkins" {
  name  = "localhost:5000/jenkins-custom"
  keep_locally = false
}

resource "docker_container" "jenkins" {
  image   = docker_image.jenkins.latest
  name = "jenkinsdc"
  networks_advanced {
    name = "simple_pipeline_network"
  }
  volumes {
    host_path = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  ports {
    internal = 8080
    external = 8080
  }
}
