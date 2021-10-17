FROM jenkins/jenkins:lts-jdk11

USER root

#VOLUME /var/run/docker.sock

RUN apt update -y ; apt install -y apt-transport-https ca-certificates curl gnupg lsb-release sudo
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
          $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null ; \
      apt update -y ; apt install -y docker-ce-cli ; groupadd docker && usermod -g docker jenkins
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

#usermod -g docker jenkins

USER jenkins

# copy the list of plugins we want to install
COPY plugins.txt /usr/share/jenkins/plugins.txt

# run the install-plugins script to install the plugins
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/plugins.txt

# disable the setup wizard as we will setup jenkins as code
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# copy the seedjob file into the image
COPY seedjob.groovy /usr/local/seedjob.groovy

# copy the config-as-code yaml file into the image
COPY jenkins-casc.yaml /usr/local/jenkins-casc.yaml

# tell the jenkins config-as-code plugin where to find the yaml file
ENV CASC_JENKINS_CONFIG /usr/local/jenkins-casc.yaml

ENTRYPOINT sudo groupmod -g $(stat -c "%g" /var/run/docker.sock) docker && sudo chmod o+rw /var/run/docker.sock && /sbin/tini -- /usr/local/bin/jenkins.sh
