# Web Sight Docker Deployment

Web Sight is a software platform that enables red and blue teams to automate the information gathering processes required by their day-to-day jobs. At present, Web Sight performs the following activities:

* Domain name enumeration
* DNS record enumeration
* Network scanning (large scale)
* Network service fingerprinting
* SSL support enumeration
* SSL certificate inspection
* Application-layer inspection for supported application protocols (currently only HTTP)

These activities are entirely automated, and require only the following information as scanning "seeds":

* Network ranges
* Domain names

For web applications that are discovered across an organization's domain names and network ranges, the following activities are conducted:

* Virtual host enumeration
* User agent enumeration
* Crawling
* Screen shotting

The goal of automating this information gathering process is to provide users with the situational awareness that proper security strategizing (both offensively and defensively) requires. Simply put, how can you hope to attack and/or defend an organization if you don't have a good understanding of the organization's attack surface at a given point in time? Furthermore, given the nature of enterprise attack surface (constant churn, massive scale), any understanding of attack surface is fleeting, and attack surface must be re-evaluated regularly to maintain situational awareness.

Please note that this documentation is very much a work in progress. If you find any part of it confusing, please feel free to submit a question via GitHub and I will do my best to respond in a timely fashion.

## Introduction

This repository contains the software necessary to get Web Sight's front- and back-end components up and running on top of Docker.

