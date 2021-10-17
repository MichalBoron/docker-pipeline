terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.15.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "dockerjcasc" {
  name  = "localhost:5000/docker-and-jenkins-casc"
  keep_locally = false
}

resource "docker_container" "dockerjcasc" {
  image   = docker_image.dockerjcasc.latest
  name = "JenkinsContainer"
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

