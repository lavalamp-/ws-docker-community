FROM nginx:latest

MAINTAINER Christopher Grayson "chris@websight.io"

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update \
    && apt-get install -y curl \
    && apt-get -y autoclean

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 6.10.0
ENV ANGULAR_CLI_VERSION 1.0.0-beta.24

RUN mkdir /ws-frontend
ADD ws-frontend-community/package.json /ws-frontend/package.json

RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash

RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && npm install -g "angular-cli@$ANGULAR_CLI_VERSION" \
    && cd /ws-frontend \
    && npm install

ADD nginx/frontend.nginx.conf /etc/nginx/conf.d/default.conf
ADD nginx/server.key /etc/ssl/certs/ws-server.key
ADD nginx/server.crt /etc/ssl/certs/ws-server.crt

EXPOSE 80 443
