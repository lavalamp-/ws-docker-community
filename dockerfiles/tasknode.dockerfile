FROM wsbackend-base:latest

MAINTAINER Christopher Grayson "chris@websight.io"

RUN mv /bin/sh /bin/sh.old && ln -s /bin/bash /bin/sh

RUN apt-get update \
    && apt-get install -y curl zmap nmap \
    && apt-get -y autoclean

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 6.10.0

RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash

RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && npm install -g phantomjs-prebuilt

ENV PATH="/usr/local/nvm/versions/node/v6.10.0/bin:${PATH}"

CMD celery -A tasknode worker -l info -P prefork
