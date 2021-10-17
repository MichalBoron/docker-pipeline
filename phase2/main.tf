terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.15.0"
    }
  }
}

provider "docker" {}


resource "docker_image" "jcasc" {
  name  = "localhost:5000/jenkins-casc"
  keep_locally = false
}

resource "docker_container" "jcasc" {
  image   = docker_image.jcasc.latest
  name = "JenkinsContainer"
  networks_advanced {
    name = "simple_pipeline_network"
  }
  ports {
    internal = 8080
    external = 8080
  }
}

