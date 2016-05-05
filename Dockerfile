# Ubuntu because I know it
FROM ubuntu:xenial

# Version of aws command to install
ENV AWS_CLI_VERSION 1.10.1

# AWS access key.
ENV AWS_ACCESS_KEY_ID ""

# AWS secret key. Access and secret key variables override credentials stored
# in credential and config files.
ENV AWS_SECRET_ACCESS_KEY ""

# AWS region. This variable overrides the default region of the in-use profile,
# if set.
ENV AWS_DEFAULT_REGION us-east-1

# AWS output format
ENV AWS_DEFAULT_FORMAT table

# Setup the docker host
ENV DOCKER_HOST unix:///var/run/docker.sock

# Setup apt-get vars
ENV DEBIAN_FRONTEND noninteractive

# Docker repo info
ENV DOCKER_REPO "deb https://apt.dockerproject.org/repo ubuntu-xenial main"
ENV DOCKER_KEY_SERVER "hkp://p80.pool.sks-keyservers.net:80"
ENV DOCKER_KEY_ID 58118E89F3A912897C070ADBF76221572C52609D

# Install docker and awscli
RUN apt-get update -y                                         \
  && apt-get install -y --no-install-recommends               \
    apt-transport-https ca-certificates                       \
  && apt-key adv                                              \
    --keyserver ${DOCKER_KEY_SERVER}                          \
    --recv-keys ${DOCKER_KEY_ID}                              \
  && echo $DOCKER_REPO > /etc/apt/sources.list.d/docker.list  \
  && apt-get update -y                                        \
  && apt-get purge -y lxc-docker                              \
  && apt-get install -y --no-install-recommends               \
    docker-engine python-setuptools python-pip                \
  && apt-get autoremove -y                                    \
  && apt-get clean                                            \
  && rm -rf /var/lib/apt/lists/*                              \
  && pip install awscli==$AWS_CLI_VERSION

# Users should Forward the docker socket or set DOCKER_HOST
VOLUME /var/run/docker.sock

# Install docker-image-puller
ADD ./docker-image-puller /usr/bin/docker-image-puller
RUN chmod a+x /usr/bin/docker-image-puller

ENTRYPOINT ["/usr/bin/docker-image-puller"]
