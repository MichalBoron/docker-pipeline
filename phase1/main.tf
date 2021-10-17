terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.15.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "private_network" {
  name = "simple_pipeline_network"
}

resource "docker_image" "registry" {
  name         = "registry:latest"
  keep_locally = false
}

resource "docker_container" "registry" {
  image   = docker_image.registry.latest
  name    = "registrycontainer"
  restart = "always"
  networks_advanced {
    name = "simple_pipeline_network"
  }
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
  name = "DockerWorkerContainer"
  restart = "always"
  tty = true # prevent exiting after startup
  networks_advanced {
    name = "simple_pipeline_network"
  }
  volumes {
    host_path = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
}

# git server
resource "docker_image" "gitea" {
  name = "gitea/gitea"
  keep_locally = false
}

resource "docker_container" "gitea" {
  image = docker_image.gitea.latest
  name = "GiteaContainer"
  restart = "always"
  networks_advanced {
    name = "simple_pipeline_network"
  }
  ports {
    internal = 3000
    external = 3000
  }
  ports {
    internal = 22
    external = 222
  }
}