Web Sight is comprised of two main components - the [front-end](https://github.com/lavalamp-/ws-frontend-community) and the [back-end](https://github.com/lavalamp-/ws-backend-community). The front-end is a single page application written using Angular 2 (Typescript) and the back-end is a fairly complicated distributed N-tier system comprised of RabbitMQ, Python (Django Rest Framework, Celery, SQLAlchemy), PostgreSQL, Redis, and Elasticsearch. As may be apparent from this list of dependencies, getting all of the components up and running and working with one another can be a bit of a chore.

Enter [Docker](https://www.docker.com/). If you haven't used Docker before, I highly recommend reading the [getting started Docker documentation](https://docs.docker.com/get-started/). In a nut shell, Docker enables you to quickly deploy applications and all of their dependencies across various environments at ease. This includes deploying N-tier applications that have inter-application dependencies, which makes Docker a perfect fit for Web Sight deployment.

## Dependencies

Dependencies for the [front-](https://github.com/lavalamp-/ws-frontend-community) and [back-end](https://github.com/lavalamp-/ws-backend-community) components can be found in their respective Git repository README files. Getting things deployed through Docker simplifies things a bit, as many of the back-end dependencies are handled within the Docker deployment. All in all, the Docker deployment relies upon the following:

* [Docker](https://www.docker.com/) - All software is deployed within Docker containers and connections between application dependencies is handled by Docker as well
* [Elasticsearch](https://www.elastic.co/) - Data collected by task nodes is largely stored in Elasticsearch to enable rapid querying and insertion at scale as well as to reduce database load
* [PostgreSQL](https://www.postgresql.org/) - Web Sight makes use of PostgreSQL for storage of all database-related data
* [AWS S3](https://aws.amazon.com/s3/) - File storage

## Directory Layout

The contents of the Web Sight Docker project are laid out as follows:

```
/configs/ - Configuration files for the front- and back-end applications
/nginx/ - Files for the Nginx server that is deployed within Docker
/dockerfiles/ - The .dockerfile files for creating the Docker images that the full Docker deployment relies upon
/scripts/ - Various scripts used for setting up and testing the Docker deployment
/docker-compose.yaml - The Docker compose file for spinning up the N-tier Web Sight application.
```

## Installation

**Web Sight has been tested and works with both OSX and Ubuntu. The steps here should work on other Linux distributions, but YMMV.**

To get started with the Web Sight Docker deployment, first clone the repository and `cd` into the cloned directory:

```
git clone https://github.com/lavalamp-/ws-docker-community.git
cd ws-docker-community
```

Once the repository is cloned, pull down the front- and back-end repositories that the Docker deployment relies upon by running the following command:

```
git submodule update --init --recursive
```

With all of the relevant code now pulled down, we must install and configure the non-Dockerized dependencies that Web Sight relies upon. Note that the installation process for these dependencies can vary greatly depending on what platform you are using, so I'll leave links here to the technologies and their respective installation instructions:

* [PostgreSQL](https://www.postgresql.org/download/)
* [Elasticsearch 5.*](https://www.elastic.co/guide/en/elasticsearch/reference/current/_installation.html)

Once all of these dependencies have been installed, you will want to:

1. Create a [database user as well as a database within PostgreSQL](https://www.ntchosting.com/encyclopedia/databases/postgresql/create-user/)
2. Give [full permissions for the given database user on the newly-created database](https://www.postgresql.org/docs/9.0/static/user-manag.html)
3. Ensure that the given PostgreSQL user can [access the database server from the IP address(es) where you'll be running Web Sight from](https://www.postgresql.org/docs/9.1/static/auth-pg-hba-conf.html)
4. Create a [user within Elasticsearch](https://www.elastic.co/guide/en/x-pack/current/setting-up-authentication.html)

With all of the Web Sight code pulled down and the software dependencies installed, we can move on to configuring the deployment

## Configuration

Web Sight makes use of a number of third-party services to provide various parts of functionality to application users. In order for Web Sight to be fully functional, you must sign up for these third-party services:

* [Amazon Web Services](https://aws.amazon.com/) (**req'd**) - Usage of S3 (**req'd**) and usage of Amazon Elasticsearch (optional)
* [Farsight DNSDB](https://www.dnsdb.info/) (optional) - Greatly boosts domain name enumeration
* [Stripe](https://stripe.com/docs/api) (**req'd**) - Currently used for payment processing and the API currently requires at least dev credentials for orders to be placed (this will be phased out soon)
* SMTP Mail Server (**req'd**) - Sending emails, can be any SMTP service
* [reCAPTCHA](https://www.google.com/recaptcha/intro/invisible.html) (**req'd**) - Protects against automated attacks, will be phased out soon

Once you have signed up for these services and have the relevant API keys, we can move on to configuring the front- and back-end Web Sight components.

First we will want to configure the front-end. To do so, copy the example configuration file over:

```
cp configs/app.config.ts.example configs/app.config.ts
```

Once the configuration file has been copied over, we must alter only the following values within it:

```
stripePublishableKey - The publishable key from your from your [Stripe account](https://dashboard.stripe.com/account/apikeys).
```

With the front-end configuration file now set up, let's move on to the back-end. Start by copying over the example configuration file again:

```
cp configs/tasknode.cfg.example configs/tasknode.cfg
```

Once the configuration file has been copied over, we must alter the following values:

```
[AWS]

aws_key_id - Your AWS key ID
aws_secret_key - Your AWS secret key

[Database]

db_host - The IP address or hostname where your PostgreSQL server is running
db_port - The port where your PostgreSQL server is running
db_name - The name of the database to use for Web Sight
db_user - The username to connect to PostgreSQL with
db_password - The password to connect to PostgreSQL with

[DNS]

dns_dnsdb_api_key - Your Farsight DNSDB API key

[Elasticsearch]

es_username - The username to connect to Elasticsearch with
es_password - The password to connect to Elasticsearch with
es_host - The hostname or IP address where your Elasticsearch server is running
es_port - The port where your Elasticsearch server is running
es_use_aws - Whether or not to use AWS Elasticsearch (if you set this value to True, then the credentials in the [AWS] section will be used to connect to AWS and the other connection values within [Elasticsearch] will be ignored.

[Payments]

payments_stripe_publishable_key - Your Stripe API publishable key
payments_stripe_secret_key - Your Stripe API secret key

[Recaptcha]

recaptcha_secret - Your reCAPTCHA secret key

[Rest]

rest_domain - The URL where your REST API will be running

[SMTP]

smtp_username - The username to connect to your SMTP server with
smtp_password - The password to connect to your SMTP server with
smtp_host - The hostname or IP address where your SMTP server is running
smtp_port - The port where your SMTP server is running
```

With the `tasknode.cfg` file now properly filled out, we have one configuration file left. Go ahead and copy over the example Django settings file:

```
cp configs/settings.py.example configs/settings.py
```

Now let's fill the `settings.py` file out. The example `settings.py` file contains blocks surrounded by square brackets (`[[EXAMPLE]]`) for all of the places where you must update the configuration file. The values should be updated as follows:

```
[[DJANGO_SECRET]] - A large, unguessable random string
[[DB_NAME]] - The name of the database that Web Sight will use
[[DB_USER]] - The user to connect to the database with
[[DB_PASSWORD]] - The password to connect to the database with
[[DB_HOST]] - The hostname or IP address where the database resides
[[DB_PORT]] - The port where the database resides
[[SMTP_HOST]] - The hostname or IP address where your SMTP server resides
[[SMTP_PORT]] - The port where your SMTP server resides
[[SMTP_USER]] - The user to connect to your SMTP server with
[[SMTP_PASSWORD]] - The password to connect to your SMTP server with
[[SMTP_USE_TLS]] - A boolean value depicting whether or not to connect to your SMTP server using SSL/TLS.
```

Now that all of the configuration files are filled out, let's generate a self-signed SSL certificate for our front-end application to use:

```
openssl req -x509 -newkey rsa:4096 -keyout nginx/server.key -out nginx/server.crt -days 365 -nodes
```

With all of that done, your Dockerized Web Sight deployment should be entirely configured! We can now move on to building the Docker images.

## Building the Docker Images

The Web Sight deployment contains all of the Dockerfiles that it relies upon in the `dockerfiles` directory. The contents of this directory are explained below:

```
api.dockerfile - This is the image that runs the Django Rest Framework application for the Web Sight API.
backend-base.dockerfile - This is the base image that both the tasknode and the REST API server are built upon. It installs all of the dependencies that are relied upon by both node types in the deployment.
frontend-base.dockerfile - This is the base image for the web server that hosts the single page application used by Web Sight. It installs and configures Nginx as well as the tools necessary for building the front-end application.
frontend.dockerfile - This is the full image for the front-end that contains the compiled single page application.
tasknode.dockerfile - This is the image that contains the code run by tasknodes in the deployment.
```

To build all of the images in one fell swoop, go ahead and invoke the Docker building script as follows:

```
./scripts/build-all-images.sh
```

The script quite simply builds all of the images used by the Web Sight Docker deployment:

```
docker build -f dockerfiles/backend-base.dockerfile -t wsbackend-base:latest .
docker build -f dockerfiles/api.dockerfile -t wsbackend-api:latest .
docker build -f dockerfiles/tasknode.dockerfile -t wsbackend-tasknode:latest .
docker build -f dockerfiles/frontend-base.dockerfile -t wsfrontend-base:latest .
docker build -f dockerfiles/frontend.dockerfile -t wsfrontend:latest .
```

With the images all successfully built, the only step left is initializing our database and Elasticsearch and then we are good to go!

## Initializing Data Stores
