# syntax = docker/dockerfile:1

# image args
ARG IMAGE
ARG IMAGE_TAG

##### Build Image #####
FROM ${IMAGE}:${IMAGE_TAG}

# constants
ARG USER="borg"
ARG USER_ID="1000"

ARG CONFIG_DIR="/config"
ARG DATA_DIR="/data"

ARG SSH_USER_DIR="${CONFIG_DIR}/ssh"
ARG BORG_REPO_DIR="${DATA_DIR}/repos"

RUN mkdir --mode=555 ${CONFIG_DIR} && \
	mkdir --mode=755 ${DATA_DIR}

RUN apt-get update \
	&& apt-get upgrade \
	&& apt-get install --no-install-recommends -y \
	openssh-server \
	borgbackup \
	&& rm -rf /var/lib/apt/lists/*

# create directory that's required for SSHD to successfully start
RUN mkdir /run/sshd

COPY --chown=root:root --chmod=644 sshd_config /etc/ssh/sshd_config

# user setup
RUN useradd "${USER}" --uid "${USER_ID}" --shell /bin/sh

# borg
RUN chown ${USER}:${USER} ${DATA_DIR}
VOLUME "${BORG_REPO_DIR}"

# ssh login
RUN mkdir -p /home/${USER}/.ssh && \
	ln -s /home/${USER}/.ssh ${SSH_USER_DIR}
VOLUME ${SSH_USER_DIR}}

CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config"]
