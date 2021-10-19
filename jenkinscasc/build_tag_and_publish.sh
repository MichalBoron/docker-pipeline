#!/bin/bash
docker build -t jenkins-custom:0.2 .
docker tag jenkins-custom:0.2 localhost:5000/jenkins-custom
docker push localhost:5000/jenkins-custom
