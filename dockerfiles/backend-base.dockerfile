FROM python:2.7

MAINTAINER Christopher Grayson "chris@websight.io"

RUN apt-get update

ADD ws-backend-community /ws-backend

RUN pip install -r /ws-backend/requirements.txt

ADD configs/settings.py /ws-backend/wsbackend/settings.py
ADD configs/tasknode.cfg /ws-backend/tasknode/tasknode.cfg
ADD secrets/gce.json /ws-backend/files/gce.json

ENV GOOGLE_APPLICATION_CREDENTIALS /ws-backend/files/gce.json

WORKDIR /ws-backend
