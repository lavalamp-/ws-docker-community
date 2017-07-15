FROM wsbackend-base:latest

MAINTAINER Christopher Grayson "chris@websight.io"

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
