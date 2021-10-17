#!/bin/bash
docker build -t docker-and-jenkins-casc:0.2 .
docker tag docker-and-jenkins-casc:0.2 localhost:5000/docker-and-jenkins-casc
docker push localhost:5000/docker-and-jenkins-casc

