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

