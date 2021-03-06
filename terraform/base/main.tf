terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.15.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "private" {
  name = "simple_pipeline_network"
}

resource "docker_image" "registry" {
  name         = "registry:2.7.1"
  keep_locally = false
}

resource "docker_container" "registry" {
  image   = docker_image.registry.latest
  name    = "registrydc"
  restart = "always"
  networks_advanced {
    name = docker_network.private.name
  }
  ports {
    internal = 5000
    external = 5000
  }
}

# git server
resource "docker_image" "gitea" {
  name         = "gitea/gitea:1.15.4"
  keep_locally = false
}

resource "docker_container" "gitea" {
  image   = docker_image.gitea.latest
  name    = "giteadc"
  restart = "always"
  networks_advanced {
    name = docker_network.private.name
  }
  ports {
    internal = 3000
    external = 3000
  }
  ports {
    internal = 22
    external = 222
  }

  provisioner "local-exec" {
    command = "bash provision_gitea.sh"
  }
}
