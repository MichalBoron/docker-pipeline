terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.15.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "registry" {
  name         = "registry:latest"
  keep_locally = false
}

resource "docker_container" "registry" {
  image   = docker_image.registry.latest
  name    = "myregistry"
  restart = "always"
  ports {
    internal = 5000
    external = 5000
  }
}

# this image will be used as Jenkins agent to build docker containers
resource "docker_image" "docker" {
  name = "docker:latest"
  keep_locally = false
}

resource "docker_container" "docker" {
  image = docker_image.docker.latest
  name = "dockerworker"
  restart = "always"
  tty = true # prevent exiting after startup
  volumes {
    host_path = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
}
