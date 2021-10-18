# docker-pipeline
Demonstration of a simple CI/CD pipeline implemented with Terraform, Docker, Jenkins, and Gitea.

This project creates infrastructure based on containers.
It sets up a Gitea git server, a docker registry, and an automatically configured Jenkins instance.
The pipeline can be tested using the companion repository https://github.com/MichalBoron/docker-pipeline-flask-app, containing a simple Python Flask application along with Dockerfile and Jenkinsfile. 
Jenkins will poll local git repository, build a docker image of the application and push it to the local docker registry.

## Prerequisites

Machine running Linux, with Docker and Terraform installed.

## Usage

Change directory to `phase1`, run `terraform apply`.

Clone the [companion repository](https://github.com/MichalBoron/docker-pipeline-flask-app) containing Python Flask application code with Dockerfile and Jenkinsfile. 
Visit localhost:3000 and configure the Gitea server, create a user called dev.
In Gitea, logged in as the dev user, create a **publicly visible** repository named **FlaskApp**.
Push the Flask application code to that repository.

Change directory to `jenkinscasc`, run `./build_tag_and_publish.sh`.

Change directory to `phase2`, run `terraform apply`.

Visit Jenkins instance at `localhost:8080` and verify that FlaskAppPipeline built docker image successfully.
Query docker registry  to see if `flask-image` was published: 
	`curl -X GET localhost:5000/v2/_catalog`

Run the Flask application image with (note that port 5000 is already taken by the registry): `docker run -p 5555:5000 localhost:5000/flask-image`.
Verify that Flask is responding correctly by visiting `localhost:5555` in a browser.



## Step by step explanation
Running terraform apply in folder `phase1` creates a private docker registry container (name: registrycontainer) and a Gitea git server container (name: GiteaContainer). Containers created in all phases are connected with a docker bridge network named `simple_pipeline_network`, it is possible to refer to other containers with container names instead of ip addresses.

Gitea git server requires manual configuration.

The [companion repository](https://github.com/MichalBoron/docker-pipeline-flask-app) contains a simple Python Flask application, along with Dockerfile and Jenkinsfile.
The Dockerfile instructs docker how to build the image with required dependencies (python, pip, flask, etc.) and how to run the server.
The Jenkinsfile contains instructions for Jenkins: build image using docker, push image to docker registry.
Contents of this repository have to be pushed to the local Gitea server, under user dev, to a publicly visible repository called FlaskApp. Jenkins will expect to find the repository under http://GiteaContainer:3000/dev/FlaskApp.git . Public visibility removes the need to configure repository credentials on Jenkins.

The `jenkinscasc` folder contains files needed for creating and publishing Jenkins docker image.
As Jenkins will be tasked with creating docker images for commits in FlaskApp repository, Jenkins needs access to docker.
The Dockerfile, based on public image jenkins/jenkins:lts-jdk11, installs docker cli, ensures that jenkins user has access to `/var/run/docker.sock` (needed to execute docker commands), and runs steps related to Jenkins Configuration as Code.
Jenkins Configuration as Code is a plugin to Jenkins that enables automatic configuration of Jenkins based on YAML files and groovy scripts.
`plugins.txt` contains the list of plugins that will be automatically installed.
`jenkins-casc.yaml` contains configuration of:  users and passwords (based on matrix-auth plugin), two pipeline jobs (defined in seedjob.groovy) and a multibranch pipeline job for FlaskApp (using job-dsl plugin).
 The job for FlaskApp polls repository every 5 minutes.
 `build_tag_and_publish.sh` runs docker commands that build image `docker-and-jenkins-casc`, tag it and push it to private registry on `localhost:5000`.
 
 Running `terraform apply` in folder `phase2` creates a container (name: JenkinsContainer) based on `localhost:5000/docker-and-jenkins-casc image`.
 Mounting `/var/run/docker.sock` (docker's UNIX socket) to the container enables Jenkins to run commands on docker instance of the host.
 
 Jenkins polls FlaskApp repository every 5 minutes. If changes are detected, docker image of application is built and published to local registry, according to Jenkinsfile and Dockerfile in FlaskApp repository.
 
##  Other
To access registry from remote hosts, it is necessary to add the registry host to `/etc/docker/daemon.json` (on the machine trying to access the registry).
Below is an example of `/etc/docker/daemon.json`, assuming that the registry is running on host `192.168.1.123`, on port `5000`.
```JSON  
{
  "insecure-registries":["192.168.1.123:5000"]
}
```   
 
