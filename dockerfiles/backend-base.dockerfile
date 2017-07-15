FROM python:2.7

MAINTAINER Christopher Grayson "chris@websight.io"

RUN apt-get update

ADD ws-backend-community /ws-backend

RUN pip install -r /ws-backend/requirements.txt

COPY configs/tasknode.cfg /ws-backend/tasknode/tasknode.cfg
COPY configs/settings.py /ws-backend/wsbackend/settings.py

WORKDIR /ws-backend
