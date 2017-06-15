FROM wsfrontend-base:latest

MAINTAINER Christopher Grayson "chris@websight.io"

ADD ws-frontend /ws-frontend
ADD configs/app.config.ts /ws-frontend/src/app/app.config.ts

RUN source $NVM_DIR/nvm.sh \
    && cd /ws-frontend \
    && ng build --prod

RUN rm -rf /usr/share/nginx/html/*
RUN cd /ws-frontend/dist \
    && cp -R ./* /usr/share/nginx/html/
