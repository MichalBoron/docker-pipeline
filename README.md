# docker-pipeline
Demonstration of a simple CI/CD pipeline implemented with Terraform, Docker, Jenkins, and Gitea.

This project creates infrastructure based on containers.
It sets up a Gitea git server, a docker registry, and an automatically configured Jenkins instance.
The pipeline is tested using the companion repository https://github.com/MichalBoron/docker-pipeline-flask-app, containing a simple Python Flask application along with Dockerfile and Jenkinsfile. 
After infrastructure is set up, the repository is automatically migrated to the local Gitea server.
Jenkins polls the local git repository, builds a docker image of the application and push it to the local docker registry.

## Prerequisites

Linux OS, Docker Engine, containerd, Terraform version 1.0.9+

## Usage

Run `make`, when prompted review plans and type `yes`.

Visit Gtiea instance at `localhost:3000` (credentials: dev / dev). Verify that FlaskApp repository was created.

Visit Jenkins instance at `localhost:8080` (credentials: admin / admin or dev / dev) and verify that FlaskAppPipeline built docker image successfully.

Query local docker registry  to see if `flask-image` was published: 
	`curl -X GET localhost:5000/v2/_catalog`

Run the Flask application image with (note that port 5000 is already taken by the registry): `docker run -p 5555:5000 localhost:5000/flask-image`.
Verify that Flask is responding correctly by visiting `localhost:5555` in a browser.



## Step by step explanation
Running `make` performs the following actions:
1. Creates a private docker registry container (name: registrydc).
2. Creates a container for Gitea git server (name: giteadc).
3. Creates a named docker bridge network for all containers (name: simple_pipeline_network). This makes it possible to refer to other containers by using names instead of ip addresses.
4. Provisions Gitea git server by accepting default configuration, creating administrative user `dev` with password `dev` and instructing the server, by using Gitea REST API, to migrate the [companion repository](https://github.com/MichalBoron/docker-pipeline-flask-app).
5. Builds a custom docker image for the Jenkins instance, installs docker cli, plugins and automatically configures jenkins using Jenkins Configuration as Code plugin. A pipeline for FlaskApp repo is created. The image is pushed to local docker registry.
6. Creates a container for Jenkins based on image built in the previous step (name: jenkinsdc).
7. Thanks to pipeline configured in step 5, every 5 minutes Jenkins will poll FlaskApp repository which contains a Dockerfile and a Jenkinsfile. The Dockerfile instructs docker how to build the image with required dependencies (python, pip, flask, etc.) and how to run the server. Jenkinsfile contains instructions to: build application image using docker, push image to docker registry.


## Repository contents

```
config
├── Dockerfile                                                                     
├── jenkins-casc.yaml                                                              
├── plugins.txt                                                                    
└── seedjob.groovy   

terraform                                                                          
├── base                                                                           
│   ├── main.tf                                                                    
│   └── provision_gitea.sh                                                         
└── jenkins                                                                        
    └── main.tf     
    
Makefile 
```

The `config` folder contains files needed for creating and publishing Jenkins docker image.
As Jenkins will be tasked with creating docker images for commits in FlaskApp repository, Jenkins needs access to docker.
The Dockerfile, based on public image jenkins/jenkins:lts-jdk11, installs docker cli, ensures that jenkins user has access to `/var/run/docker.sock` (needed to execute docker commands), and runs steps related to Jenkins Configuration as Code.
Jenkins Configuration as Code is a plugin to Jenkins that enables automatic configuration of Jenkins based on YAML files and groovy scripts.
`plugins.txt` contains the list of plugins that will be automatically installed.
`jenkins-casc.yaml` contains configuration of:  users and passwords (based on matrix-auth plugin), two pipeline jobs (defined in seedjob.groovy) and a multibranch pipeline job for FlaskApp (using job-dsl plugin).

The `terraform/base` folder contains terraform configuration for local docker registry and Gitea containers. `provision_gitea.sh` handles configuring Gitea after startup.

The `terraform/jenkins` folder contains terraform configuration for jenkins container.
Mounting `/var/run/docker.sock` (docker's UNIX socket) to the container enables Jenkins to run commands on docker instance of the host.

Makefile automates the process of setting up and tearing down the infrastructure. Possible targets:
```
all                            Automatically set up all components.
destroyall                     Destroy all components.
config                         Configure jenkins image and push to repository.
prep                           Run terraform init in given subdirectory.
plan                           Run terraform plan in given subdirectory, output to file tfplan.
apply                          Run terraform apply (from file tfplan) in given subdirectory.
destroy                        Run terraform destroy in given subdirectory.
help                           Prints help for targets with comments
```
Examples of invocations:
```
make
make destroyall
make destroy jenkins
make plan jenkins
make apply jenkins
```
 
##  Other
To access registry from remote hosts, it is necessary to add the registry host to `/etc/docker/daemon.json` (on the machine trying to access the registry).
Below is an example of `/etc/docker/daemon.json`, assuming that the registry is running on host `192.168.1.123`, on port `5000`.
```JSON  
{
  "insecure-registries":["192.168.1.123:5000"]
}
```   
 
