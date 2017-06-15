FROM wsbackend-base:latest

MAINTAINER Christopher Grayson "chris@websight.io"

EXPOSE 8000

RUN python manage.py makemigrations
RUN python manage.py migrate

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]