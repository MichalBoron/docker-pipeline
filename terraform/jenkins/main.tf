terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.15.0"
    }
  }
}

provider "docker" {}

data "docker_network" "private" {
  name = "simple_pipeline_network"
}

resource "docker_image" "jenkins" {
  name         = "localhost:5000/jenkins-custom"
  keep_locally = false
}

resource "docker_container" "jenkins" {
  image = docker_image.jenkins.latest
  name  = "jenkinsdc"
  networks_advanced {
    name = data.docker_network.private.name
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  ports {
    internal = 8080
    external = 8080
  }
}
